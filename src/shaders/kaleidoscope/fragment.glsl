// ============================================
// Kaleidoscope Shader
// Mirror symmetry meets polar coordinates
// ============================================

varying vec2 vUv;
uniform float uTime;

// Symmetry controls
uniform float uSegments;       // Number of mirror segments (6 = hexagonal)
uniform float uRotation;       // Base rotation offset
uniform float uRotationSpeed;  // Auto-rotation speed
uniform float uZoom;           // Zoom into the pattern

// Pattern controls
uniform float uPatternStyle;   // 0=noise, 1=voronoi, 2=waves, 3=spirals, 4=geometric
uniform float uPatternScale;   // Scale of the inner pattern
uniform float uDistortion;     // Warp/distortion amount
uniform float uComplexity;     // Pattern complexity (octaves/iterations)

// Animation
uniform float uPulse;          // Pulsing zoom effect
uniform float uFlowSpeed;      // How fast the pattern flows

// Colors
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uColor3;
uniform float uColorCycles;    // Color repetitions
uniform float uSaturation;
uniform float uBrightness;

// Effects
uniform float uCenterGlow;     // Glow at center
uniform float uEdgeFade;       // Fade at edges
uniform float uChromatic;      // Chromatic aberration amount

// Constants
#define PI 3.14159265359
#define TAU 6.28318530718

// ============================================
// Noise Functions (inline for independence)
// ============================================

float hash21(vec2 p) {
    p = fract(p * vec2(234.34, 435.345));
    p += dot(p, p + 34.23);
    return fract(p.x * p.y);
}

vec2 hash22(vec2 p) {
    vec3 a = fract(p.xyx * vec3(234.34, 435.345, 654.165));
    a += dot(a, a + 34.23);
    return fract(vec2(a.x * a.y, a.y * a.z));
}

// Simplex-style noise for smooth gradients
vec2 fade2(vec2 t) {
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

float noise2D(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    
    float a = hash21(i);
    float b = hash21(i + vec2(1.0, 0.0));
    float c = hash21(i + vec2(0.0, 1.0));
    float d = hash21(i + vec2(1.0, 1.0));
    
    vec2 u = fade2(f);
    
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

// FBM with variable octaves
float fbm(vec2 p, float octaves) {
    float sum = 0.0;
    float amp = 1.0;
    float freq = 1.0;
    float maxVal = 0.0;
    
    for (int i = 0; i < 8; i++) {
        if (float(i) >= octaves) break;
        sum += amp * noise2D(p * freq);
        maxVal += amp;
        amp *= 0.5;
        freq *= 2.0;
    }
    
    return sum / maxVal;
}

// Voronoi for crystalline patterns
float voronoi(vec2 p) {
    vec2 n = floor(p);
    vec2 f = fract(p);
    float minDist = 1.0;
    
    for (int j = -1; j <= 1; j++) {
        for (int i = -1; i <= 1; i++) {
            vec2 neighbor = vec2(float(i), float(j));
            vec2 point = hash22(n + neighbor);
            point = 0.5 + 0.5 * sin(uTime * 0.5 + TAU * point); // Animate cells
            vec2 diff = neighbor + point - f;
            minDist = min(minDist, length(diff));
        }
    }
    
    return minDist;
}

// ============================================
// Polar Coordinate Transforms
// ============================================

// Convert cartesian to polar (angle, radius)
vec2 toPolar(vec2 uv) {
    return vec2(atan(uv.y, uv.x), length(uv));
}

// Convert polar back to cartesian
vec2 toCartesian(vec2 polar) {
    return vec2(cos(polar.x), sin(polar.x)) * polar.y;
}

// ============================================
// The Kaleidoscope Transform
// ============================================

// This is the magic: n-fold mirror symmetry
vec2 kaleidoscope(vec2 uv, float segments) {
    // Convert to polar
    float angle = atan(uv.y, uv.x);
    float radius = length(uv);
    
    // Segment angle
    float segmentAngle = TAU / segments;
    
    // Fold angle into first segment
    angle = mod(angle, segmentAngle);
    
    // Mirror every other segment (creates true kaleidoscope effect)
    // Without this, you get rotational symmetry but not mirror symmetry
    if (mod(floor(atan(uv.y, uv.x) / segmentAngle), 2.0) >= 1.0) {
        angle = segmentAngle - angle;
    }
    
    // Convert back to cartesian
    return vec2(cos(angle), sin(angle)) * radius;
}

// ============================================
// Pattern Generators
// ============================================

// Pattern 0: Flowing noise
float patternNoise(vec2 p, float t) {
    vec2 flow = vec2(t * 0.3, t * 0.2);
    float n = fbm(p + flow, uComplexity);
    
    // Add detail layers
    n += 0.5 * fbm(p * 2.0 - flow * 0.5, uComplexity * 0.5);
    n /= 1.5;
    
    return n;
}

// Pattern 1: Animated voronoi cells
float patternVoronoi(vec2 p, float t) {
    float v = voronoi(p);
    
    // Add edge glow
    float edges = 1.0 - smoothstep(0.0, 0.1, v);
    
    return mix(v, edges, 0.5);
}

// Pattern 2: Interfering waves
float patternWaves(vec2 p, float t) {
    float waves = 0.0;
    
    // Multiple wave sources
    for (int i = 0; i < 5; i++) {
        float fi = float(i);
        vec2 center = vec2(
            sin(t * 0.3 + fi * 1.3),
            cos(t * 0.4 + fi * 1.7)
        ) * 2.0;
        
        float dist = length(p - center);
        waves += sin(dist * 5.0 - t * 2.0 + fi) * 0.5 + 0.5;
    }
    
    return waves / 5.0;
}

// Pattern 3: Spirals
float patternSpirals(vec2 p, float t) {
    float angle = atan(p.y, p.x);
    float radius = length(p);
    
    // Logarithmic spiral
    float spiral = sin(angle * 5.0 + log(radius + 0.1) * 10.0 - t * 2.0);
    spiral = spiral * 0.5 + 0.5;
    
    // Add counter-rotating spiral
    float spiral2 = sin(-angle * 3.0 + log(radius + 0.1) * 8.0 + t * 1.5);
    spiral2 = spiral2 * 0.5 + 0.5;
    
    return mix(spiral, spiral2, 0.5);
}

// Pattern 4: Geometric shapes
float patternGeometric(vec2 p, float t) {
    // Rotating grid
    float c = cos(t * 0.2);
    float s = sin(t * 0.2);
    p = mat2(c, -s, s, c) * p;
    
    // Combine circles and lines
    float circles = fract(length(p) * 3.0);
    circles = smoothstep(0.4, 0.5, circles) - smoothstep(0.5, 0.6, circles);
    
    // Diamond pattern
    vec2 grid = abs(fract(p) - 0.5);
    float diamonds = smoothstep(0.3, 0.35, grid.x + grid.y);
    
    // Radial lines
    float angle = atan(p.y, p.x);
    float lines = abs(sin(angle * 8.0));
    lines = smoothstep(0.9, 0.95, lines);
    
    return max(max(circles, diamonds * 0.5), lines);
}

// ============================================
// Color Functions
// ============================================

// IQ's cosine palette
vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(TAU * (c * t + d));
}

// HSV to RGB conversion
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// ============================================
// Main
// ============================================

void main() {
    // Center UV and apply aspect correction
    vec2 uv = vUv - 0.5;
    uv *= 2.0;  // Scale to -1 to 1
    
    // Store original radius for edge effects
    float origRadius = length(uv);
    
    // Apply zoom with optional pulse
    float zoom = uZoom;
    if (uPulse > 0.0) {
        zoom *= 1.0 + uPulse * 0.2 * sin(uTime * 2.0);
    }
    uv /= zoom;
    
    // Apply rotation
    float rotAngle = uRotation + uTime * uRotationSpeed;
    float c = cos(rotAngle);
    float s = sin(rotAngle);
    uv = mat2(c, -s, s, c) * uv;
    
    // Apply kaleidoscope transform
    vec2 kUv = kaleidoscope(uv, uSegments);
    
    // Apply distortion (domain warping)
    if (uDistortion > 0.0) {
        vec2 warp = vec2(
            noise2D(kUv * 3.0 + uTime * 0.5),
            noise2D(kUv * 3.0 + vec2(5.2, 1.3) + uTime * 0.5)
        ) - 0.5;
        kUv += warp * uDistortion * 0.5;
    }
    
    // Scale for pattern
    vec2 patternUv = kUv * uPatternScale;
    
    // Time for animation
    float t = uTime * uFlowSpeed;
    
    // Generate pattern based on style
    float pattern = 0.0;
    int style = int(uPatternStyle);
    
    if (style == 0) {
        pattern = patternNoise(patternUv, t);
    } else if (style == 1) {
        pattern = patternVoronoi(patternUv, t);
    } else if (style == 2) {
        pattern = patternWaves(patternUv, t);
    } else if (style == 3) {
        pattern = patternSpirals(patternUv, t);
    } else {
        pattern = patternGeometric(patternUv, t);
    }
    
    // Color mapping
    float colorT = pattern * uColorCycles;
    
    // Add radial color variation
    colorT += length(kUv) * 0.3;
    
    // Create color using palette
    vec3 col1 = uColor1;
    vec3 col2 = uColor2;
    vec3 col3 = uColor3;
    
    // Blend between the three colors based on pattern
    vec3 color;
    if (pattern < 0.5) {
        color = mix(col1, col2, pattern * 2.0);
    } else {
        color = mix(col2, col3, (pattern - 0.5) * 2.0);
    }
    
    // Add rainbow cycling option
    vec3 rainbow = hsv2rgb(vec3(colorT * 0.5 + uTime * 0.1, uSaturation, 1.0));
    color = mix(color, rainbow, 0.3);
    
    // Apply saturation and brightness
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    color = mix(vec3(luminance), color, uSaturation);
    color *= uBrightness;
    
    // Chromatic aberration effect
    if (uChromatic > 0.0) {
        float aberration = uChromatic * 0.02;
        vec2 kUvR = kaleidoscope(uv * (1.0 + aberration), uSegments);
        vec2 kUvB = kaleidoscope(uv * (1.0 - aberration), uSegments);
        
        float patternR = 0.0;
        float patternB = 0.0;
        
        if (style == 0) {
            patternR = patternNoise(kUvR * uPatternScale, t);
            patternB = patternNoise(kUvB * uPatternScale, t);
        } else if (style == 1) {
            patternR = patternVoronoi(kUvR * uPatternScale, t);
            patternB = patternVoronoi(kUvB * uPatternScale, t);
        } else {
            patternR = pattern;
            patternB = pattern;
        }
        
        color.r = mix(color.r, patternR, 0.3);
        color.b = mix(color.b, patternB, 0.3);
    }
    
    // Center glow
    if (uCenterGlow > 0.0) {
        float glow = 1.0 - smoothstep(0.0, 0.5, origRadius);
        glow = pow(glow, 2.0);
        color += glow * uCenterGlow * vec3(1.0, 0.9, 0.8);
    }
    
    // Edge fade (vignette)
    if (uEdgeFade > 0.0) {
        float vignette = 1.0 - smoothstep(0.5, 1.0, origRadius);
        color *= mix(1.0, vignette, uEdgeFade);
    }
    
    // Ensure colors are in valid range
    color = clamp(color, 0.0, 1.0);
    
    gl_FragColor = vec4(color, 1.0);
}
