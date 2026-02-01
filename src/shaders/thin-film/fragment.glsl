varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;

uniform float uTime;
uniform float uThicknessMin;       // Minimum film thickness (nanometers)
uniform float uThicknessMax;       // Maximum film thickness (nanometers)
uniform float uThicknessVariation; // How much thickness varies across surface
uniform float uN1;                 // Refractive index of air (or outer medium)
uniform float uN2;                 // Refractive index of film (soap ≈ 1.33, oil ≈ 1.5)
uniform float uN3;                 // Refractive index of substrate
uniform float uAnimSpeed;          // Animation speed
uniform float uSwirl;              // Swirl/flow intensity
uniform float uColorIntensity;     // Intensity of iridescent effect
uniform vec3 uBaseColor;           // Base/background color
uniform float uFresnelStrength;    // Fresnel rim effect strength
uniform int uVisualization;        // 0=soap bubble, 1=oil slick, 2=abstract
uniform float uNoiseScale;         // Scale of thickness noise

#define PI 3.14159265359

// ============================================================
// SPECTRAL TO RGB CONVERSION
// Based on Alan Zucconi's spectral_zucconi6 approximation
// Maps wavelength (380-780nm) to visible RGB color
// ============================================================
vec3 spectralZucconi6(float wavelength) {
    // Attempt to map wavelength to RGB
    // Uses polynomial fits to CIE color matching functions
    float x = (wavelength - 380.0) / 400.0;  // Normalize to 0-1 range
    
    // Three overlapping Gaussian-like curves for R, G, B
    float r = smoothstep(0.0, 0.35, x) - smoothstep(0.35, 0.75, x) * 0.5 + smoothstep(0.7, 1.0, x) * 0.9;
    float g = smoothstep(0.0, 0.5, x) * smoothstep(1.0, 0.5, x) * 1.5;
    float b = 1.0 - smoothstep(0.0, 0.5, x);
    
    // Better approximation using bump functions
    vec3 color;
    color.r = 1.0 / (1.0 + exp(-15.0 * (x - 0.75))) + 
              exp(-pow((x - 0.1) * 5.0, 2.0));
    color.g = exp(-pow((x - 0.5) * 4.0, 2.0));
    color.b = exp(-pow((x - 0.2) * 6.0, 2.0));
    
    return clamp(color, 0.0, 1.0);
}

// Wavelength to RGB using classic approximation (more physically accurate)
vec3 wavelengthToRGB(float wavelength) {
    // wavelength in nanometers (380-780)
    float r = 0.0, g = 0.0, b = 0.0;
    
    if (wavelength >= 380.0 && wavelength < 440.0) {
        r = -(wavelength - 440.0) / (440.0 - 380.0);
        g = 0.0;
        b = 1.0;
    } else if (wavelength >= 440.0 && wavelength < 490.0) {
        r = 0.0;
        g = (wavelength - 440.0) / (490.0 - 440.0);
        b = 1.0;
    } else if (wavelength >= 490.0 && wavelength < 510.0) {
        r = 0.0;
        g = 1.0;
        b = -(wavelength - 510.0) / (510.0 - 490.0);
    } else if (wavelength >= 510.0 && wavelength < 580.0) {
        r = (wavelength - 510.0) / (580.0 - 510.0);
        g = 1.0;
        b = 0.0;
    } else if (wavelength >= 580.0 && wavelength < 645.0) {
        r = 1.0;
        g = -(wavelength - 645.0) / (645.0 - 580.0);
        b = 0.0;
    } else if (wavelength >= 645.0 && wavelength <= 780.0) {
        r = 1.0;
        g = 0.0;
        b = 0.0;
    }
    
    // Intensity falloff at edges of visible spectrum
    float factor;
    if (wavelength >= 380.0 && wavelength < 420.0) {
        factor = 0.3 + 0.7 * (wavelength - 380.0) / (420.0 - 380.0);
    } else if (wavelength >= 420.0 && wavelength <= 700.0) {
        factor = 1.0;
    } else if (wavelength > 700.0 && wavelength <= 780.0) {
        factor = 0.3 + 0.7 * (780.0 - wavelength) / (780.0 - 700.0);
    } else {
        factor = 0.0;
    }
    
    return vec3(r, g, b) * factor;
}

// ============================================================
// NOISE FUNCTIONS
// For creating organic thickness variation
// ============================================================
float hash21(vec2 p) {
    p = fract(p * vec2(234.34, 435.345));
    p += dot(p, p + 34.23);
    return fract(p.x * p.y);
}

float noise2D(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    
    float a = hash21(i);
    float b = hash21(i + vec2(1.0, 0.0));
    float c = hash21(i + vec2(0.0, 1.0));
    float d = hash21(i + vec2(1.0, 1.0));
    
    vec2 u = f * f * (3.0 - 2.0 * f);
    
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm(vec2 p, int octaves) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    
    for (int i = 0; i < 6; i++) {
        if (i >= octaves) break;
        value += amplitude * noise2D(p * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }
    
    return value;
}

// ============================================================
// THIN-FILM INTERFERENCE PHYSICS
// ============================================================

// Calculate optical path difference
// Returns the OPD in nanometers
float opticalPathDifference(float thickness, float n2, float cosTheta2) {
    // OPD = 2 * n2 * d * cos(theta2)
    // where theta2 is the refraction angle inside the film
    return 2.0 * n2 * thickness * cosTheta2;
}

// Calculate refraction angle using Snell's law
// Returns cos(theta2) directly since we use it more than the angle itself
float snellCosTheta2(float n1, float n2, float cosTheta1) {
    float sinTheta1 = sqrt(1.0 - cosTheta1 * cosTheta1);
    float sinTheta2 = (n1 / n2) * sinTheta1;
    
    // Check for total internal reflection
    if (sinTheta2 > 1.0) return 0.0;
    
    return sqrt(1.0 - sinTheta2 * sinTheta2);
}

// Calculate phase shift from reflection
// Returns 0.0 or 0.5 (half wavelength shift)
float phaseShift(float n1, float n2) {
    // Phase shift of PI occurs when reflecting from higher refractive index
    return n1 < n2 ? 0.5 : 0.0;
}

// Calculate reflectance for a single wavelength using thin-film interference
float thinFilmReflectance(float wavelength, float thickness, float cosTheta1, 
                          float n1, float n2, float n3) {
    // Calculate refraction angle
    float cosTheta2 = snellCosTheta2(n1, n2, cosTheta1);
    
    // Calculate optical path difference
    float opd = opticalPathDifference(thickness, n2, cosTheta2);
    
    // Phase shifts at interfaces
    float shift1 = phaseShift(n1, n2);  // Air to film
    float shift2 = phaseShift(n2, n3);  // Film to substrate
    float totalShift = shift1 + shift2;
    
    // If both shifts or neither, they cancel out
    // If only one, we have a net half-wavelength shift
    float phaseOffset = fract(totalShift) * PI;
    
    // Calculate interference phase
    // phi = (2π / λ) * OPD + phase_offset
    float phi = (2.0 * PI / wavelength) * opd + phaseOffset;
    
    // Interference intensity (simplified model)
    // Constructive when cos(phi) = 1, destructive when cos(phi) = -1
    float interference = 0.5 * (1.0 + cos(phi));
    
    // Apply Fresnel-like falloff
    // More reflection at grazing angles
    float fresnel = pow(1.0 - cosTheta1, 3.0);
    
    return mix(interference * 0.8, interference, fresnel);
}

// Calculate full thin-film color by sampling multiple wavelengths
vec3 thinFilmColor(float thickness, float cosTheta1, float n1, float n2, float n3) {
    vec3 color = vec3(0.0);
    
    // Sample across visible spectrum (380-780nm)
    // More samples = more accurate but slower
    const int SAMPLES = 16;
    float wavelengthStart = 380.0;
    float wavelengthEnd = 780.0;
    float wavelengthStep = (wavelengthEnd - wavelengthStart) / float(SAMPLES);
    
    for (int i = 0; i < SAMPLES; i++) {
        float wavelength = wavelengthStart + float(i) * wavelengthStep;
        float reflectance = thinFilmReflectance(wavelength, thickness, cosTheta1, n1, n2, n3);
        vec3 spectralColor = wavelengthToRGB(wavelength);
        color += spectralColor * reflectance;
    }
    
    return color / float(SAMPLES) * 2.5; // Normalize and boost
}

// Simplified 3-sample approach (faster)
vec3 thinFilmColorFast(float thickness, float cosTheta1, float n1, float n2, float n3) {
    // Sample at red, green, blue wavelengths
    float rReflect = thinFilmReflectance(650.0, thickness, cosTheta1, n1, n2, n3);
    float gReflect = thinFilmReflectance(510.0, thickness, cosTheta1, n1, n2, n3);
    float bReflect = thinFilmReflectance(475.0, thickness, cosTheta1, n1, n2, n3);
    
    return vec3(rReflect, gReflect, bReflect);
}

// ============================================================
// THICKNESS PATTERNS
// Different ways to vary thickness across the surface
// ============================================================

// Soap bubble pattern - thin at top, thick at bottom with swirls
float soapBubbleThickness(vec2 uv, float time) {
    // Gravity effect - thicker at bottom
    float gravity = uv.y * 0.6;
    
    // Swirling flow patterns
    vec2 flowUv = uv;
    flowUv.x += sin(uv.y * 5.0 + time * 0.5) * 0.1 * uSwirl;
    flowUv.y += cos(uv.x * 4.0 + time * 0.3) * 0.08 * uSwirl;
    
    // Organic noise
    float noise = fbm(flowUv * uNoiseScale + time * 0.1, 4);
    
    return gravity + noise * uThicknessVariation;
}

// Oil slick pattern - pooling with circular ripples
float oilSlickThickness(vec2 uv, float time) {
    vec2 center = vec2(0.5);
    float dist = length(uv - center);
    
    // Pooling effect - thicker toward center
    float pooling = 1.0 - smoothstep(0.0, 0.8, dist);
    
    // Interference rings
    float rings = sin(dist * 20.0 - time * 0.5) * 0.1;
    
    // Flowing noise
    float flow = fbm((uv + vec2(time * 0.05, 0.0)) * uNoiseScale, 5);
    
    return pooling * 0.5 + rings + flow * uThicknessVariation;
}

// Abstract animated pattern
float abstractThickness(vec2 uv, float time) {
    // Rotating coordinates
    float angle = time * 0.2;
    vec2 rotUv = vec2(
        uv.x * cos(angle) - uv.y * sin(angle),
        uv.x * sin(angle) + uv.y * cos(angle)
    );
    
    // Complex flowing noise
    float n1 = fbm(rotUv * uNoiseScale + time * 0.15, 4);
    float n2 = fbm((rotUv + vec2(5.2, 1.3)) * uNoiseScale * 0.5 + time * 0.1, 3);
    
    // Combine with interference
    float waves = sin(uv.x * 10.0 + time) * sin(uv.y * 10.0 - time) * 0.2;
    
    return n1 * 0.6 + n2 * 0.4 + waves;
}

void main() {
    // Simulated view angle based on UV position
    // Creates perspective-like effect on a flat plane
    vec2 centeredUv = vUv - 0.5;
    float distFromCenter = length(centeredUv);
    
    // Cosine of viewing angle (1.0 at center, decreasing toward edges)
    float cosTheta = max(0.1, 1.0 - distFromCenter * 0.8);
    
    // Animate time
    float time = uTime * uAnimSpeed;
    
    // Calculate thickness based on visualization mode
    float thicknessNorm;
    if (uVisualization == 0) {
        thicknessNorm = soapBubbleThickness(vUv, time);
    } else if (uVisualization == 1) {
        thicknessNorm = oilSlickThickness(vUv, time);
    } else {
        thicknessNorm = abstractThickness(vUv, time);
    }
    
    // Map to actual thickness range (in nanometers)
    float thickness = mix(uThicknessMin, uThicknessMax, clamp(thicknessNorm, 0.0, 1.0));
    
    // Calculate thin-film interference color
    vec3 iridescence = thinFilmColor(thickness, cosTheta, uN1, uN2, uN3);
    
    // Fresnel rim effect - more iridescence at edges
    float fresnel = pow(1.0 - cosTheta, uFresnelStrength);
    
    // Blend with base color
    vec3 color = mix(uBaseColor, iridescence, uColorIntensity * (0.3 + fresnel * 0.7));
    
    // Add subtle specular highlight at center
    float specular = pow(cosTheta, 20.0) * 0.3;
    color += vec3(specular);
    
    // Vignette for depth
    float vignette = 1.0 - distFromCenter * 0.5;
    color *= vignette;
    
    // Gamma correction for better color representation
    color = pow(color, vec3(0.9));
    
    gl_FragColor = vec4(color, 1.0);
}
