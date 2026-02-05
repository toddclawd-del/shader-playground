// ============================================
// Supershape / Superformula Shader
// Johan Gielis' universal shape equation (2003)
//
// One formula to rule them all:
//   r(φ) = (|cos(mφ/4)/a|^n2 + |sin(mφ/4)/b|^n3)^(-1/n1)
//
// By tweaking m, n1, n2, n3, a, b you can generate:
//   circles, stars, flowers, polygons, leaves, organic blobs...
//   basically every 2D natural form from a single equation.
//
// Reference: https://paulbourke.net/geometry/supershape/
// ============================================

varying vec2 vUv;
uniform float uTime;

// Superformula parameters
uniform float uM;           // Rotational symmetry count
uniform float uN1;          // "Inflation" exponent
uniform float uN2;          // Cos term exponent
uniform float uN3;          // Sin term exponent
uniform float uA;           // Cos scaling
uniform float uB;           // Sin scaling

// Visualization
uniform float uVisualization;   // 0=Neon, 1=SDF Contours, 2=Filled, 3=Morph, 4=Layered
uniform float uScale;           // Overall shape scale
uniform float uLineWidth;       // Outline thickness
uniform float uGlow;            // Glow intensity

// Animation
uniform float uAnimSpeed;       // Speed multiplier
uniform float uRotationSpeed;   // Auto-rotation
uniform float uAutoMorph;       // Toggle morphing (bool 0/1)
uniform float uMorphSpeed;      // Morph cycle speed
uniform float uBreathe;         // Parameter wobble amount

// Colors
uniform vec3 uColor1;           // Primary
uniform vec3 uColor2;           // Secondary
uniform vec3 uColor3;           // Accent
uniform vec3 uBackgroundColor;  // Background

// Layered mode
uniform float uLayers;          // Number of shape layers
uniform float uLayerSpread;     // Scale spread between layers

// Constants
#define PI 3.14159265359
#define TAU 6.28318530718

// ============================================
// THE SUPERFORMULA
// ============================================
// This is the entire equation, evaluated at a given angle.
// Returns the radius of the shape at that angle.
//
// The math:
//   cos(mφ/4) creates m-fold symmetry around the circle
//   n1 controls overall "inflation" — higher = rounder
//   n2, n3 control the shape of each lobe
//   a, b scale the cos/sin terms independently
//
// When n1=n2=n3 and they're small (<1): star shapes
// When n1 is large, n2=n3 are large: polygon shapes
// When n1 is moderate, n2≠n3: asymmetric organic forms

float superformula(float phi, float m, float n1, float n2, float n3, float a, float b) {
    // The two halves of the equation
    float t1 = abs(cos(m * phi * 0.25) / a);
    t1 = pow(t1, n2);

    float t2 = abs(sin(m * phi * 0.25) / b);
    t2 = pow(t2, n3);

    float sum = t1 + t2;

    // Guard against division by zero / numerical instability
    if (sum < 1e-10) return 1.0;

    // The negative reciprocal power creates the "inside-out" effect
    // that makes the shape finite rather than infinite
    return pow(sum, -1.0 / n1);
}

// ============================================
// Signed Distance to the Supershape
// ============================================
// Negative = inside, Positive = outside
// This is what enables smooth outlines, glows, and fills.

float supershapeSDF(vec2 p, float m, float n1, float n2, float n3, float a, float b, float sc) {
    float angle = atan(p.y, p.x);
    float radius = length(p);
    float shapeR = superformula(angle, m, n1, n2, n3, a, b) * sc;
    return radius - shapeR;
}

// ============================================
// Shape Presets for Morph Mode
// ============================================
// vec4(m, n1, n2, n3) — a and b stay at 1.0

// Each preset is a fundamentally different shape topology:
//   0: Starfish — pointy star with thin arms
//   1: Organic blob — smooth flowing amoeba (IQ's classic m=3 params)
//   2: Hexagonal flower — six rounded petals
//   3: Rounded square — polygon with soft corners
//   4: Five-petal flower — botanical accuracy
//   5: Eight-point star — compass rose
//   6: Trefoil — three-lobed clover shape
//   7: Seven-petal daisy — odd-symmetry flower

#define NUM_PRESETS 8

vec4 getPreset(int idx) {
    if (idx == 0) return vec4(5.0,  0.3,  0.3,  0.3);    // Starfish
    if (idx == 1) return vec4(3.0,  5.0,  18.0, 18.0);   // Organic blob
    if (idx == 2) return vec4(6.0,  1.0,  1.0,  1.0);    // Hex flower
    if (idx == 3) return vec4(4.0,  12.0, 15.0, 15.0);   // Rounded square
    if (idx == 4) return vec4(5.0,  1.0,  1.7,  1.7);    // Five petals
    if (idx == 5) return vec4(8.0,  0.5,  0.5,  0.5);    // Eight-point star
    if (idx == 6) return vec4(3.0,  0.5,  1.0,  1.0);    // Trefoil
    return          vec4(7.0,  0.2,  1.7,  1.7);          // Seven-petal daisy
}

// Smooth interpolation between presets using smoothstep easing
vec4 morphPresets(float t) {
    float total = float(NUM_PRESETS);
    float phase = mod(t, total);
    int current = int(floor(phase));
    int next = int(mod(float(current + 1), total));
    float blend = fract(phase);

    // Hermite ease-in-out for natural-feeling transitions
    blend = blend * blend * (3.0 - 2.0 * blend);

    return mix(getPreset(current), getPreset(next), blend);
}

// ============================================
// Color Helpers
// ============================================

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// Simple hash for background texture
float hash(vec2 p) {
    p = fract(p * vec2(234.34, 435.345));
    p += dot(p, p + 34.23);
    return fract(p.x * p.y);
}

float noise2D(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

// ============================================
// Main
// ============================================

void main() {
    // Center UV to -1..1
    vec2 uv = (vUv - 0.5) * 2.0;

    float t = uTime * uAnimSpeed;

    // --- Resolve parameters ---
    float m  = uM;
    float n1 = uN1;
    float n2 = uN2;
    float n3 = uN3;
    float a  = uA;
    float b  = uB;

    int vis = int(uVisualization);

    // Auto-morph overrides manual parameters
    bool morphing = uAutoMorph > 0.5 || vis == 3;
    if (morphing) {
        vec4 preset = morphPresets(t * uMorphSpeed * 0.3);
        m  = preset.x;
        n1 = preset.y;
        n2 = preset.z;
        n3 = preset.w;
        a  = 1.0;
        b  = 1.0;
    }

    // "Breathe" — gentle parameter oscillation for organic feel
    if (uBreathe > 0.0 && !morphing) {
        float breath = uBreathe * 0.15;
        n1 += sin(t * 0.7) * n1 * breath;
        n2 += sin(t * 0.9 + 1.0) * n2 * breath;
        n3 += cos(t * 0.8 + 2.0) * n3 * breath;
    }

    // --- Rotation ---
    float rot = t * uRotationSpeed;
    float cr = cos(rot);
    float sr = sin(rot);
    vec2 ruv = mat2(cr, -sr, sr, cr) * uv;

    // --- Compute SDF ---
    float d = supershapeSDF(ruv, m, n1, n2, n3, a, b, uScale);

    // Screen-space AA using derivative of distance
    float aa = fwidth(d);

    // --- Background ---
    // Subtle noise + radial gradient for depth
    float bgNoise = noise2D(uv * 5.0 + t * 0.05) * 0.03;
    float bgRadial = 1.0 - 0.35 * length(uv);
    vec3 bg = uBackgroundColor * (bgRadial + bgNoise);

    vec3 color = bg;

    // ========== MODE 0: Neon Glow ==========
    if (vis == 0) {
        // Crisp outline
        float outline = smoothstep(uLineWidth + aa, uLineWidth - aa, abs(d));

        // Multi-layer glow: exponential falloff
        float glow1 = exp(-abs(d) * (10.0 - uGlow * 7.0));       // tight glow
        float glow2 = exp(-abs(d) * (4.0 - uGlow * 2.5)) * 0.4;  // wide bloom

        // Angle-based hue shift along the shape
        float angle = atan(ruv.y, ruv.x) / TAU + 0.5;
        vec3 shapeColor = mix(uColor1, uColor2, angle);
        shapeColor = mix(shapeColor, uColor3, sin(angle * m * PI) * 0.5 + 0.5);

        color = bg;
        color += shapeColor * (glow1 + glow2) * uGlow;
        color += shapeColor * outline;
    }

    // ========== MODE 1: SDF Contours ==========
    else if (vis == 1) {
        // Topographic contour lines of the distance field
        float contourFreq = 25.0;
        float bands = sin(d * contourFreq) * 0.5 + 0.5;
        bands *= exp(-abs(d) * 2.5);

        // Surface highlight (the actual shape boundary)
        float surface = smoothstep(aa, -aa, abs(d) - 0.008);

        // Inside vs outside coloring
        float insideMask = smoothstep(aa, -aa, d);
        vec3 inside  = mix(uColor1, uColor2, bands);
        vec3 outside = mix(uColor3 * 0.4, bg, smoothstep(0.0, 0.8, d));

        color = mix(outside, inside, insideMask);
        color += bands * 0.15;
        color = mix(color, vec3(1.0), surface * 0.9);
    }

    // ========== MODE 2: Filled Shape ==========
    else if (vis == 2) {
        float fill = smoothstep(aa, -aa, d);

        // Interior: angle + radius gradient
        float angle = atan(ruv.y, ruv.x) / TAU + 0.5;
        float radius = length(ruv);

        // Rich color blending
        vec3 fillColor = mix(uColor1, uColor2, angle);
        fillColor = mix(fillColor, uColor3, sin(angle * m * PI + t) * 0.5 + 0.5);

        // Radial luminosity falloff
        float rFade = smoothstep(0.0, uScale * 0.9, radius);
        fillColor = mix(fillColor * 1.2, fillColor * 0.25, rFade);

        // Thin bright edge
        float edge = smoothstep(0.015 + aa, 0.015 - aa, abs(d));
        vec3 edgeColor = mix(uColor2, uColor3, 0.5) * 1.5;

        color = mix(bg, fillColor, fill);
        color += edgeColor * edge * 0.6;
    }

    // ========== MODE 3: Morph Gallery ==========
    else if (vis == 3) {
        float outline = smoothstep(uLineWidth + aa, uLineWidth - aa, abs(d));
        float glow1 = exp(-abs(d) * (10.0 - uGlow * 7.0));
        float glow2 = exp(-abs(d) * (4.0 - uGlow * 2.5)) * 0.35;

        // Cycling rainbow hue
        float hue = fract(t * uMorphSpeed * 0.08);
        vec3 shapeColor = hsv2rgb(vec3(hue, 0.85, 1.0));

        // Second hue for gradient
        vec3 shapeColor2 = hsv2rgb(vec3(fract(hue + 0.33), 0.7, 0.9));

        float angle = atan(ruv.y, ruv.x) / TAU + 0.5;
        vec3 blended = mix(shapeColor, shapeColor2, angle);

        color = bg;
        color += blended * (glow1 + glow2) * uGlow;
        color += blended * outline;

        // Subtle interior fill
        float fill = smoothstep(aa, -aa, d);
        color += blended * fill * 0.1;
    }

    // ========== MODE 4: Layered Bloom ==========
    else if (vis == 4) {
        int numLayers = int(uLayers);
        color = bg;

        for (int i = 0; i < 5; i++) {
            if (i >= numLayers) break;

            float fi = float(i);
            float layerScale = uScale * (1.0 + fi * uLayerSpread * 0.25);
            float layerRot = rot + fi * PI / float(numLayers);

            float lc = cos(layerRot);
            float ls = sin(layerRot);
            vec2 lruv = mat2(lc, -ls, ls, lc) * uv;

            float ld = supershapeSDF(lruv, m, n1, n2, n3, a, b, layerScale);
            float laa = fwidth(ld);

            // Glow + outline per layer
            float lglow = exp(-abs(ld) * (10.0 - uGlow * 7.0));
            float lglow2 = exp(-abs(ld) * (4.0 - uGlow * 2.5)) * 0.3;
            float loutline = smoothstep(uLineWidth + laa, uLineWidth - laa, abs(ld));

            // Per-layer color via hue shift
            float hue = fi / float(numLayers);
            vec3 layerColor = mix(uColor1, uColor2, hue);
            layerColor = mix(layerColor, uColor3, fract(hue + 0.5));

            float opacity = 1.0 - fi * 0.12;

            color += layerColor * (lglow + lglow2) * uGlow * opacity * 0.5;
            color += layerColor * loutline * opacity;
        }
    }

    // --- Final polish ---

    // Vignette
    float vignette = 1.0 - 0.35 * dot(vUv - 0.5, vUv - 0.5) * 4.0;
    color *= vignette;

    color = clamp(color, 0.0, 1.0);

    gl_FragColor = vec4(color, 1.0);
}
