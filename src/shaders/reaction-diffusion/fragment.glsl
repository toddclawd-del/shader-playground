// ============================================
// Reaction-Diffusion Shader
// Artistic approximation of Gray-Scott model
// Creates organic patterns like:
// - Mitosis (cell division)
// - Coral growth
// - Animal skin patterns (spots/stripes)
//
// Note: True RD needs ping-pong buffers.
// This approximates the visual aesthetic.
// ============================================

precision highp float;

varying vec2 vUv;

uniform float uTime;
uniform float uFeedRate;
uniform float uKillRate;
uniform float uDiffusionA;
uniform float uDiffusionB;
uniform float uBrushSize;
uniform vec2 uMouse;
uniform float uMouseDown;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uColor3;
uniform vec3 uBackgroundColor;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p, int octaves) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    
    for (int i = 0; i < 8; i++) {
        if (i >= octaves) break;
        value += amplitude * noise(p * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

// Turing pattern simulation
// Creates spots and stripes similar to reaction-diffusion
float turingPattern(vec2 p, float time) {
    // Scale parameters
    float scale = 10.0 + uDiffusionA * 20.0;
    
    // Multiple layers of patterns
    float pattern = 0.0;
    
    // Layer 1: Base spots
    vec2 p1 = p * scale;
    float spots = fbm(p1 + time * uFeedRate * 2.0, 4);
    spots = smoothstep(0.4, 0.6, spots);
    
    // Layer 2: Fine structure
    vec2 p2 = p * scale * 2.0;
    float fine = fbm(p2 - time * uKillRate, 3);
    fine = smoothstep(0.45, 0.55, fine);
    
    // Layer 3: Large scale modulation
    vec2 p3 = p * scale * 0.5;
    float large = fbm(p3 + time * 0.1, 2);
    
    // Combine with reaction-diffusion-like mixing
    pattern = spots * (0.5 + large * 0.5);
    pattern = mix(pattern, fine, 0.3 * large);
    
    // Add activator-inhibitor dynamics
    float inhibitor = fbm(p * scale * 1.5 + time * uKillRate * 3.0, 3);
    float activator = fbm(p * scale * 0.8 - time * uFeedRate, 4);
    
    // Mix based on diffusion rates
    float reaction = activator - inhibitor * uDiffusionB;
    reaction = smoothstep(-0.2, 0.2, reaction);
    
    pattern = mix(pattern, reaction, 0.4);
    
    return pattern;
}

// Cell-like structures
float cellPattern(vec2 p, float time) {
    float scale = 5.0 + uDiffusionA * 10.0;
    vec2 scaled = p * scale;
    
    // Create voronoi-like cells
    vec2 i = floor(scaled);
    vec2 f = fract(scaled);
    
    float minDist = 1.0;
    float secondDist = 1.0;
    
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 neighbor = vec2(float(x), float(y));
            vec2 cellPos = neighbor + hash(i + neighbor + floor(time * uFeedRate * 10.0) * 0.01) * 0.8;
            
            // Animate cell positions
            cellPos += vec2(
                sin(time * uKillRate * 2.0 + hash(i + neighbor) * 6.28) * 0.1,
                cos(time * uKillRate * 2.0 + hash(i + neighbor + vec2(1.0)) * 6.28) * 0.1
            );
            
            float dist = length(f - cellPos);
            
            if (dist < minDist) {
                secondDist = minDist;
                minDist = dist;
            } else if (dist < secondDist) {
                secondDist = dist;
            }
        }
    }
    
    // Edge detection (membrane-like)
    float edge = secondDist - minDist;
    edge = smoothstep(0.0, 0.1 * uDiffusionB, edge);
    
    // Cell interior
    float interior = smoothstep(0.3, 0.1, minDist);
    
    return mix(edge, interior, 0.5);
}

// ============================================
// Main
// ============================================

void main() {
    vec2 uv = vUv;
    float time = uTime * 0.3;
    
    // Mouse interaction - add chemical B where mouse is
    float mouseDist = length(uv - uMouse);
    float mouseInfluence = smoothstep(uBrushSize, 0.0, mouseDist);
    
    // If mouse is down, create disturbance
    if (uMouseDown > 0.5) {
        mouseInfluence *= 2.0;
    }
    
    // Get base patterns
    float turing = turingPattern(uv, time);
    float cells = cellPattern(uv, time);
    
    // Mix patterns based on feed/kill rates
    float mixRatio = uFeedRate / (uFeedRate + uKillRate + 0.001);
    float pattern = mix(turing, cells, mixRatio);
    
    // Apply mouse disturbance
    pattern = mix(pattern, 1.0 - pattern, mouseInfluence * 0.5);
    
    // Create color gradient based on concentration
    vec3 color;
    
    if (pattern < 0.33) {
        color = mix(uBackgroundColor, uColor1, pattern * 3.0);
    } else if (pattern < 0.66) {
        color = mix(uColor1, uColor2, (pattern - 0.33) * 3.0);
    } else {
        color = mix(uColor2, uColor3, (pattern - 0.66) * 3.0);
    }
    
    // Add subtle highlights at high concentrations
    float highlight = smoothstep(0.7, 0.9, pattern);
    color += vec3(highlight * 0.2);
    
    // Mouse glow
    float mouseGlow = smoothstep(uBrushSize * 1.5, 0.0, mouseDist) * 0.3;
    color += uColor3 * mouseGlow * (1.0 + uMouseDown);
    
    // Subtle vignette
    float vignette = 1.0 - length(vUv - 0.5) * 0.3;
    color *= vignette;
    
    gl_FragColor = vec4(color, 1.0);
}
