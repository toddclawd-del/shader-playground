// Moiré Pattern Shader
// Demonstrates interference patterns from overlapping periodic structures
// Reference: https://en.wikipedia.org/wiki/Moir%C3%A9_pattern

varying vec2 vUv;

uniform float uTime;
uniform float uFrequency1;
uniform float uFrequency2;
uniform float uRotation1;
uniform float uRotation2;
uniform float uAnimSpeed;
uniform float uLineWidth;
uniform float uContrast;
uniform int uPatternType;       // 0: Radial, 1: Linear, 2: Rotating, 3: Combined
uniform float uCenterOffset;
uniform float uWaveDistortion;
uniform float uColorPhase;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uColor3;
uniform vec3 uBackgroundColor;

#define PI 3.14159265359
#define TAU 6.28318530718

// ═══════════════════════════════════════════════════════════════════════════
// ROTATION
// ═══════════════════════════════════════════════════════════════════════════

mat2 rotate2D(float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return mat2(c, -s, s, c);
}

// ═══════════════════════════════════════════════════════════════════════════
// PATTERN GENERATORS
// Each returns a value between 0 and 1 based on the distance field
// ═══════════════════════════════════════════════════════════════════════════

// Concentric circles (radial pattern)
float radialPattern(vec2 uv, vec2 center, float frequency) {
    float dist = length(uv - center);
    return sin(dist * frequency * TAU);
}

// Parallel lines (linear pattern)
float linearPattern(vec2 uv, float angle, float frequency) {
    vec2 rotated = rotate2D(angle) * uv;
    return sin(rotated.x * frequency * TAU);
}

// Spiral pattern
float spiralPattern(vec2 uv, vec2 center, float frequency, float twist) {
    vec2 p = uv - center;
    float dist = length(p);
    float angle = atan(p.y, p.x);
    return sin((dist + angle * twist) * frequency * TAU);
}

// Grid/checker pattern
float gridPattern(vec2 uv, float angle, float frequency) {
    vec2 rotated = rotate2D(angle) * uv;
    float lines1 = sin(rotated.x * frequency * TAU);
    float lines2 = sin(rotated.y * frequency * TAU);
    return lines1 * lines2;
}

// ═══════════════════════════════════════════════════════════════════════════
// WAVE DISTORTION
// Adds organic movement to patterns
// ═══════════════════════════════════════════════════════════════════════════

vec2 waveDistort(vec2 uv, float amount, float time) {
    if (amount < 0.001) return uv;
    
    float wave1 = sin(uv.y * 5.0 + time * 0.5) * amount * 0.1;
    float wave2 = sin(uv.x * 4.0 + time * 0.7) * amount * 0.08;
    
    return uv + vec2(wave1, wave2);
}

// ═══════════════════════════════════════════════════════════════════════════
// MOIRÉ COMBINATION
// The magic happens when we combine patterns with different parameters
// ═══════════════════════════════════════════════════════════════════════════

float combineMoire(float pattern1, float pattern2, float width) {
    // Convert sine waves to line patterns using threshold
    float line1 = smoothstep(-width, width, pattern1);
    float line2 = smoothstep(-width, width, pattern2);
    
    // Multiply patterns - overlap creates moiré
    return line1 * line2;
}

float combineAdditiveGlow(float pattern1, float pattern2) {
    // Additive blending creates soft glowing intersections
    float glow1 = 0.5 + 0.5 * pattern1;
    float glow2 = 0.5 + 0.5 * pattern2;
    return glow1 * glow2;
}

// ═══════════════════════════════════════════════════════════════════════════
// COLOR MAPPING
// ═══════════════════════════════════════════════════════════════════════════

vec3 mapColor(float value, float phase) {
    // Create a smooth gradient through three colors with phase shift
    float t = fract(value + phase);
    
    vec3 color;
    if (t < 0.333) {
        color = mix(uColor1, uColor2, t * 3.0);
    } else if (t < 0.666) {
        color = mix(uColor2, uColor3, (t - 0.333) * 3.0);
    } else {
        color = mix(uColor3, uColor1, (t - 0.666) * 3.0);
    }
    
    return color;
}

// ═══════════════════════════════════════════════════════════════════════════
// MAIN
// ═══════════════════════════════════════════════════════════════════════════

void main() {
    // Center UV coordinates (-0.5 to 0.5)
    vec2 uv = vUv - 0.5;
    
    // Apply wave distortion for organic movement
    float time = uTime * uAnimSpeed;
    uv = waveDistort(uv, uWaveDistortion, time);
    
    // Calculate animated parameters
    float animRotation1 = uRotation1 + time * 0.1;
    float animRotation2 = uRotation2 - time * 0.08;
    
    // Define pattern centers for radial patterns
    vec2 center1 = vec2(uCenterOffset * 0.1, 0.0);
    vec2 center2 = vec2(-uCenterOffset * 0.1, 0.0);
    
    float moire;
    float pattern1, pattern2;
    
    // ─────────────────────────────────────────────────────────────────────────
    // PATTERN TYPE 0: RADIAL MOIRÉ (Concentric Circles)
    // Classic moiré from two sets of concentric circles
    // ─────────────────────────────────────────────────────────────────────────
    if (uPatternType == 0) {
        // Two overlapping sets of concentric circles with different centers/frequencies
        pattern1 = radialPattern(uv, center1, uFrequency1);
        pattern2 = radialPattern(uv, center2, uFrequency2);
        
        moire = combineAdditiveGlow(pattern1, pattern2);
    }
    
    // ─────────────────────────────────────────────────────────────────────────
    // PATTERN TYPE 1: LINEAR MOIRÉ (Parallel Lines)
    // Two sets of parallel lines at different angles
    // ─────────────────────────────────────────────────────────────────────────
    else if (uPatternType == 1) {
        pattern1 = linearPattern(uv, animRotation1, uFrequency1);
        pattern2 = linearPattern(uv, animRotation2, uFrequency2);
        
        moire = combineMoire(pattern1, pattern2, uLineWidth);
    }
    
    // ─────────────────────────────────────────────────────────────────────────
    // PATTERN TYPE 2: ROTATING GRID MOIRÉ
    // Two grids at different angles - creates complex interference
    // ─────────────────────────────────────────────────────────────────────────
    else if (uPatternType == 2) {
        pattern1 = gridPattern(uv, animRotation1, uFrequency1);
        pattern2 = gridPattern(uv, animRotation2, uFrequency2);
        
        moire = combineMoire(pattern1, pattern2, uLineWidth);
    }
    
    // ─────────────────────────────────────────────────────────────────────────
    // PATTERN TYPE 3: COMBINED (Radial + Linear)
    // Mix of concentric circles and lines for maximum hypnosis
    // ─────────────────────────────────────────────────────────────────────────
    else if (uPatternType == 3) {
        float radial = radialPattern(uv, vec2(0.0), uFrequency1);
        float linear = linearPattern(uv, animRotation1, uFrequency2);
        
        pattern1 = radial;
        pattern2 = linear;
        
        moire = combineAdditiveGlow(pattern1, pattern2);
    }
    
    // ─────────────────────────────────────────────────────────────────────────
    // PATTERN TYPE 4: SPIRAL MOIRÉ
    // Two spiraling patterns create rotating moiré effect
    // ─────────────────────────────────────────────────────────────────────────
    else {
        float twist1 = 2.0 + sin(time * 0.3);
        float twist2 = 2.5 - cos(time * 0.25);
        
        pattern1 = spiralPattern(uv, center1, uFrequency1, twist1);
        pattern2 = spiralPattern(uv, center2, uFrequency2, twist2);
        
        moire = combineAdditiveGlow(pattern1, pattern2);
    }
    
    // ─────────────────────────────────────────────────────────────────────────
    // CONTRAST & COLOR
    // ─────────────────────────────────────────────────────────────────────────
    
    // Apply contrast curve
    moire = pow(moire, 1.0 / uContrast);
    
    // Map to colors with animated phase
    float colorPhase = uColorPhase + time * 0.05;
    vec3 moireColor = mapColor(moire, colorPhase);
    
    // Blend with background based on pattern intensity
    float blend = smoothstep(0.1, 0.9, moire);
    vec3 finalColor = mix(uBackgroundColor, moireColor, blend);
    
    // Add subtle pulsing glow at high-intensity regions
    float glow = pow(moire, 3.0) * 0.3;
    finalColor += glow * uColor1;
    
    // Vignette
    float vignette = 1.0 - length(vUv - 0.5) * 0.5;
    finalColor *= vignette;
    
    gl_FragColor = vec4(finalColor, 1.0);
}
