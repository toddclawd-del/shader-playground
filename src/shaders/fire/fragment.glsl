/**
 * Procedural Fire Shader
 * 
 * Mesmerizing procedural flames using FBM + domain warping.
 * Flames flicker, dance, rise, and breathe organically.
 * 
 * Key techniques:
 * - Fractal Brownian Motion (FBM) for layered noise
 * - Double domain warping (IQ's secret sauce)
 * - Time-driven UV animation for rising flames
 * - Smooth color gradient mapping
 * 
 * References:
 * - IQ's Domain Warping: https://iquilezles.org/articles/warp/
 * - IQ's FBM: https://iquilezles.org/articles/fbm/
 * - The Book of Shaders Ch. 13: https://thebookofshaders.com/13/
 */

varying vec2 vUv;

uniform float uTime;
uniform float uFlameHeight;
uniform float uFlameWidth;
uniform float uSpeed;
uniform float uTurbulence;
uniform float uFlickerIntensity;
uniform float uOctaves;
uniform float uGlowIntensity;
uniform float uHeatDistortion;
uniform float uSparks;

// Colors
uniform vec3 uCoreColor;
uniform vec3 uMidColor;
uniform vec3 uTipColor;
uniform vec3 uOuterGlow;

// Shape & Style
uniform float uShapeMode;
uniform float uColorMode;

#define PI 3.14159265359
#define TAU 6.28318530718

// ========================================
// NOISE FUNCTIONS
// ========================================

// Simple hash for pseudo-random
float hash(vec2 p) {
    p = fract(p * vec2(234.34, 435.345));
    p += dot(p, p + 34.23);
    return fract(p.x * p.y);
}

// 2D noise
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    
    // Smooth interpolation
    vec2 u = f * f * (3.0 - 2.0 * f);
    
    // Four corners
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

// Fractal Brownian Motion
float fbm(vec2 p, int octaves) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    float lacunarity = 2.0;
    float persistence = 0.5;
    
    for (int i = 0; i < 8; i++) {
        if (i >= octaves) break;
        value += amplitude * noise(p * frequency);
        frequency *= lacunarity;
        amplitude *= persistence;
    }
    
    return value;
}

// ========================================
// DOMAIN WARPING (IQ's technique)
// ========================================

// Single-layer warp
float warpedNoise(vec2 p, float time, int octaves) {
    vec2 q = vec2(
        fbm(p + vec2(0.0, 0.0), octaves),
        fbm(p + vec2(5.2, 1.3), octaves)
    );
    
    vec2 r = vec2(
        fbm(p + 4.0 * q + vec2(1.7, 9.2) + time * 0.15, octaves),
        fbm(p + 4.0 * q + vec2(8.3, 2.8) + time * 0.126, octaves)
    );
    
    return fbm(p + 4.0 * r * uTurbulence, octaves);
}

// ========================================
// FLAME SHAPE MASKS
// ========================================

// Natural flame (teardrop-ish)
float naturalMask(vec2 uv) {
    // Center horizontally
    float x = (uv.x - 0.5) * 2.0 / uFlameWidth;
    float y = uv.y;
    
    // Teardrop shape: wider at bottom, narrow at top
    float widthAtY = mix(1.0, 0.0, pow(y, 0.7));
    float horizontal = smoothstep(widthAtY, widthAtY * 0.5, abs(x));
    
    // Vertical falloff - flames taper off at top
    float vertical = smoothstep(uFlameHeight, 0.0, y);
    
    return horizontal * vertical;
}

// Torch (narrow, tall)
float torchMask(vec2 uv) {
    float x = (uv.x - 0.5) * 3.0 / uFlameWidth;
    float y = uv.y;
    
    float widthAtY = mix(0.6, 0.0, pow(y, 0.5));
    float horizontal = smoothstep(widthAtY, widthAtY * 0.3, abs(x));
    float vertical = smoothstep(uFlameHeight * 1.5, 0.0, y);
    
    return horizontal * vertical;
}

// Candle (small, gentle)
float candleMask(vec2 uv) {
    float x = (uv.x - 0.5) * 4.0 / uFlameWidth;
    float y = uv.y;
    
    float widthAtY = mix(0.4, 0.0, pow(y, 0.6));
    float horizontal = smoothstep(widthAtY, widthAtY * 0.2, abs(x));
    float vertical = smoothstep(uFlameHeight * 0.6, 0.0, y);
    
    return horizontal * vertical;
}

// Explosion (radial burst)
float explosionMask(vec2 uv) {
    vec2 center = vec2(0.5, 0.3);
    float dist = length((uv - center) / vec2(uFlameWidth, uFlameHeight));
    return smoothstep(1.0, 0.0, dist);
}

// Wall of fire
float wallMask(vec2 uv) {
    float y = uv.y;
    float vertical = smoothstep(uFlameHeight, 0.0, y);
    return vertical;
}

float getShapeMask(vec2 uv) {
    int shape = int(uShapeMode);
    if (shape == 0) return naturalMask(uv);
    if (shape == 1) return torchMask(uv);
    if (shape == 2) return candleMask(uv);
    if (shape == 3) return explosionMask(uv);
    return wallMask(uv);
}

// ========================================
// COLOR PALETTES
// ========================================

// Realistic fire
vec3 realisticPalette(float t) {
    vec3 core = vec3(0.1, 0.0, 0.0);      // Deep dark red
    vec3 inner = vec3(1.0, 0.1, 0.0);     // Bright red
    vec3 mid = vec3(1.0, 0.4, 0.0);       // Orange
    vec3 outer = vec3(1.0, 0.8, 0.0);     // Yellow
    vec3 tip = vec3(1.0, 1.0, 0.9);       // White-hot
    
    if (t < 0.2) return mix(core, inner, t * 5.0);
    if (t < 0.4) return mix(inner, mid, (t - 0.2) * 5.0);
    if (t < 0.7) return mix(mid, outer, (t - 0.4) * 3.33);
    return mix(outer, tip, (t - 0.7) * 3.33);
}

// Neon/cyberpunk
vec3 neonPalette(float t) {
    vec3 core = vec3(0.05, 0.0, 0.1);
    vec3 inner = vec3(1.0, 0.0, 0.5);     // Hot pink
    vec3 mid = vec3(0.5, 0.0, 1.0);       // Purple
    vec3 outer = vec3(0.0, 0.8, 1.0);     // Cyan
    vec3 tip = vec3(1.0, 1.0, 1.0);
    
    if (t < 0.25) return mix(core, inner, t * 4.0);
    if (t < 0.5) return mix(inner, mid, (t - 0.25) * 4.0);
    if (t < 0.75) return mix(mid, outer, (t - 0.5) * 4.0);
    return mix(outer, tip, (t - 0.75) * 4.0);
}

// Infernal/demonic
vec3 infernalPalette(float t) {
    vec3 core = vec3(0.0, 0.0, 0.0);      // Void black
    vec3 inner = vec3(0.2, 0.0, 0.0);     // Dark blood
    vec3 mid = vec3(0.5, 0.0, 0.0);       // Deep red
    vec3 outer = vec3(1.0, 0.0, 0.0);     // Bright red
    vec3 tip = vec3(1.0, 0.4, 0.0);       // Orange tips
    
    if (t < 0.3) return mix(core, inner, t * 3.33);
    if (t < 0.5) return mix(inner, mid, (t - 0.3) * 5.0);
    if (t < 0.8) return mix(mid, outer, (t - 0.5) * 3.33);
    return mix(outer, tip, (t - 0.8) * 5.0);
}

// Ice fire
vec3 icePalette(float t) {
    vec3 core = vec3(0.0, 0.05, 0.2);
    vec3 inner = vec3(0.0, 0.3, 1.0);     // Deep blue
    vec3 mid = vec3(0.0, 0.7, 1.0);       // Cyan-blue
    vec3 outer = vec3(0.5, 0.9, 1.0);     // Light cyan
    vec3 tip = vec3(1.0, 1.0, 1.0);       // White
    
    if (t < 0.25) return mix(core, inner, t * 4.0);
    if (t < 0.5) return mix(inner, mid, (t - 0.25) * 4.0);
    if (t < 0.75) return mix(mid, outer, (t - 0.5) * 4.0);
    return mix(outer, tip, (t - 0.75) * 4.0);
}

// Custom (use uniform colors)
vec3 customPalette(float t) {
    if (t < 0.5) return mix(uCoreColor, uMidColor, t * 2.0);
    return mix(uMidColor, uTipColor, (t - 0.5) * 2.0);
}

vec3 getFireColor(float t) {
    int mode = int(uColorMode);
    if (mode == 0) return realisticPalette(t);
    if (mode == 1) return neonPalette(t);
    if (mode == 2) return infernalPalette(t);
    if (mode == 3) return icePalette(t);
    return customPalette(t);
}

// ========================================
// SPARKS (bonus effect)
// ========================================

float sparks(vec2 uv, float time) {
    if (uSparks < 0.01) return 0.0;
    
    float spark = 0.0;
    for (int i = 0; i < 5; i++) {
        vec2 pos = vec2(
            hash(vec2(float(i), 0.0)) * 0.6 + 0.2,
            mod(hash(vec2(float(i), 1.0)) + time * (0.3 + hash(vec2(float(i), 2.0)) * 0.2), 1.0)
        );
        float dist = length(uv - pos);
        spark += smoothstep(0.02, 0.0, dist) * hash(vec2(time, float(i)));
    }
    return spark * uSparks;
}

// ========================================
// MAIN
// ========================================

void main() {
    vec2 uv = vUv;
    float time = uTime * uSpeed;
    int octaves = int(uOctaves);
    
    // Heat distortion (optional shimmer effect)
    if (uHeatDistortion > 0.01) {
        float distort = fbm(uv * 8.0 + time * 2.0, 3) * 0.02 * uHeatDistortion;
        uv.x += distort;
    }
    
    // Animate UVs upward - flames rise
    vec2 noiseUv = uv;
    noiseUv.y -= time * 0.5;
    
    // Scale for noise detail
    noiseUv *= 3.0;
    
    // Get warped noise value
    float n = warpedNoise(noiseUv, time, octaves);
    
    // Add flicker
    float flicker = 1.0 + (noise(vec2(time * 5.0, uv.x * 3.0)) - 0.5) * uFlickerIntensity;
    n *= flicker;
    
    // Get shape mask
    float mask = getShapeMask(uv);
    
    // Add turbulence to mask edges
    float edgeNoise = fbm(uv * 5.0 + vec2(0.0, -time * 0.3), 3);
    mask *= smoothstep(0.0, 0.3, mask + (edgeNoise - 0.5) * uTurbulence * 0.5);
    
    // Combine noise with mask for final flame shape
    float flame = n * mask;
    flame = smoothstep(0.0, 0.7, flame);
    
    // Get color based on flame intensity
    vec3 color = getFireColor(flame);
    
    // Add outer glow
    float glowMask = getShapeMask(uv);
    glowMask = smoothstep(0.0, 0.5, glowMask);
    vec3 glow = uOuterGlow * glowMask * (1.0 - flame) * uGlowIntensity;
    color += glow;
    
    // Add sparks
    float sparkVal = sparks(uv, time);
    color += vec3(1.0, 0.8, 0.4) * sparkVal;
    
    // Final alpha based on mask
    float alpha = max(flame, glowMask * uGlowIntensity * 0.5);
    alpha = max(alpha, sparkVal);
    
    // For solid background mode, always full alpha
    alpha = max(alpha, 0.0);
    
    gl_FragColor = vec4(color, 1.0);
}
