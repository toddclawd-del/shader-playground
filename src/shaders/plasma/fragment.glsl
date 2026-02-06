/**
 * Classic Demoscene Plasma
 * 
 * A tribute to the demoscene plasma effects from the 80s/90s.
 * Uses sine wave composition to create flowing, psychedelic patterns.
 * 
 * Key techniques:
 * - Sine wave summation for pattern generation
 * - Distance-based rings (radial waves)
 * - Cosine color palettes (IQ technique)
 * - Time-based animation
 * 
 * References:
 * - Lode's Computer Graphics Tutorial: https://lodev.org/cgtutor/plasma.html
 * - Future Crew's Second Reality (1993)
 * - Inigo Quilez color palettes: https://iquilezles.org/articles/palettes/
 */

varying vec2 vUv;

uniform float uTime;
uniform float uScale;
uniform float uSpeed;
uniform float uWaveFrequency1;
uniform float uWaveFrequency2;
uniform float uWaveFrequency3;
uniform float uWaveFrequency4;
uniform float uDistortionAmount;
uniform float uColorCycles;
uniform float uColorSpeed;
uniform float uSaturation;
uniform float uBrightness;
uniform float uPatternStyle;
uniform float uColorStyle;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uColor3;
uniform vec3 uPaletteOffset;
uniform vec3 uPaletteAmp;
uniform vec3 uPaletteFreq;
uniform vec3 uPalettePhase;
uniform vec2 uCenter1;
uniform vec2 uCenter2;
uniform float uPulseAmount;
uniform float uVignetteStrength;

#define PI 3.14159265359
#define TAU 6.28318530718

// ========================================
// COSINE COLOR PALETTE (IQ Technique)
// ========================================
// Creates smooth, continuous color gradients
// color(t) = a + b * cos(2π * (c*t + d))
// where a = offset, b = amplitude, c = frequency, d = phase
vec3 cosinePalette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(TAU * (c * t + d));
}

// Preset palettes
vec3 paletteRainbow(float t) {
    // Classic rainbow that cycles smoothly
    return cosinePalette(t,
        vec3(0.5, 0.5, 0.5),    // offset (midpoint)
        vec3(0.5, 0.5, 0.5),    // amplitude
        vec3(1.0, 1.0, 1.0),    // frequency
        vec3(0.0, 0.33, 0.67)   // phase (R, G, B offset by 1/3)
    );
}

vec3 paletteNeon(float t) {
    // Vibrant neon (cyan, magenta, yellow)
    return cosinePalette(t,
        vec3(0.5, 0.5, 0.5),
        vec3(0.5, 0.5, 0.5),
        vec3(1.0, 1.0, 1.0),
        vec3(0.0, 0.1, 0.2)
    );
}

vec3 paletteFire(float t) {
    // Fire/lava colors
    return cosinePalette(t,
        vec3(0.5, 0.5, 0.5),
        vec3(0.5, 0.5, 0.5),
        vec3(1.0, 1.0, 0.5),
        vec3(0.0, 0.1, 0.2)
    );
}

vec3 paletteOcean(float t) {
    // Ocean/cool tones
    return cosinePalette(t,
        vec3(0.5, 0.5, 0.5),
        vec3(0.5, 0.5, 0.5),
        vec3(1.0, 0.7, 0.4),
        vec3(0.0, 0.15, 0.20)
    );
}

vec3 paletteAcid(float t) {
    // Acid/toxic green-purple
    return cosinePalette(t,
        vec3(0.5, 0.5, 0.5),
        vec3(0.5, 0.5, 0.5),
        vec3(2.0, 1.0, 0.0),
        vec3(0.5, 0.2, 0.25)
    );
}

vec3 paletteCustom(float t) {
    return cosinePalette(t, uPaletteOffset, uPaletteAmp, uPaletteFreq, uPalettePhase);
}

// HSV to RGB for alternative coloring
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// Three-color gradient interpolation
vec3 threeColorGradient(float t, vec3 c1, vec3 c2, vec3 c3) {
    t = fract(t);
    if (t < 0.5) {
        return mix(c1, c2, t * 2.0);
    } else {
        return mix(c2, c3, (t - 0.5) * 2.0);
    }
}

// ========================================
// PLASMA PATTERN GENERATORS
// ========================================

// Distance from a point
float dist(vec2 p, vec2 center) {
    vec2 d = p - center;
    return length(d);
}

// Classic plasma: sum of sine waves
float plasmaClassic(vec2 p, float time) {
    float v = 0.0;
    
    // Horizontal wave
    v += sin(p.x * uWaveFrequency1 + time);
    
    // Vertical wave  
    v += sin(p.y * uWaveFrequency2 + time * 0.7);
    
    // Diagonal wave
    v += sin((p.x + p.y) * uWaveFrequency3 + time * 1.3);
    
    // Radial wave from center 1
    v += sin(dist(p, uCenter1) * uWaveFrequency4 + time * 0.5);
    
    return v / 4.0; // Normalize to -1 to 1
}

// Complex plasma: more wave interactions
float plasmaComplex(vec2 p, float time) {
    float v = 0.0;
    
    // Multiple horizontal waves with phase offset
    v += sin(p.x * uWaveFrequency1 + time);
    v += sin((p.x + time * 0.5) * uWaveFrequency2 * 0.5);
    
    // Multiple vertical waves
    v += sin(p.y * uWaveFrequency2 + time * 1.2);
    v += sin((p.y - time * 0.3) * uWaveFrequency3 * 0.7);
    
    // Diagonal
    v += sin((p.x + p.y) * uWaveFrequency3 + time);
    v += sin((p.x - p.y) * uWaveFrequency1 * 0.5 - time * 0.7);
    
    // Two radial waves from different centers
    v += sin(dist(p, uCenter1) * uWaveFrequency4 + time);
    v += sin(dist(p, uCenter2) * uWaveFrequency4 * 0.8 - time * 0.5);
    
    return v / 8.0;
}

// Concentric rings
float plasmaRings(vec2 p, float time) {
    float v = 0.0;
    
    // Multiple ring sources
    v += sin(dist(p, uCenter1) * uWaveFrequency1 * 2.0 + time);
    v += sin(dist(p, uCenter2) * uWaveFrequency2 * 2.0 - time * 0.7);
    v += sin(dist(p, vec2(0.5)) * uWaveFrequency3 * 2.0 + time * 1.3);
    
    // Add some linear waves for variation
    v += sin(p.x * uWaveFrequency4 + p.y * uWaveFrequency4 * 0.5 + time);
    
    return v / 4.0;
}

// Cellular plasma (sharper edges)
float plasmaCellular(vec2 p, float time) {
    float v = 0.0;
    
    // Base waves
    v += sin(p.x * uWaveFrequency1 + time);
    v += sin(p.y * uWaveFrequency2 + time * 0.7);
    v += sin(dist(p, uCenter1) * uWaveFrequency3 + time);
    v += sin(dist(p, uCenter2) * uWaveFrequency4 - time * 0.5);
    
    v /= 4.0;
    
    // Quantize for cellular look
    v = floor(v * 8.0) / 8.0;
    
    return v;
}

// Turbulent plasma with distortion
float plasmaTurbulent(vec2 p, float time) {
    // Distort coordinates
    vec2 dp = p;
    dp.x += sin(p.y * 4.0 + time) * uDistortionAmount;
    dp.y += sin(p.x * 4.0 + time * 1.3) * uDistortionAmount;
    
    float v = 0.0;
    v += sin(dp.x * uWaveFrequency1 + time);
    v += sin(dp.y * uWaveFrequency2 + time * 0.8);
    v += sin((dp.x + dp.y) * uWaveFrequency3 * 0.5 + time * 1.2);
    v += sin(dist(dp, uCenter1) * uWaveFrequency4 + time * 0.6);
    
    return v / 4.0;
}

// ========================================
// MAIN
// ========================================

void main() {
    // Center UVs and apply scale
    vec2 uv = (vUv - 0.5) * uScale + 0.5;
    
    // Time with speed control
    float time = uTime * uSpeed;
    
    // Calculate plasma value based on pattern style
    float plasma = 0.0;
    int patternStyle = int(uPatternStyle);
    
    if (patternStyle == 0) {
        plasma = plasmaClassic(uv, time);
    } else if (patternStyle == 1) {
        plasma = plasmaComplex(uv, time);
    } else if (patternStyle == 2) {
        plasma = plasmaRings(uv, time);
    } else if (patternStyle == 3) {
        plasma = plasmaCellular(uv, time);
    } else {
        plasma = plasmaTurbulent(uv, time);
    }
    
    // Apply pulse effect (breathing)
    float pulse = 1.0 + sin(time * 2.0) * uPulseAmount;
    plasma *= pulse;
    
    // Map plasma value to color
    // Normalize from [-1, 1] to [0, 1] and apply color cycles
    float t = (plasma * 0.5 + 0.5) * uColorCycles + time * uColorSpeed;
    
    vec3 color;
    int colorStyle = int(uColorStyle);
    
    if (colorStyle == 0) {
        color = paletteRainbow(t);
    } else if (colorStyle == 1) {
        color = paletteNeon(t);
    } else if (colorStyle == 2) {
        color = paletteFire(t);
    } else if (colorStyle == 3) {
        color = paletteOcean(t);
    } else if (colorStyle == 4) {
        color = paletteAcid(t);
    } else if (colorStyle == 5) {
        // HSV rainbow
        color = hsv2rgb(vec3(t, uSaturation, uBrightness));
    } else if (colorStyle == 6) {
        // Three-color gradient using custom colors
        color = threeColorGradient(t, uColor1, uColor2, uColor3);
    } else {
        // Custom cosine palette
        color = paletteCustom(t);
    }
    
    // Apply saturation adjustment (for cosine palettes)
    if (colorStyle < 5 || colorStyle == 7) {
        vec3 grey = vec3(dot(color, vec3(0.299, 0.587, 0.114)));
        color = mix(grey, color, uSaturation);
        color *= uBrightness;
    }
    
    // Vignette
    vec2 vigUv = vUv * 2.0 - 1.0;
    float vignette = 1.0 - dot(vigUv, vigUv) * uVignetteStrength;
    color *= vignette;
    
    // Ensure color stays in valid range
    color = clamp(color, 0.0, 1.0);
    
    gl_FragColor = vec4(color, 1.0);
}
