// ============================================
// Julia Set Fractal Shader
// ============================================
// The Julia set is the boundary between points that escape to infinity
// and points that remain bounded under iteration of f(z) = z² + c
//
// Unlike Mandelbrot (where c varies and z₀ = 0), here c is constant
// and z₀ varies across the complex plane. This makes Julia sets
// "slices" of the Mandelbrot set — each point in Mandelbrot corresponds
// to a unique Julia set.
// ============================================

varying vec2 vUv;

uniform float uTime;
uniform float uZoom;
uniform vec2 uCenter;
uniform vec2 uC;           // The constant c in f(z) = z² + c
uniform float uAnimateC;   // Whether to animate c
uniform float uAnimSpeed;
uniform int uMaxIterations;
uniform float uColorCycles;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uColor3;
uniform float uSaturation;
uniform float uInteriorStyle; // 0 = black, 1 = colored

// Complex number multiplication: (a + bi)(c + di) = (ac - bd) + (ad + bc)i
vec2 complexMul(vec2 a, vec2 b) {
    return vec2(
        a.x * b.x - a.y * b.y,  // real part
        a.x * b.y + a.y * b.x   // imaginary part
    );
}

// Complex number squared: z² = (a + bi)² = (a² - b²) + 2abi
vec2 complexSquare(vec2 z) {
    return vec2(
        z.x * z.x - z.y * z.y,  // real: a² - b²
        2.0 * z.x * z.y         // imaginary: 2ab
    );
}

// Complex magnitude squared (faster than length for comparison)
float complexMag2(vec2 z) {
    return z.x * z.x + z.y * z.y;
}

// Smooth iteration count for anti-aliased coloring
// Instead of integer iteration count, we get a smooth float
float smoothIterations(vec2 z, int iterations) {
    // The "potential" at escape gives us sub-iteration precision
    // log(log|z|) / log(2) gives continuous coloring
    float mag2 = complexMag2(z);
    float log_zn = log(mag2) / 2.0;  // log|z|
    float nu = log(log_zn / log(2.0)) / log(2.0);
    return float(iterations) + 1.0 - nu;
}

// HSV to RGB conversion for color flexibility
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// Palette function using cosine gradients (IQ technique)
vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(6.28318 * (c * t + d));
}

void main() {
    // Map UV [0,1] to centered coordinates [-1,1] with aspect correction
    vec2 uv = vUv * 2.0 - 1.0;
    
    // Apply zoom and pan
    // Zoom works by scaling the view window (smaller scale = deeper zoom)
    vec2 z = uv / uZoom + uCenter;
    
    // Get the c constant - either animated or manual
    vec2 c;
    if (uAnimateC > 0.5) {
        // Animate c along interesting paths in the complex plane
        // This path traces through many beautiful Julia set shapes
        float t = uTime * uAnimSpeed;
        
        // Orbit around the "main cardioid" of Mandelbrot set
        // c = 0.7885 * e^(it) gives the classic spiraling Julia sets
        float r = 0.7885;
        c = vec2(r * cos(t), r * sin(t));
        
        // Alternative: figure-8 path through interesting regions
        // c = vec2(sin(t) * 0.4, sin(t * 2.0) * 0.3);
    } else {
        c = uC;
    }
    
    // ========================================
    // ESCAPE TIME ALGORITHM
    // ========================================
    // Iterate z = z² + c until |z| > 2 (escaped) or max iterations
    // Points that don't escape are "in" the Julia set
    
    int iterations = 0;
    const float ESCAPE_RADIUS = 4.0;  // Actually 2², we compare |z|²
    
    for (int i = 0; i < 500; i++) {
        if (i >= uMaxIterations) break;
        
        // Check escape condition: |z|² > 4 means |z| > 2
        if (complexMag2(z) > ESCAPE_RADIUS) break;
        
        // The magic formula: z = z² + c
        z = complexSquare(z) + c;
        iterations++;
    }
    
    // ========================================
    // COLORING
    // ========================================
    
    vec3 color;
    
    if (iterations >= uMaxIterations) {
        // Interior (bounded) points
        if (uInteriorStyle > 0.5) {
            // Colored interior based on final z position
            float angle = atan(z.y, z.x);
            float mag = length(z);
            color = hsv2rgb(vec3(angle / 6.28318 + 0.5, 0.7, 0.3));
        } else {
            // Classic black interior
            color = vec3(0.0);
        }
    } else {
        // Exterior - use smooth iteration count for anti-aliased bands
        float smoothIter = smoothIterations(z, iterations);
        
        // Normalize and apply color cycles
        float t = smoothIter / float(uMaxIterations);
        t = fract(t * uColorCycles);
        
        // Create gradient using the three colors
        // Using cosine interpolation for smooth transitions
        vec3 col;
        if (t < 0.33) {
            col = mix(uColor1, uColor2, t * 3.0);
        } else if (t < 0.66) {
            col = mix(uColor2, uColor3, (t - 0.33) * 3.0);
        } else {
            col = mix(uColor3, uColor1, (t - 0.66) * 3.0);
        }
        
        // Apply saturation control
        float gray = dot(col, vec3(0.299, 0.587, 0.114));
        color = mix(vec3(gray), col, uSaturation);
    }
    
    // Subtle vignette for polish
    float vignette = 1.0 - 0.3 * length(vUv - 0.5);
    color *= vignette;
    
    gl_FragColor = vec4(color, 1.0);
}
