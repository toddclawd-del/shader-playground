varying vec2 vUv;

uniform float uTime;
uniform float uScale;
uniform float uAnimationSpeed;
uniform float uEdgeWidth;
uniform float uEdgeSharpness;
uniform float uCellColorMix;
uniform float uDistanceGlow;
uniform float uJitter;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uColor3;
uniform vec3 uEdgeColor;
uniform vec3 uBackgroundColor;

// ============================================
// Hash functions for deterministic randomness
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
// Voronoi with full cell info
// Returns: vec4(minDist, edgeDist, cellId.x, cellId.y)
// ============================================

vec4 voronoi(vec2 p, float time) {
    vec2 n = floor(p);
    vec2 f = fract(p);
    
    float minDist = 8.0;
    float secondDist = 8.0;
    vec2 closestCell = vec2(0.0);
    vec2 closestPoint = vec2(0.0);
    
    // First pass: find closest point
    for (int j = -2; j <= 2; j++) {
        for (int i = -2; i <= 2; i++) {
            vec2 neighbor = vec2(float(i), float(j));
            vec2 cellId = n + neighbor;
            
            // Random point position within cell
            vec2 randomOffset = hash22(cellId);
            
            // Animate the points - each moves in its own circle/pattern
            vec2 animatedOffset = randomOffset;
            animatedOffset.x += sin(time * (0.5 + randomOffset.x) + randomOffset.y * 6.28) * 0.3;
            animatedOffset.y += cos(time * (0.5 + randomOffset.y) + randomOffset.x * 6.28) * 0.3;
            
            // Apply jitter control (0 = grid, 1 = full random)
            vec2 point = mix(vec2(0.5), animatedOffset, uJitter);
            
            vec2 diff = neighbor + point - f;
            float dist = length(diff);
            
            if (dist < minDist) {
                secondDist = minDist;
                minDist = dist;
                closestCell = cellId;
                closestPoint = neighbor + point;
            } else if (dist < secondDist) {
                secondDist = dist;
            }
        }
    }
    
    // Second pass: calculate precise edge distance
    float edgeDist = 8.0;
    for (int j = -2; j <= 2; j++) {
        for (int i = -2; i <= 2; i++) {
            vec2 neighbor = vec2(float(i), float(j));
            vec2 cellId = n + neighbor;
            
            if (cellId == closestCell) continue;
            
            vec2 randomOffset = hash22(cellId);
            vec2 animatedOffset = randomOffset;
            animatedOffset.x += sin(uTime * uAnimationSpeed * (0.5 + randomOffset.x) + randomOffset.y * 6.28) * 0.3;
            animatedOffset.y += cos(uTime * uAnimationSpeed * (0.5 + randomOffset.y) + randomOffset.x * 6.28) * 0.3;
            vec2 point = mix(vec2(0.5), animatedOffset, uJitter);
            
            vec2 otherPoint = neighbor + point;
            
            // Edge is perpendicular bisector between closest point and this point
            vec2 midpoint = 0.5 * (closestPoint + otherPoint);
            vec2 direction = normalize(otherPoint - closestPoint);
            
            // Distance from fragment to the edge line
            float d = dot(midpoint - f, direction);
            edgeDist = min(edgeDist, d);
        }
    }
    
    return vec4(minDist, edgeDist, closestCell);
}

// ============================================
// Color palette - smooth gradient through 3 colors
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
    vec2 p = uv * uScale;
    
    float time = uTime * uAnimationSpeed;
    
    // Get Voronoi data
    vec4 v = voronoi(p, time);
    float minDist = v.x;
    float edgeDist = v.y;
    vec2 cellId = v.zw;
    
    // Generate unique color per cell based on cell ID
    vec3 cellRandom = hash32(cellId);
    float cellColorIndex = cellRandom.x + cellRandom.y * 0.5 + time * 0.05;
    vec3 cellColor = palette(cellColorIndex);
    
    // Distance-based color (radial gradient within cells)
    vec3 distColor = mix(uColor1, uColor2, minDist);
    
    // Combine cell coloring with distance coloring
    vec3 color = mix(distColor, cellColor, uCellColorMix);
    
    // Add distance-based glow (brighter near cell centers)
    float glow = 1.0 - minDist;
    glow = pow(glow, 2.0);
    color += uDistanceGlow * glow * uColor1 * 0.5;
    
    // Edge detection and rendering
    float edge = smoothstep(uEdgeWidth, uEdgeWidth * (1.0 - uEdgeSharpness), edgeDist);
    
    // Apply edge color
    color = mix(color, uEdgeColor, edge);
    
    // Subtle inner shadow near edges for depth
    float innerShadow = smoothstep(0.0, uEdgeWidth * 3.0, edgeDist);
    color *= 0.7 + 0.3 * innerShadow;
    
    // Background blend for areas far from cell centers
    float bgBlend = smoothstep(0.8, 1.2, minDist);
    color = mix(color, uBackgroundColor, bgBlend);
    
    // Final gamma/tonemap
    color = pow(color, vec3(0.95));
    
    gl_FragColor = vec4(color, 1.0);
}
