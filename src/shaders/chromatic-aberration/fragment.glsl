// ============================================
// Chromatic Aberration Shader
// Simulates optical lens imperfections by
// offsetting RGB channels independently.
// Features: barrel distortion, vignette, film grain
// ============================================

precision highp float;

varying vec2 vUv;

uniform float uTime;
uniform float uAberrationStrength;
uniform float uMode; // 0=radial, 1=directional, 2=mouse-based
uniform float uRedOffset;
uniform float uGreenOffset;
uniform float uBlueOffset;
uniform float uBarrelDistortion;
uniform float uVignette;
uniform vec2 uMouse;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uColor3;

#define PI 3.14159265359

// ============================================
// Noise for background patterns
// ============================================

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

float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    for (int i = 0; i < 5; i++) {
        value += amplitude * noise(p);
        p *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

// ============================================
// Distortion Functions
// ============================================

// Barrel/pincushion distortion
vec2 barrelDistort(vec2 uv, float strength) {
    vec2 centered = uv - 0.5;
    float dist = length(centered);
    float distortion = 1.0 + strength * dist * dist;
    return centered * distortion + 0.5;
}

// Get chromatic offset based on mode
vec2 getOffset(vec2 uv, float amount, int mode) {
    vec2 center = vec2(0.5);
    
    if (mode == 0) {
        // Radial - offset from center
        vec2 toCenter = uv - center;
        return normalize(toCenter) * amount;
    } else if (mode == 1) {
        // Directional - horizontal offset
        return vec2(amount, 0.0);
    } else {
        // Mouse-based - offset from mouse position
        vec2 toMouse = uv - uMouse;
        float dist = length(toMouse);
        float influence = smoothstep(0.5, 0.0, dist);
        return toMouse * amount * influence * 5.0;
    }
}

// ============================================
// Base Pattern - Vibrant design for chromatic effect
// ============================================

vec3 basePattern(vec2 uv, float time) {
    // High-contrast patterns that showcase chromatic aberration
    
    // Flowing organic shapes
    float n1 = fbm(uv * 2.5 + time * 0.2);
    float n2 = fbm(uv * 4.0 - time * 0.15 + 5.0);
    
    // Animated concentric rings
    vec2 center = vec2(0.5);
    float dist = length(uv - center);
    float rings = sin(dist * 25.0 - time * 3.0) * 0.5 + 0.5;
    rings = pow(rings, 0.7); // Sharpen rings for more aberration contrast
    
    // Bold diagonal stripes
    float stripe = sin((uv.x - uv.y) * 20.0 + time * 1.5);
    stripe = smoothstep(-0.3, 0.3, stripe);
    
    // Hexagonal-like pattern
    vec2 hexUv = uv * 6.0;
    float hex = sin(hexUv.x + sin(hexUv.y * 1.5)) * cos(hexUv.y + cos(hexUv.x * 1.5));
    hex = smoothstep(-0.5, 0.5, hex);
    
    // Layer patterns with strong contrast
    float pattern = rings * 0.4 + stripe * 0.3 + hex * 0.2 + n1 * 0.1;
    
    // Create sharp edges for dramatic aberration
    float edges = smoothstep(0.4, 0.6, n2);
    pattern = mix(pattern, edges, 0.25);
    
    // Vibrant color mapping
    vec3 color = mix(uColor1, uColor2, pattern);
    color = mix(color, uColor3, rings * n1 * 0.8);
    
    // Add brightness variation
    color *= 0.8 + n1 * 0.4;
    
    return color;
}

// ============================================
// Main
// ============================================

void main() {
    vec2 uv = vUv;
    float time = uTime;
    
    // Apply barrel distortion first
    vec2 distortedUv = barrelDistort(uv, uBarrelDistortion);
    
    // Get mode as integer
    int mode = int(uMode + 0.5);
    
    // Calculate channel offsets
    float baseStrength = uAberrationStrength * 0.1;
    
    vec2 redOffset = getOffset(distortedUv, baseStrength * uRedOffset, mode);
    vec2 greenOffset = getOffset(distortedUv, baseStrength * uGreenOffset, mode);
    vec2 blueOffset = getOffset(distortedUv, baseStrength * uBlueOffset, mode);
    
    // Sample each color channel with different offsets
    vec3 redSample = basePattern(distortedUv + redOffset, time);
    vec3 greenSample = basePattern(distortedUv + greenOffset, time);
    vec3 blueSample = basePattern(distortedUv + blueOffset, time);
    
    // Combine channels
    vec3 color = vec3(
        redSample.r,
        greenSample.g,
        blueSample.b
    );
    
    // Add subtle color fringing at edges
    float edgeDist = length(uv - 0.5) * 2.0;
    float fringe = smoothstep(0.5, 1.0, edgeDist) * uAberrationStrength;
    color.r += fringe * 0.1;
    color.b -= fringe * 0.1;
    
    // Apply vignette
    float vig = 1.0 - edgeDist * uVignette;
    vig = smoothstep(0.0, 1.0, vig);
    color *= vig;
    
    // Add film grain
    float grain = hash(uv * 500.0 + time) * 0.05;
    color += grain - 0.025;
    
    // Subtle color correction
    color = pow(color, vec3(0.95));
    
    gl_FragColor = vec4(color, 1.0);
}
