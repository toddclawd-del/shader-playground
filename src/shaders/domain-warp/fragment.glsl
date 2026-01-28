// Domain Warping Shader
// Based on Inigo Quilez's technique: https://iquilezles.org/articles/warp/
// 
// The core idea: warp the domain of a noise function with another noise function
// f(p) → f(p + fbm(p)) → f(p + fbm(p + fbm(p)))
// 
// This creates organic, marble-like flowing patterns by recursively distorting
// the sampling coordinates before evaluating the final noise.

varying vec2 vUv;

uniform float uTime;
uniform float uScale;
uniform float uWarpIntensity1;
uniform float uWarpIntensity2;
uniform float uAnimSpeed;
uniform float uOctaves;
uniform float uLacunarity;
uniform float uGain;
uniform float uColorVariation;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uColor3;
uniform vec3 uColor4;
uniform vec3 uBackgroundColor;

// ============================================
// Noise Functions (inlined for performance)
// ============================================

// Smooth hash for pseudo-random
vec2 hash22(vec2 p) {
    vec3 a = fract(p.xyx * vec3(234.34, 435.345, 654.165));
    a += dot(a, a + 34.23);
    return fract(vec2(a.x * a.y, a.y * a.z));
}

float hash21(vec2 p) {
    p = fract(p * vec2(234.34, 435.345));
    p += dot(p, p + 34.23);
    return fract(p.x * p.y);
}

// Quintic interpolation (smoother than cubic)
vec2 quintic(vec2 t) {
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

// Value noise with smooth interpolation
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    
    // Four corner values
    float a = hash21(i);
    float b = hash21(i + vec2(1.0, 0.0));
    float c = hash21(i + vec2(0.0, 1.0));
    float d = hash21(i + vec2(1.0, 1.0));
    
    // Smooth interpolation
    vec2 u = quintic(f);
    
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

// Fractal Brownian Motion
// Sums multiple octaves of noise with increasing frequency and decreasing amplitude
// This creates natural-looking patterns with detail at multiple scales
float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    float maxValue = 0.0;
    
    int oct = int(uOctaves);
    
    for (int i = 0; i < 8; i++) {
        if (i >= oct) break;
        value += amplitude * noise(p * frequency);
        maxValue += amplitude;
        frequency *= uLacunarity;
        amplitude *= uGain;
    }
    
    return value / maxValue;
}

// ============================================
// Domain Warping Pattern
// ============================================

// This is the heart of the shader.
// We compute the pattern and expose intermediate values (q, r) for coloring.
//
// Mathematical breakdown:
// 1. q = vec2(fbm(p + offset1), fbm(p + offset2)) - First warp layer
// 2. r = vec2(fbm(p + q + offset3), fbm(p + q + offset4)) - Second warp layer  
// 3. pattern = fbm(p + r) - Final pattern
//
// Each layer feeds into the next, creating recursive distortion.
// The offsets prevent symmetry and add variation.

float pattern(vec2 p, out vec2 q, out vec2 r) {
    float t = uTime * uAnimSpeed;
    
    // First warp layer - creates the primary distortion
    // Different offsets give each component a unique character
    q = vec2(
        fbm(p + vec2(0.0, 0.0) + 0.1 * t),
        fbm(p + vec2(5.2, 1.3) - 0.12 * t)
    );
    
    // Second warp layer - distorts based on first layer
    // The 4.0 multiplier controls how strongly q affects the lookup
    r = vec2(
        fbm(p + uWarpIntensity1 * q + vec2(1.7, 9.2) + 0.15 * t),
        fbm(p + uWarpIntensity1 * q + vec2(8.3, 2.8) - 0.13 * t)
    );
    
    // Final pattern - the fully warped noise
    return fbm(p + uWarpIntensity2 * r);
}

// ============================================
// Main
// ============================================

void main() {
    vec2 uv = vUv;
    
    // Center and scale UVs
    vec2 p = (uv - 0.5) * uScale;
    
    // Compute pattern with intermediate values
    vec2 q, r;
    float f = pattern(p, q, r);
    
    // ----------------------------------------
    // Coloring using intermediate values
    // ----------------------------------------
    // This is where domain warping gets interesting for color.
    // Instead of just mapping the final pattern to a gradient,
    // we use q and r to add extra color variation.
    
    // Base color from pattern value
    vec3 color = mix(uColor1, uColor2, f);
    
    // Mix with Color3 based on magnitude of first warp (q)
    // length(q) tells us how much distortion happened in the first pass
    float qMag = length(q);
    color = mix(color, uColor3, qMag * uColorVariation);
    
    // Mix with Color4 based on directional component of second warp (r)
    // r.y gives us vertical variation in the second warp layer
    float rComponent = clamp(r.y + 0.5, 0.0, 1.0);
    color = mix(color, uColor4, rComponent * uColorVariation * 0.7);
    
    // Add subtle gradient variation based on q direction
    // This creates those beautiful flowing color bands
    float qAngle = atan(q.y, q.x) / 6.28318 + 0.5;
    color += (uColor2 - uColor1) * qAngle * 0.1 * uColorVariation;
    
    // Subtle background tint at edges
    float edge = smoothstep(0.3, 0.5, length(uv - 0.5));
    color = mix(color, uBackgroundColor, edge * 0.3);
    
    // Boost contrast slightly
    color = pow(color, vec3(0.95));
    
    // Clamp to valid range
    color = clamp(color, 0.0, 1.0);
    
    gl_FragColor = vec4(color, 1.0);
}
