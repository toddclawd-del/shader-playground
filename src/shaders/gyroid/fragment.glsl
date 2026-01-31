// Gyroid Pattern Shader
// A triply periodic minimal surface discovered by Alan Schoen in 1970
// The gyroid minimizes surface area like a soap film - it's a "minimal surface"

varying vec2 vUv;

uniform float uTime;
uniform float uScale;
uniform float uSliceSpeed;
uniform float uSliceOffset;
uniform float uThickness;
uniform float uOctaves;
uniform float uLacunarity;
uniform float uPersistence;
uniform int uVisualization;
uniform float uContourFrequency;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uColor3;
uniform vec3 uBackgroundColor;
uniform float uColorMix;
uniform float uGlow;
uniform float uDistortion;

// ============================================================
// THE CORE GYROID FORMULA
// ============================================================
// This is the magic: sin and cos of each axis dotted together
// Mathematically: sin(x)cos(y) + sin(y)cos(z) + sin(z)cos(x)
// In GLSL: dot(sin(p), cos(p.yzx)) - elegant one-liner!
//
// The result is a continuous field where:
//   value = 0  → you're ON the gyroid surface
//   value > 0  → you're "outside"
//   value < 0  → you're "inside"
// ============================================================

float gyroid(vec3 p) {
    return dot(sin(p), cos(p.yzx));
}

// Gyroid with adjustable thickness (creates tubular structures)
float gyroidSurface(vec3 p, float thickness) {
    return abs(gyroid(p)) - thickness;
}

// FBM-style stacked gyroids for organic complexity
float fbmGyroid(vec3 p, int octaves, float lacunarity, float persistence) {
    float value = 0.0;
    float amplitude = 1.0;
    float frequency = 1.0;
    float maxValue = 0.0;
    
    for (int i = 0; i < 8; i++) {
        if (i >= octaves) break;
        value += amplitude * gyroid(p * frequency);
        maxValue += amplitude;
        amplitude *= persistence;
        frequency *= lacunarity;
    }
    
    return value / maxValue;
}

// Simple rotation matrix for 3D distortion
mat3 rotateY(float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return mat3(
        c, 0.0, s,
        0.0, 1.0, 0.0,
        -s, 0.0, c
    );
}

mat3 rotateX(float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return mat3(
        1.0, 0.0, 0.0,
        0.0, c, -s,
        0.0, s, c
    );
}

void main() {
    // Center UV coordinates (-1 to 1 range)
    vec2 uv = vUv * 2.0 - 1.0;
    uv *= uScale;
    
    // Create 3D coordinates for the gyroid
    // The Z-axis "slices" through the infinite gyroid structure over time
    float z = uTime * uSliceSpeed + uSliceOffset;
    vec3 p = vec3(uv, z);
    
    // Apply optional rotation/distortion
    if (uDistortion > 0.0) {
        float wobble = sin(uTime * 0.3) * uDistortion;
        p = rotateY(wobble) * rotateX(wobble * 0.7) * p;
    }
    
    // Calculate gyroid value
    float g;
    if (uOctaves > 1.0) {
        g = fbmGyroid(p, int(uOctaves), uLacunarity, uPersistence);
    } else {
        g = gyroid(p);
    }
    
    // Visualization modes
    vec3 color;
    float alpha = 1.0;
    
    if (uVisualization == 0) {
        // Mode 0: Smooth gradient
        // Maps the continuous gyroid field to colors
        float t = g * 0.5 + 0.5; // Normalize to 0-1
        t = clamp(t, 0.0, 1.0);
        
        // Three-color gradient
        if (t < 0.5) {
            color = mix(uColor1, uColor2, t * 2.0);
        } else {
            color = mix(uColor2, uColor3, (t - 0.5) * 2.0);
        }
        
    } else if (uVisualization == 1) {
        // Mode 1: Contour lines (topographic map style)
        // Shows the structure more clearly
        float contours = sin(g * uContourFrequency * 6.28318);
        float lines = smoothstep(0.8, 1.0, abs(contours));
        
        // Color based on which "side" of the surface
        float side = step(0.0, g);
        vec3 baseColor = mix(uColor1, uColor3, side);
        color = mix(baseColor, uColor2, lines);
        
    } else if (uVisualization == 2) {
        // Mode 2: Binary threshold (shows the actual surface boundary)
        float surface = smoothstep(uThickness, uThickness - 0.05, abs(g));
        color = mix(uBackgroundColor, uColor1, surface);
        
        // Add glow around surface
        float glow = smoothstep(uThickness + uGlow, uThickness, abs(g));
        color += uColor2 * glow * 0.5;
        
    } else if (uVisualization == 3) {
        // Mode 3: Heat map (good for seeing the field values)
        float t = g * 0.5 + 0.5;
        
        // Classic heat map: blue -> cyan -> green -> yellow -> red
        vec3 c1 = vec3(0.0, 0.0, 0.5);  // Deep blue
        vec3 c2 = vec3(0.0, 0.5, 1.0);  // Cyan
        vec3 c3 = vec3(0.0, 1.0, 0.5);  // Green
        vec3 c4 = vec3(1.0, 1.0, 0.0);  // Yellow
        vec3 c5 = vec3(1.0, 0.0, 0.0);  // Red
        
        if (t < 0.25) {
            color = mix(c1, c2, t * 4.0);
        } else if (t < 0.5) {
            color = mix(c2, c3, (t - 0.25) * 4.0);
        } else if (t < 0.75) {
            color = mix(c3, c4, (t - 0.5) * 4.0);
        } else {
            color = mix(c4, c5, (t - 0.75) * 4.0);
        }
        
        // Override with custom colors if uColorMix is high
        if (uColorMix > 0.0) {
            vec3 customHeat;
            if (t < 0.5) {
                customHeat = mix(uColor1, uColor2, t * 2.0);
            } else {
                customHeat = mix(uColor2, uColor3, (t - 0.5) * 2.0);
            }
            color = mix(color, customHeat, uColorMix);
        }
        
    } else {
        // Mode 4: Cellular / organic
        // Combines contours with surface detection
        float cell = abs(g);
        float lines = fract(cell * uContourFrequency);
        lines = smoothstep(0.0, 0.1, lines) * smoothstep(0.2, 0.1, lines);
        
        float depth = 1.0 - smoothstep(0.0, 1.0, cell);
        color = mix(uBackgroundColor, uColor1, depth);
        color = mix(color, uColor2, lines * 0.8);
        
        // Highlight the zero-crossing (actual surface)
        float surface = smoothstep(uThickness, 0.0, cell);
        color = mix(color, uColor3, surface);
    }
    
    // Add subtle glow effect
    if (uGlow > 0.0 && uVisualization != 2) {
        float glowMask = 1.0 - smoothstep(0.0, 0.5, abs(g));
        color += uColor2 * glowMask * uGlow * 0.3;
    }
    
    // Vignette for polish
    float vignette = 1.0 - length(vUv - 0.5) * 0.5;
    color *= vignette;
    
    gl_FragColor = vec4(color, alpha);
}
