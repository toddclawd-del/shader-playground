varying vec2 vUv;

uniform float uTime;
uniform vec2 uMouse;
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

// ============================================
// Noise for frost effect
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

float fbm(vec2 p, int octaves) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    
    for (int i = 0; i < 6; i++) {
        if (i >= octaves) break;
        value += amplitude * noise(p * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }
    
    return value;
}

// ============================================
// Blur simulation (box blur approximation)
// ============================================

vec3 sampleBlurred(vec2 uv, float blur) {
    vec3 color = vec3(0.0);
    float total = 0.0;
    
    // Sample in a pattern around the point
    for (float x = -2.0; x <= 2.0; x += 1.0) {
        for (float y = -2.0; y <= 2.0; y += 1.0) {
            vec2 offset = vec2(x, y) * blur * 0.01;
            
            // Create a fake "background" using gradients and noise
            vec2 sampleUv = uv + offset;
            float n = fbm(sampleUv * 3.0 + uTime * 0.1, 4);
            vec3 bg = mix(
                vec3(0.1, 0.1, 0.15),
                vec3(0.2, 0.25, 0.3),
                n
            );
            
            // Add some color variation
            bg += vec3(
                sin(sampleUv.x * 10.0 + uTime) * 0.05,
                cos(sampleUv.y * 8.0 + uTime * 0.7) * 0.05,
                sin((sampleUv.x + sampleUv.y) * 6.0) * 0.05
            );
            
            float weight = 1.0 - length(vec2(x, y)) / 3.0;
            color += bg * weight;
            total += weight;
        }
    }
    
    return color / total;
}

// ============================================
// Main
// ============================================

void main() {
    vec2 uv = vUv;
    vec2 centeredUv = uv - 0.5;
    
    // ---- Frost distortion ----
    float frostNoise = 0.0;
    if (uFrost > 0.0) {
        frostNoise = fbm(uv * uFrostScale + uTime * uDistortSpeed * 0.2, 4);
        frostNoise = (frostNoise - 0.5) * 2.0 * uFrost * 0.1;
    }
    
    // ---- Refraction distortion ----
    vec2 refractOffset = vec2(0.0);
    if (uRefraction > 0.0) {
        // Lens-like refraction from center
        float dist = length(centeredUv);
        vec2 dir = normalize(centeredUv + 0.001);
        float refractAmount = pow(dist, 2.0) * uRefraction * 0.5;
        refractOffset = dir * refractAmount;
        
        // Add animated wave distortion
        refractOffset += vec2(
            sin(uv.y * 20.0 + uTime * uDistortSpeed) * 0.01,
            cos(uv.x * 20.0 + uTime * uDistortSpeed) * 0.01
        ) * uRefraction;
    }
    
    // Combined distortion
    vec2 distortedUv = uv + refractOffset + frostNoise;
    
    // ---- Chromatic aberration ----
    vec3 color;
    if (uChromaticAberration > 0.0) {
        float caAmount = uChromaticAberration * 0.02;
        vec2 caDir = normalize(centeredUv + 0.001);
        
        vec3 colorR = sampleBlurred(distortedUv + caDir * caAmount, uBlur);
        vec3 colorG = sampleBlurred(distortedUv, uBlur);
        vec3 colorB = sampleBlurred(distortedUv - caDir * caAmount, uBlur);
        
        color = vec3(colorR.r, colorG.g, colorB.b);
    } else {
        color = sampleBlurred(distortedUv, uBlur);
    }
    
    // ---- Frost overlay ----
    if (uFrost > 0.0) {
        float frost = fbm(uv * uFrostScale * 2.0, 5);
        frost = pow(frost, 1.5);
        color = mix(color, vec3(0.9, 0.95, 1.0), frost * uFrost * 0.3);
    }
    
    // ---- Reflection (fake specular) ----
    if (uReflection > 0.0) {
        vec2 reflectUv = uv;
        reflectUv.y = 1.0 - reflectUv.y;
        
        float reflection = fbm(reflectUv * 5.0 + uTime * 0.1, 3);
        reflection = pow(reflection, 3.0);
        
        // Fresnel-like edge reflection
        float fresnel = pow(length(centeredUv) * 1.5, 2.0);
        fresnel = clamp(fresnel, 0.0, 1.0);
        
        color += vec3(1.0) * reflection * uReflection * 0.3;
        color += vec3(0.8, 0.9, 1.0) * fresnel * uReflection * 0.2;
    }
    
    // ---- Edge glow ----
    if (uEdgeGlow > 0.0) {
        float edge = length(centeredUv) * 2.0;
        edge = smoothstep(0.3, 1.0, edge);
        color += uEdgeColor * edge * uEdgeGlow;
    }
    
    // ---- Tint ----
    color = mix(color, color * uTint, uTintStrength);
    
    // ---- Final opacity ----
    float alpha = uOpacity;
    
    // Add subtle inner glow
    float innerGlow = 1.0 - length(centeredUv) * 1.5;
    innerGlow = max(0.0, innerGlow);
    alpha += innerGlow * 0.1;
    
    gl_FragColor = vec4(color, alpha);
}
