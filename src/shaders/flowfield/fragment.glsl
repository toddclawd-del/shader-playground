varying vec2 vUv;

uniform float uTime;
uniform float uNoiseScale;
uniform float uNoiseSpeed;
uniform float uMouseForce;
uniform float uTrailLength;
uniform float uParticleDensity;
uniform float uParticleSize;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uBackgroundColor;
uniform float uColorMix;

// Mouse uniforms (auto-injected)
uniform vec2 uMouse;
uniform vec2 uMouseVelocity;
uniform float uMouseDown;

#define PI 3.14159265

// ============================================
// Noise Functions
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

// Curl noise for flow field (fast approximation)
vec2 curlNoise(vec2 p, float t) {
    float n1 = noise(p + vec2(0.0, 0.01) + t);
    float n2 = noise(p - vec2(0.0, 0.01) + t);
    float n3 = noise(p + vec2(0.01, 0.0) + t);
    float n4 = noise(p - vec2(0.01, 0.0) + t);

    return vec2(n1 - n2, -(n3 - n4)) * 50.0;
}

// FBM for texture
float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    for (int i = 0; i < 4; i++) {
        value += amplitude * noise(p);
        p *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

// ============================================
// Main - Simplified flow visualization
// ============================================

void main() {
    vec2 uv = vUv;
    float time = uTime * uNoiseSpeed;

    // Background
    vec3 color = uBackgroundColor;

    // Get flow direction at this point
    vec2 flow = curlNoise(uv * uNoiseScale, time);

    // Mouse influence
    vec2 toMouse = uMouse - uv;
    float mouseDist = length(toMouse);
    float mouseInfluence = uMouseForce / (mouseDist * 5.0 + 0.5);
    if (uMouseDown > 0.5) mouseInfluence *= 2.0;
    flow += normalize(toMouse + 0.001) * mouseInfluence;

    // Create flowing line pattern
    float linePattern = 0.0;

    // Multiple offset layers for depth
    for (int i = 0; i < 3; i++) {
        float layer = float(i);
        float layerOffset = layer * 0.33;

        // Trace UV backwards along flow
        vec2 tracedUv = uv;
        for (int j = 0; j < 8; j++) {
            vec2 localFlow = curlNoise(tracedUv * uNoiseScale, time + layerOffset);

            // Mouse influence on traced point
            vec2 toMouseLocal = uMouse - tracedUv;
            float mouseDistLocal = length(toMouseLocal);
            localFlow += normalize(toMouseLocal + 0.001) * uMouseForce / (mouseDistLocal * 5.0 + 0.5);

            tracedUv -= localFlow * 0.003 * uTrailLength;
        }

        // Create particles along the flow
        vec2 gridUv = tracedUv * uParticleDensity;
        vec2 gridId = floor(gridUv);
        vec2 gridFract = fract(gridUv) - 0.5;

        // Particle position with random offset
        float cellHash = hash(gridId + layer * 100.0);
        vec2 particleOffset = vec2(hash(gridId * 1.1), hash(gridId * 2.3)) - 0.5;
        particleOffset *= 0.8;

        // Distance to particle
        float dist = length(gridFract - particleOffset);
        float particle = smoothstep(uParticleSize, 0.0, dist);

        // Trail fade based on layer
        particle *= (1.0 - layer * 0.25);

        linePattern += particle;

        // Color variation
        float colorVar = cellHash;
        vec3 particleCol = mix(uColor1, uColor2, colorVar * uColorMix);
        color += particleCol * particle * 0.5;
    }

    // Flow visualization (subtle background)
    float flowVis = fbm(uv * uNoiseScale * 2.0 + time);
    color += mix(uColor1, uColor2, flowVis) * 0.05;

    // Mouse glow
    float mouseGlow = smoothstep(0.3, 0.0, mouseDist) * uMouseForce * 0.3;
    color += mix(uColor1, uColor2, 0.5) * mouseGlow;

    // Vignette
    float vignette = 1.0 - length(uv - 0.5) * 0.4;
    color *= vignette;

    // Clamp to prevent oversaturation
    color = clamp(color, 0.0, 1.0);

    gl_FragColor = vec4(color, 1.0);
}
