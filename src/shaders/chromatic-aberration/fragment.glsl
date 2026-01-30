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
// Base Pattern (something to apply the effect to)
// ============================================

vec3 basePattern(vec2 uv, float time) {
    // Create interesting patterns to showcase the chromatic effect
    
    // Flowing noise
    float n1 = fbm(uv * 3.0 + time * 0.3);
    float n2 = fbm(uv * 5.0 - time * 0.2 + 10.0);
    
    // Circular patterns
    vec2 center = vec2(0.5);
    float dist = length(uv - center);
    float circles = sin(dist * 20.0 - time * 2.0) * 0.5 + 0.5;
    
    // Grid lines
    vec2 grid = abs(fract(uv * 8.0) - 0.5);
    float lines = smoothstep(0.02, 0.0, min(grid.x, grid.y));
    
    // Diagonal stripes
    float stripe = sin((uv.x + uv.y) * 30.0 + time) * 0.5 + 0.5;
    
    // Combine patterns
    float pattern = n1 * 0.4 + circles * 0.3 + lines * 0.2 + stripe * 0.1;
    
    // Add some sharp edges for more visible chromatic effect
    float edge = smoothstep(0.45, 0.55, n2);
    pattern = mix(pattern, edge, 0.3);
    
    // Create color from pattern
    vec3 color = mix(uColor1, uColor2, pattern);
    color = mix(color, uColor3, n1 * n2);
    
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
