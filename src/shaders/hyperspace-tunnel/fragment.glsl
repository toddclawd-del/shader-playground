/**
 * Hyperspace Tunnel
 * 
 * A mesmerizing infinite tunnel effect inspired by demoscene classics.
 * Uses polar coordinate transformation to create the illusion of flying
 * through an infinite cylinder.
 * 
 * Key techniques:
 * - Polar coordinate mapping (angle + radius → tunnel surface)
 * - Radius → depth illusion (smaller radius = deeper)
 * - Animated UV offset for forward motion
 * - Twist effect via angle modulation
 * - Multiple pattern generators (noise, grid, hexagon, rings)
 * 
 * References:
 * - Shadertoy classic tunnels
 * - "Tunnel Effect" by Lode Vandevenne
 * - Ben Wheatley's Hyperspace Tunnel (Perlin cylinder mapping)
 */

varying vec2 vUv;

uniform float uTime;
uniform float uSpeed;
uniform float uTwist;
uniform float uZoom;
uniform float uPatternScale;
uniform float uPatternStyle;
uniform float uColorStyle;
uniform float uGlowIntensity;
uniform float uFogDensity;
uniform float uPulseAmount;
uniform float uDistortion;
uniform float uNoiseOctaves;
uniform float uVignetteStrength;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uColor3;
uniform vec2 uCenterOffset;

#define PI 3.14159265359
#define TAU 6.28318530718

// ========================================
// NOISE FUNCTIONS
// ========================================

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f); // smoothstep
    
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p, float octaves) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    
    for (float i = 0.0; i < 6.0; i++) {
        if (i >= octaves) break;
        value += amplitude * noise(p * frequency);
        amplitude *= 0.5;
        frequency *= 2.0;
    }
    return value;
}

// ========================================
// COLOR PALETTES
// ========================================

vec3 cosinePalette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(TAU * (c * t + d));
}

vec3 paletteNeon(float t) {
    return cosinePalette(t,
        vec3(0.5, 0.5, 0.5),
        vec3(0.5, 0.5, 0.5),
        vec3(1.0, 1.0, 1.0),
        vec3(0.0, 0.1, 0.2)
    );
}

vec3 paletteRetro(float t) {
    // Purple/pink/cyan retrowave
    return cosinePalette(t,
        vec3(0.5, 0.5, 0.5),
        vec3(0.5, 0.5, 0.5),
        vec3(1.0, 1.0, 0.5),
        vec3(0.8, 0.9, 0.3)
    );
}

vec3 paletteMatrix(float t) {
    // Green matrix vibes
    return cosinePalette(t,
        vec3(0.0, 0.3, 0.0),
        vec3(0.0, 0.5, 0.0),
        vec3(0.0, 1.0, 0.0),
        vec3(0.0, 0.0, 0.0)
    );
}

vec3 paletteFire(float t) {
    return cosinePalette(t,
        vec3(0.5, 0.5, 0.5),
        vec3(0.5, 0.5, 0.5),
        vec3(1.0, 1.0, 0.5),
        vec3(0.0, 0.1, 0.2)
    );
}

vec3 paletteCustom(float t) {
    // Three-color gradient
    t = fract(t);
    if (t < 0.5) {
        return mix(uColor1, uColor2, t * 2.0);
    } else {
        return mix(uColor2, uColor3, (t - 0.5) * 2.0);
    }
}

// ========================================
// PATTERN GENERATORS
// ========================================

// Grid/checkerboard pattern
float patternGrid(vec2 uv) {
    vec2 grid = fract(uv * uPatternScale);
    float lines = step(0.05, grid.x) * step(0.05, grid.y);
    float check = step(0.5, fract(uv.x * uPatternScale * 0.5)) + 
                  step(0.5, fract(uv.y * uPatternScale * 0.5));
    return mix(lines, mod(check, 2.0), 0.3);
}

// Hexagonal grid
float patternHexagon(vec2 uv) {
    vec2 p = uv * uPatternScale;
    vec2 h = vec2(1.0, sqrt(3.0));
    vec2 a = mod(p, h) - h * 0.5;
    vec2 b = mod(p - h * 0.5, h) - h * 0.5;
    return min(dot(a, a), dot(b, b));
}

// Concentric rings
float patternRings(vec2 uv) {
    float d = length(uv);
    return sin(d * uPatternScale * 10.0);
}

// Noise-based organic pattern
float patternNoise(vec2 uv) {
    return fbm(uv * uPatternScale, uNoiseOctaves);
}

// Warp stripes
float patternStripes(vec2 uv) {
    float stripe = sin(uv.x * uPatternScale * 20.0);
    stripe += sin(uv.y * uPatternScale * 3.0 + uTime * 0.5) * 0.3;
    return stripe * 0.5 + 0.5;
}

// Star burst
float patternStarburst(vec2 uv) {
    float angle = atan(uv.y, uv.x);
    float rays = sin(angle * floor(uPatternScale * 4.0)) * 0.5 + 0.5;
    float d = length(uv);
    return rays * (1.0 - d * 0.5);
}

// ========================================
// MAIN TUNNEL EFFECT
// ========================================

void main() {
    // Center UV with offset control
    vec2 uv = vUv - 0.5 + uCenterOffset;
    
    // Apply some distortion to the input coords
    if (uDistortion > 0.0) {
        float distortAngle = atan(uv.y, uv.x);
        float distortRadius = length(uv);
        distortRadius += sin(distortAngle * 6.0 + uTime * 2.0) * uDistortion * 0.02;
        uv = vec2(cos(distortAngle), sin(distortAngle)) * distortRadius;
    }
    
    // Convert to polar coordinates
    float angle = atan(uv.y, uv.x);  // -PI to PI
    float radius = length(uv);        // 0 to ~0.7
    
    // Avoid division by zero near center
    radius = max(radius, 0.001);
    
    // Depth is inverse of radius (smaller radius = deeper into tunnel)
    float depth = uZoom / radius;
    
    // Animate depth for forward motion
    float time = uTime * uSpeed;
    depth += time;
    
    // Apply twist (angle changes with depth)
    float twistAmount = uTwist * depth * 0.1;
    angle += twistAmount;
    
    // Create tunnel UV coordinates
    // X = angle (wraps around cylinder)
    // Y = depth (how far into tunnel)
    vec2 tunnelUV = vec2(
        angle / TAU + 0.5,  // Normalize angle to 0-1
        depth
    );
    
    // Add pulse effect
    float pulse = 1.0 + sin(time * 3.0) * uPulseAmount;
    tunnelUV *= pulse;
    
    // Calculate pattern value based on style
    float pattern = 0.0;
    int patternStyle = int(uPatternStyle);
    
    if (patternStyle == 0) {
        pattern = patternNoise(tunnelUV);
    } else if (patternStyle == 1) {
        pattern = patternGrid(tunnelUV);
    } else if (patternStyle == 2) {
        pattern = patternHexagon(tunnelUV);
    } else if (patternStyle == 3) {
        pattern = patternRings(tunnelUV);
    } else if (patternStyle == 4) {
        pattern = patternStripes(tunnelUV);
    } else {
        pattern = patternStarburst(tunnelUV);
    }
    
    // Map pattern to color
    float colorT = pattern + time * 0.1;
    
    vec3 color;
    int colorStyle = int(uColorStyle);
    
    if (colorStyle == 0) {
        color = paletteNeon(colorT);
    } else if (colorStyle == 1) {
        color = paletteRetro(colorT);
    } else if (colorStyle == 2) {
        color = paletteMatrix(colorT);
    } else if (colorStyle == 3) {
        color = paletteFire(colorT);
    } else {
        color = paletteCustom(colorT);
    }
    
    // Apply glow (brighter in center / at edges of patterns)
    float glow = pow(pattern, 0.5) * uGlowIntensity;
    color += glow;
    
    // Fog/fade with depth (things get brighter/dimmer as they approach)
    float fog = exp(-radius * uFogDensity);
    color *= fog;
    
    // Bright center (the light at the end of the tunnel)
    float centerGlow = 1.0 - smoothstep(0.0, 0.1, radius);
    color += centerGlow * vec3(1.0, 1.0, 1.0) * 0.5;
    
    // Vignette (darken edges)
    vec2 vigUv = vUv * 2.0 - 1.0;
    float vignette = 1.0 - dot(vigUv, vigUv) * uVignetteStrength;
    color *= max(vignette, 0.0);
    
    // Clamp final color
    color = clamp(color, 0.0, 1.0);
    
    gl_FragColor = vec4(color, 1.0);
}
