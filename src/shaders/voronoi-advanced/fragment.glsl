varying vec2 vUv;

uniform float uTime;
uniform float uCellCount;
uniform float uEdgeThickness;
uniform float uAnimationSpeed;
uniform float uColorMode; // 0=cells, 1=edges, 2=distance
uniform float uMouseMode; // -1=repel, 0=none, 1=attract
uniform vec2 uMouse;
uniform float uMouseDown;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uColor3;
uniform vec3 uEdgeColor;
uniform vec3 uBackgroundColor;

// ============================================
// Hash Functions
// ============================================

vec2 hash22(vec2 p) {
    vec3 a = fract(p.xyx * vec3(234.34, 435.345, 654.165));
    a += dot(a, a + 34.23);
    return fract(vec2(a.x * a.y, a.y * a.z));
}

vec3 hash32(vec2 p) {
    vec3 a = fract(p.xyx * vec3(234.34, 435.345, 654.165));
    a += dot(a, a.yzx + 34.23);
    return fract(vec3(a.x * a.y, a.y * a.z, a.z * a.x));
}

// ============================================
// Voronoi with Mouse Interaction
// ============================================

struct VoronoiResult {
    float minDist;
    float secondDist;
    float edgeDist;
    vec2 closestPoint;
    vec2 cellId;
};

VoronoiResult voronoi(vec2 p, float time, vec2 mouse, float mouseForce) {
    vec2 n = floor(p);
    vec2 f = fract(p);
    
    VoronoiResult result;
    result.minDist = 8.0;
    result.secondDist = 8.0;
    result.edgeDist = 8.0;
    result.closestPoint = vec2(0.0);
    result.cellId = vec2(0.0);
    
    // First pass: find closest and second closest
    for (int j = -2; j <= 2; j++) {
        for (int i = -2; i <= 2; i++) {
            vec2 neighbor = vec2(float(i), float(j));
            vec2 cellId = n + neighbor;
            
            // Base random position
            vec2 randomOffset = hash22(cellId);
            
            // Animate position
            vec2 animatedOffset = randomOffset;
            animatedOffset.x += sin(time * (0.3 + randomOffset.x * 0.4) + randomOffset.y * 6.28) * 0.35;
            animatedOffset.y += cos(time * (0.3 + randomOffset.y * 0.4) + randomOffset.x * 6.28) * 0.35;
            
            // Mouse interaction - push or pull points
            vec2 worldPos = (cellId + animatedOffset) / uCellCount;
            vec2 toMouse = mouse - worldPos;
            float mouseDist = length(toMouse);
            float mouseInfluence = smoothstep(0.4, 0.0, mouseDist) * mouseForce * 0.3;
            
            // Apply mouse force (positive = attract, negative = repel)
            animatedOffset += normalize(toMouse + 0.001) * mouseInfluence * uCellCount;
            
            // Stronger effect when mouse is down
            if (uMouseDown > 0.5) {
                animatedOffset += normalize(toMouse + 0.001) * mouseInfluence * uCellCount * 0.5;
            }
            
            vec2 point = neighbor + animatedOffset;
            vec2 diff = point - f;
            float dist = length(diff);
            
            if (dist < result.minDist) {
                result.secondDist = result.minDist;
                result.minDist = dist;
                result.closestPoint = point;
                result.cellId = cellId;
            } else if (dist < result.secondDist) {
                result.secondDist = dist;
            }
        }
    }
    
    // Second pass: calculate edge distance
    for (int j = -2; j <= 2; j++) {
        for (int i = -2; i <= 2; i++) {
            vec2 neighbor = vec2(float(i), float(j));
            vec2 cellId = n + neighbor;
            
            if (cellId == result.cellId) continue;
            
            vec2 randomOffset = hash22(cellId);
            vec2 animatedOffset = randomOffset;
            animatedOffset.x += sin(time * (0.3 + randomOffset.x * 0.4) + randomOffset.y * 6.28) * 0.35;
            animatedOffset.y += cos(time * (0.3 + randomOffset.y * 0.4) + randomOffset.x * 6.28) * 0.35;
            
            // Apply same mouse interaction
            vec2 worldPos = (cellId + animatedOffset) / uCellCount;
            vec2 toMouse = mouse - worldPos;
            float mouseDist = length(toMouse);
            float mouseInfluence = smoothstep(0.4, 0.0, mouseDist) * mouseForce * 0.3;
            animatedOffset += normalize(toMouse + 0.001) * mouseInfluence * uCellCount;
            if (uMouseDown > 0.5) {
                animatedOffset += normalize(toMouse + 0.001) * mouseInfluence * uCellCount * 0.5;
            }
            
            vec2 otherPoint = neighbor + animatedOffset;
            vec2 midpoint = 0.5 * (result.closestPoint + otherPoint);
            vec2 direction = normalize(otherPoint - result.closestPoint);
            float d = dot(midpoint - f, direction);
            result.edgeDist = min(result.edgeDist, d);
        }
    }
    
    return result;
}

// ============================================
// Color Palette
// ============================================

vec3 palette(float t) {
    t = fract(t);
    if (t < 0.33) {
        return mix(uColor1, uColor2, t * 3.0);
    } else if (t < 0.66) {
        return mix(uColor2, uColor3, (t - 0.33) * 3.0);
    } else {
        return mix(uColor3, uColor1, (t - 0.66) * 3.0);
    }
}

// ============================================
// Main
// ============================================

void main() {
    vec2 uv = vUv;
    vec2 p = uv * uCellCount;
    float time = uTime * uAnimationSpeed;
    
    // Get voronoi data with mouse interaction
    VoronoiResult v = voronoi(p, time, uMouse, uMouseMode);
    
    // Cell color based on cell ID
    vec3 cellRandom = hash32(v.cellId);
    float cellColorIndex = cellRandom.x + cellRandom.y * 0.5 + time * 0.05;
    vec3 cellColor = palette(cellColorIndex);
    
    // Apply color mode
    int colorMode = int(uColorMode + 0.5);
    vec3 color;
    
    if (colorMode == 0) {
        // Cell colors
        color = cellColor;
        
        // Add slight gradient within cells
        float gradient = 1.0 - v.minDist * 0.3;
        color *= gradient;
    } else if (colorMode == 1) {
        // Edge highlight mode
        color = uBackgroundColor;
        
        // Edge glow
        float edge = smoothstep(uEdgeThickness, 0.0, v.edgeDist);
        color = mix(color, uEdgeColor, edge);
        
        // Subtle cell tint
        color = mix(color, cellColor * 0.3, 0.2);
    } else {
        // Distance field visualization
        float normalizedDist = v.minDist / 1.5;
        color = palette(normalizedDist);
        
        // Add edge highlight
        float edge = smoothstep(uEdgeThickness * 0.5, 0.0, v.edgeDist);
        color = mix(color, uEdgeColor, edge * 0.5);
    }
    
    // Cell center glow
    float centerGlow = smoothstep(0.3, 0.0, v.minDist);
    color += cellColor * centerGlow * 0.2;
    
    // Edge rendering for all modes
    float edgeStrength = smoothstep(uEdgeThickness, uEdgeThickness * 0.5, v.edgeDist);
    color = mix(color, uEdgeColor, edgeStrength * 0.8);
    
    // Mouse glow effect
    float mouseGlow = smoothstep(0.2, 0.0, length(uv - uMouse));
    vec3 glowColor = mix(uColor1, uColor2, 0.5);
    color += glowColor * mouseGlow * 0.3 * (1.0 + uMouseDown);
    
    // Subtle vignette
    float vignette = 1.0 - length(uv - 0.5) * 0.3;
    color *= vignette;
    
    // Gamma correction
    color = pow(color, vec3(0.95));
    
    gl_FragColor = vec4(color, 1.0);
}
