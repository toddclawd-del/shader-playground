varying vec2 vUv;

uniform float uTime;
uniform float uBlur;
uniform float uRefraction;
uniform float uChromaticAberration;
uniform float uFrost;
uniform float uFrostScale;
uniform vec3 uTint;
uniform float uTintStrength;
uniform float uOpacity;
uniform float uReflection;
uniform float uDistortSpeed;
uniform float uEdgeGlow;
uniform vec3 uEdgeColor;
uniform vec3 uColor1;
uniform vec3 uColor2;

// ============================================
// Fast noise (no loops)
// ============================================

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    return mix(
        mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
        mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x),
        f.y
    );
}

// Simplified FBM - only 3 octaves, unrolled
float fbm3(vec2 p) {
    float v = 0.0;
    v += 0.5 * noise(p); p *= 2.0;
    v += 0.25 * noise(p); p *= 2.0;
    v += 0.125 * noise(p);
    return v;
}

// ============================================
// Background generation (no blur loops)
// ============================================

vec3 generateBackground(vec2 uv, float time) {
    // Simple animated gradient background
    float n = fbm3(uv * 3.0 + time * 0.1);
    
    vec3 bg = mix(uColor1, uColor2, n);
    
    // Add subtle movement
    bg += vec3(
        sin(uv.x * 10.0 + time) * 0.03,
        cos(uv.y * 8.0 + time * 0.7) * 0.03,
        sin((uv.x + uv.y) * 6.0 + time * 0.5) * 0.03
    );
    
    return bg;
}

// ============================================
// Main
// ============================================

void main() {
    vec2 uv = vUv;
    vec2 centeredUv = uv - 0.5;
    float time = uTime;
    
    // ---- Frost distortion (simplified) ----
    vec2 distortedUv = uv;
    if (uFrost > 0.0) {
        float frostNoise = fbm3(uv * uFrostScale + time * uDistortSpeed * 0.2);
        distortedUv += (frostNoise - 0.5) * uFrost * 0.15;
    }
    
    // ---- Refraction distortion ----
    if (uRefraction > 0.0) {
        float dist = length(centeredUv);
        vec2 dir = centeredUv / (dist + 0.001);
        float refractAmount = dist * dist * uRefraction * 0.5;
        distortedUv += dir * refractAmount;
        
        // Animated wave
        distortedUv += vec2(
            sin(uv.y * 20.0 + time * uDistortSpeed),
            cos(uv.x * 20.0 + time * uDistortSpeed)
        ) * 0.01 * uRefraction;
    }
    
    // ---- Simple blur via UV jitter (no loops) ----
    vec2 blurOffset = vec2(
        noise(distortedUv * 50.0 + time),
        noise(distortedUv * 50.0 + time + 100.0)
    ) - 0.5;
    vec2 blurredUv = distortedUv + blurOffset * uBlur * 0.02;
    
    // ---- Generate color ----
    vec3 color;
    if (uChromaticAberration > 0.0) {
        float caAmount = uChromaticAberration * 0.015;
        vec2 caDir = centeredUv / (length(centeredUv) + 0.001);
        
        vec3 colorR = generateBackground(blurredUv + caDir * caAmount, time);
        vec3 colorG = generateBackground(blurredUv, time);
        vec3 colorB = generateBackground(blurredUv - caDir * caAmount, time);
        
        color = vec3(colorR.r, colorG.g, colorB.b);
    } else {
        color = generateBackground(blurredUv, time);
    }
    
    // ---- Frost overlay ----
    if (uFrost > 0.0) {
        float frost = fbm3(uv * uFrostScale * 2.0);
        frost = frost * frost;
        color = mix(color, vec3(0.95), frost * uFrost * 0.4);
    }
    
    // ---- Reflection (simplified) ----
    if (uReflection > 0.0) {
        float fresnel = length(centeredUv) * 2.0;
        fresnel = fresnel * fresnel;
        fresnel = min(fresnel, 1.0);
        
        float reflection = noise(uv * 5.0 + time * 0.3);
        reflection = reflection * reflection * reflection;
        
        color += vec3(1.0) * reflection * uReflection * 0.3;
        color += vec3(0.85, 0.9, 1.0) * fresnel * uReflection * 0.25;
    }
    
    // ---- Edge glow ----
    if (uEdgeGlow > 0.0) {
        float edge = length(centeredUv) * 2.0;
        edge = smoothstep(0.3, 1.0, edge);
        color += uEdgeColor * edge * uEdgeGlow;
    }
    
    // ---- Tint ----
    color = mix(color, color * uTint, uTintStrength);
    
    // ---- Opacity with inner glow ----
    float alpha = uOpacity;
    float innerGlow = max(0.0, 1.0 - length(centeredUv) * 1.5);
    alpha += innerGlow * 0.1;
    
    gl_FragColor = vec4(color, alpha);
}
