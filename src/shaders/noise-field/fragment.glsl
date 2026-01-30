// ============================================
// Noise Field Shader
// Visualizes different noise algorithms:
// - Perlin: classic smooth noise
// - Simplex: faster, fewer artifacts
// - Worley: cellular/voronoi-based noise
//
// Uses FBM (Fractal Brownian Motion) for detail
// ============================================

precision highp float;

varying vec2 vUv;

uniform float uTime;
uniform float uNoiseType; // 0=perlin, 1=simplex, 2=worley
uniform float uOctaves;
uniform float uFrequency;
uniform float uAmplitude;
uniform float uSpeed;
uniform float uColorMode; // 0=grayscale, 1=gradient, 2=heatmap
uniform vec2 uMouse;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uBackgroundColor;

#define PI 3.14159265359

// ============================================
// Hash Functions
// ============================================

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

vec2 hash2(vec2 p) {
    return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453);
}

// ============================================
// Perlin Noise
// ============================================

vec2 fade(vec2 t) {
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

float perlinNoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    
    vec2 u = fade(f);
    
    float n00 = dot(hash2(i) * 2.0 - 1.0, f);
    float n10 = dot(hash2(i + vec2(1.0, 0.0)) * 2.0 - 1.0, f - vec2(1.0, 0.0));
    float n01 = dot(hash2(i + vec2(0.0, 1.0)) * 2.0 - 1.0, f - vec2(0.0, 1.0));
    float n11 = dot(hash2(i + vec2(1.0, 1.0)) * 2.0 - 1.0, f - vec2(1.0, 1.0));
    
    return mix(mix(n00, n10, u.x), mix(n01, n11, u.x), u.y) * 0.5 + 0.5;
}

// ============================================
// Simplex Noise
// ============================================

vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec2 mod289(vec2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec3 permute(vec3 x) { return mod289(((x * 34.0) + 1.0) * x); }

float simplexNoise(vec2 v) {
    const vec4 C = vec4(0.211324865405187, 0.366025403784439,
                       -0.577350269189626, 0.024390243902439);
    vec2 i = floor(v + dot(v, C.yy));
    vec2 x0 = v - i + dot(i, C.xx);
    vec2 i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    i = mod289(i);
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
    return 0.5 + 0.5 * 130.0 * dot(m, g);
}

// ============================================
// Worley Noise (Cellular)
// ============================================

float worleyNoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    
    float minDist = 1.0;
    float secondMinDist = 1.0;
    
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 neighbor = vec2(float(x), float(y));
            vec2 point = hash2(i + neighbor);
            
            // Animate points
            point = 0.5 + 0.5 * sin(uTime * uSpeed * 0.5 + 6.2831 * point);
            
            vec2 diff = neighbor + point - f;
            float dist = length(diff);
            
            if (dist < minDist) {
                secondMinDist = minDist;
                minDist = dist;
            } else if (dist < secondMinDist) {
                secondMinDist = dist;
            }
        }
    }
    
    // Return F1 (distance to closest) - can also use F2-F1 for cell edges
    return minDist;
}

// ============================================
// FBM (Fractal Brownian Motion)
// ============================================

float fbm(vec2 p, int octaves, int noiseType) {
    float value = 0.0;
    float amplitude = uAmplitude;
    float frequency = 1.0;
    float maxValue = 0.0;
    
    for (int i = 0; i < 8; i++) {
        if (i >= octaves) break;
        
        float n;
        vec2 np = p * frequency + uTime * uSpeed * 0.1;
        
        if (noiseType == 0) {
            n = perlinNoise(np);
        } else if (noiseType == 1) {
            n = simplexNoise(np);
        } else {
            n = worleyNoise(np);
        }
        
        value += amplitude * n;
        maxValue += amplitude;
        frequency *= 2.0;
        amplitude *= 0.5;
    }
    
    return value / maxValue;
}

// ============================================
// Color Mapping
// ============================================

vec3 grayscaleColor(float n) {
    return vec3(n);
}

vec3 gradientColor(float n) {
    return mix(uColor1, uColor2, n);
}

vec3 heatmapColor(float n) {
    // Cold (blue) to hot (red) via yellow
    vec3 cold = vec3(0.0, 0.0, 1.0);
    vec3 mid1 = vec3(0.0, 1.0, 1.0);
    vec3 mid2 = vec3(0.0, 1.0, 0.0);
    vec3 mid3 = vec3(1.0, 1.0, 0.0);
    vec3 hot = vec3(1.0, 0.0, 0.0);
    
    if (n < 0.25) {
        return mix(cold, mid1, n * 4.0);
    } else if (n < 0.5) {
        return mix(mid1, mid2, (n - 0.25) * 4.0);
    } else if (n < 0.75) {
        return mix(mid2, mid3, (n - 0.5) * 4.0);
    } else {
        return mix(mid3, hot, (n - 0.75) * 4.0);
    }
}

// ============================================
// Main
// ============================================

void main() {
    vec2 uv = vUv;
    
    // Scale UV by frequency
    vec2 p = uv * uFrequency;
    
    // Add mouse influence - warp towards mouse
    vec2 toMouse = uMouse - uv;
    float mouseDist = length(toMouse);
    float mouseInfluence = smoothstep(0.3, 0.0, mouseDist);
    p += toMouse * mouseInfluence * 2.0;
    
    // Get noise type
    int noiseType = int(uNoiseType + 0.5);
    int octaves = int(uOctaves);
    
    // Generate noise
    float n = fbm(p, octaves, noiseType);
    
    // Apply color mode
    int colorMode = int(uColorMode + 0.5);
    vec3 color;
    
    if (colorMode == 0) {
        color = grayscaleColor(n);
    } else if (colorMode == 1) {
        color = gradientColor(n);
    } else {
        color = heatmapColor(n);
    }
    
    // Add mouse glow
    float mouseGlow = smoothstep(0.2, 0.0, mouseDist);
    color += mix(uColor1, uColor2, 0.5) * mouseGlow * 0.2;
    
    // Mix with background for edges
    float edge = smoothstep(0.0, 0.1, min(uv.x, min(uv.y, min(1.0 - uv.x, 1.0 - uv.y))));
    color = mix(uBackgroundColor, color, edge);
    
    gl_FragColor = vec4(color, 1.0);
}
