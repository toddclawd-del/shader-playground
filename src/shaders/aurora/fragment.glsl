varying vec2 vUv;

uniform float uTime;
uniform float uLayers;
uniform float uFlowSpeed;
uniform float uDistortion;
uniform float uIntensity;
uniform float uVerticalStretch;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uColor3;
uniform vec3 uBackgroundColor;

#define PI 3.14159265

// ============================================
// Noise Functions
// ============================================

float hash(float n) {
    return fract(sin(n) * 43758.5453);
}

float hash2(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);

    float a = hash2(i);
    float b = hash2(i + vec2(1.0, 0.0));
    float c = hash2(i + vec2(0.0, 1.0));
    float d = hash2(i + vec2(1.0, 1.0));

    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p, int octaves) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;

    for (int i = 0; i < 8; i++) {
        if (i >= octaves) break;
        value += amplitude * noise(p * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }

    return value;
}

// ============================================
// Aurora Functions
// ============================================

// Single aurora band
float auroraBand(vec2 uv, float offset, float time, float layer) {
    // Horizontal flow
    float flow = time * uFlowSpeed * (0.8 + layer * 0.2);

    // Create wavy vertical position
    float waveFreq = 3.0 + layer * 0.5;
    float wave = sin(uv.x * waveFreq + flow + offset) * 0.15;
    wave += sin(uv.x * waveFreq * 1.7 + flow * 0.7 + offset * 2.0) * 0.1;
    wave += sin(uv.x * waveFreq * 2.3 + flow * 1.3 - offset) * 0.05;

    // Add noise-based distortion
    float noiseDistort = fbm(vec2(uv.x * 2.0 + flow * 0.3, layer), 3) * uDistortion * 0.2;
    wave += noiseDistort;

    // Vertical position of the band
    float bandY = 0.5 + offset * 0.3 + wave;

    // Band shape with vertical stretch
    float bandDist = abs(uv.y - bandY);
    float bandWidth = 0.15 + fbm(vec2(uv.x * 4.0 + flow, offset), 2) * 0.1;
    bandWidth *= uVerticalStretch;

    // Soft band edges
    float band = smoothstep(bandWidth, 0.0, bandDist);

    // Add vertical streaks (aurora curtain effect)
    float streakFreq = 30.0 + layer * 10.0;
    float streak = sin(uv.x * streakFreq + flow * 2.0 + noise(uv * 10.0 + time) * 5.0);
    streak = pow(streak * 0.5 + 0.5, 3.0);

    // Vertical fade (stronger at top of band)
    float vertFade = smoothstep(bandY - bandWidth, bandY + bandWidth * 0.5, uv.y);
    vertFade *= smoothstep(1.0, bandY + bandWidth, uv.y);

    // Combine
    float aurora = band * (0.5 + streak * 0.5) * vertFade;

    // Add shimmer
    float shimmer = noise(vec2(uv.x * 50.0 + time * 3.0, uv.y * 20.0));
    aurora *= 0.8 + shimmer * 0.4;

    return aurora * uIntensity;
}

// Color palette interpolation
vec3 auroraColor(float t, float layer) {
    // Create smooth color transitions
    t = fract(t + layer * 0.2);

    vec3 col;
    if (t < 0.33) {
        col = mix(uColor1, uColor2, t * 3.0);
    } else if (t < 0.66) {
        col = mix(uColor2, uColor3, (t - 0.33) * 3.0);
    } else {
        col = mix(uColor3, uColor1, (t - 0.66) * 3.0);
    }

    return col;
}

// ============================================
// Main
// ============================================

void main() {
    vec2 uv = vUv;
    float time = uTime;

    // Background gradient (dark sky)
    vec3 color = mix(uBackgroundColor, uBackgroundColor * 0.5, uv.y);

    // Add subtle stars
    float stars = hash2(floor(uv * 200.0));
    stars = pow(stars, 20.0) * (0.5 + 0.5 * sin(time * 2.0 + stars * 100.0));
    color += vec3(stars) * 0.5;

    // Render aurora layers
    int layerCount = int(uLayers);
    for (int i = 0; i < 5; i++) {
        if (i >= layerCount) break;

        float layer = float(i) / float(layerCount);

        // Offset each layer
        float layerOffset = (layer - 0.5) * 0.5;
        layerOffset += sin(time * 0.2 + layer * PI) * 0.1;

        // Get band intensity
        float band = auroraBand(uv, layerOffset, time, layer);

        // Color varies along the band and between layers
        float colorT = uv.x * 0.5 + time * 0.1 + layer * 0.3;
        vec3 auroraCol = auroraColor(colorT, layer);

        // Add color variation based on position
        float posVar = fbm(uv * 3.0 + time * 0.2, 2);
        auroraCol = mix(auroraCol, auroraColor(colorT + 0.3, layer), posVar * 0.5);

        // Accumulate with additive blending
        color += auroraCol * band * (1.0 - layer * 0.2);
    }

    // Add glow around bright areas
    float glowIntensity = length(color - uBackgroundColor);
    vec3 glow = mix(uColor1, uColor2, 0.5) * glowIntensity * 0.1;
    color += glow;

    // Subtle vignette
    float vignette = 1.0 - length(uv - 0.5) * 0.3;
    color *= vignette;

    // Tone mapping
    color = color / (color + vec3(1.0));

    gl_FragColor = vec4(color, 1.0);
}
