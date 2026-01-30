varying vec2 vUv;

uniform float uTime;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uColor3;
uniform vec3 uColor4;
uniform float uSpeed;
uniform float uScale;
uniform float uComplexity;
uniform float uMouseInfluence;
uniform vec2 uMouse;

// ============================================
// Noise Functions for Organic Movement
// ============================================

vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec4 mod289(vec4 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec4 permute(vec4 x) { return mod289(((x * 34.0) + 1.0) * x); }
vec4 taylorInvSqrt(vec4 r) { return 1.79284291400159 - 0.85373472095314 * r; }

// Simplex 2D noise
float snoise(vec2 v) {
    const vec4 C = vec4(0.211324865405187, 0.366025403784439,
                       -0.577350269189626, 0.024390243902439);
    vec2 i  = floor(v + dot(v, C.yy));
    vec2 x0 = v - i + dot(i, C.xx);
    vec2 i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    i = mod289(i.xyxy).xy;
    vec3 p = permute(permute(i.y + vec3(0.0, i1.y, 1.0)) + i.x + vec3(0.0, i1.x, 1.0));
    vec3 m = max(0.5 - vec3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
    m = m * m;
    m = m * m;
    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;
    m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);
    vec3 g;
    g.x = a0.x * x0.x + h.x * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}

// FBM for layered noise
float fbm(vec2 p, int octaves) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    
    for (int i = 0; i < 10; i++) {
        if (i >= octaves) break;
        value += amplitude * snoise(p * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

// ============================================
// Color Blending Functions
// ============================================

// Smooth blending between 4 colors based on position and noise
vec3 meshGradient(vec2 uv, float time, float complexity) {
    // Create animated control points for the mesh
    vec2 p1 = vec2(0.3, 0.3) + vec2(
        snoise(vec2(time * 0.3, 0.0)) * 0.2,
        snoise(vec2(0.0, time * 0.3)) * 0.2
    );
    vec2 p2 = vec2(0.7, 0.3) + vec2(
        snoise(vec2(time * 0.3 + 1.0, 1.0)) * 0.2,
        snoise(vec2(1.0, time * 0.3 + 1.0)) * 0.2
    );
    vec2 p3 = vec2(0.3, 0.7) + vec2(
        snoise(vec2(time * 0.3 + 2.0, 2.0)) * 0.2,
        snoise(vec2(2.0, time * 0.3 + 2.0)) * 0.2
    );
    vec2 p4 = vec2(0.7, 0.7) + vec2(
        snoise(vec2(time * 0.3 + 3.0, 3.0)) * 0.2,
        snoise(vec2(3.0, time * 0.3 + 3.0)) * 0.2
    );
    
    // Calculate distances to each control point
    float d1 = length(uv - p1);
    float d2 = length(uv - p2);
    float d3 = length(uv - p3);
    float d4 = length(uv - p4);
    
    // Add noise-based distortion
    float noiseOffset = fbm(uv * complexity + time * 0.5, int(complexity));
    d1 += noiseOffset * 0.2;
    d2 += noiseOffset * 0.15;
    d3 -= noiseOffset * 0.15;
    d4 -= noiseOffset * 0.1;
    
    // Soft weighting (inverse distance with smoothing)
    float w1 = 1.0 / (d1 * d1 + 0.01);
    float w2 = 1.0 / (d2 * d2 + 0.01);
    float w3 = 1.0 / (d3 * d3 + 0.01);
    float w4 = 1.0 / (d4 * d4 + 0.01);
    
    float totalWeight = w1 + w2 + w3 + w4;
    
    // Blend colors
    vec3 color = (uColor1 * w1 + uColor2 * w2 + uColor3 * w3 + uColor4 * w4) / totalWeight;
    
    return color;
}

// ============================================
// Main
// ============================================

void main() {
    vec2 uv = vUv;
    float time = uTime * uSpeed;
    
    // Apply mouse influence - warp UV towards mouse
    vec2 mousePos = uMouse;
    vec2 toMouse = mousePos - uv;
    float mouseDist = length(toMouse);
    float mouseEffect = smoothstep(0.5, 0.0, mouseDist) * uMouseInfluence;
    uv += toMouse * mouseEffect * 0.2;
    
    // Scale UV
    vec2 scaledUv = (uv - 0.5) * uScale + 0.5;
    
    // Get base mesh gradient
    vec3 color = meshGradient(scaledUv, time, uComplexity);
    
    // Add subtle aurora-like streaks
    float streak = snoise(vec2(uv.x * 3.0 + time * 0.5, uv.y * 0.5));
    streak = pow(abs(streak), 2.0) * 0.3;
    
    vec3 streakColor = mix(uColor1, uColor3, snoise(vec2(time * 0.2, uv.y)));
    color = mix(color, color + streakColor * 0.3, streak);
    
    // Add glow around mouse
    float mouseGlow = smoothstep(0.3, 0.0, mouseDist) * uMouseInfluence;
    vec3 glowColor = mix(uColor2, uColor4, 0.5);
    color += glowColor * mouseGlow * 0.3;
    
    // Subtle vignette
    float vignette = 1.0 - length(vUv - 0.5) * 0.3;
    color *= vignette;
    
    // Tone mapping for rich colors
    color = pow(color, vec3(0.95));
    
    gl_FragColor = vec4(color, 1.0);
}
