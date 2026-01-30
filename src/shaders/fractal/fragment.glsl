// ============================================
// Fractal Explorer Shader
// Renders classic fractals in real-time:
// - Mandelbrot: z = z² + c (pixel coords)
// - Julia: z = z² + c (animated c parameter)
// - Burning Ship: z = (|Re(z)| + i|Im(z)|)² + c
//
// Features smooth coloring for anti-aliased edges
// ============================================

precision highp float;

varying vec2 vUv;

uniform float uTime;
uniform float uFractalType; // 0=mandelbrot, 1=julia, 2=burning ship
uniform float uZoom;
uniform float uCenterX;
uniform float uCenterY;
uniform float uIterations;
uniform float uColorPalette; // 0=classic, 1=fire, 2=ocean, 3=neon
uniform vec2 uMouse;
uniform float uMouseDown;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uColor3;

#define PI 3.14159265359

// ============================================
// Color Palettes
// ============================================

vec3 palette(float t, int paletteType) {
    t = fract(t);
    
    if (paletteType == 0) {
        // Classic - based on uniform colors
        if (t < 0.5) {
            return mix(uColor1, uColor2, t * 2.0);
        }
        return mix(uColor2, uColor3, (t - 0.5) * 2.0);
    } else if (paletteType == 1) {
        // Fire
        vec3 a = vec3(0.5, 0.5, 0.5);
        vec3 b = vec3(0.5, 0.5, 0.5);
        vec3 c = vec3(1.0, 0.7, 0.4);
        vec3 d = vec3(0.0, 0.15, 0.2);
        return a + b * cos(2.0 * PI * (c * t + d));
    } else if (paletteType == 2) {
        // Ocean
        vec3 a = vec3(0.5, 0.5, 0.5);
        vec3 b = vec3(0.5, 0.5, 0.5);
        vec3 c = vec3(1.0, 1.0, 1.0);
        vec3 d = vec3(0.0, 0.33, 0.67);
        return a + b * cos(2.0 * PI * (c * t + d));
    } else {
        // Neon
        vec3 a = vec3(0.5, 0.5, 0.5);
        vec3 b = vec3(0.5, 0.5, 0.5);
        vec3 c = vec3(1.0, 1.0, 0.5);
        vec3 d = vec3(0.8, 0.9, 0.3);
        return a + b * cos(2.0 * PI * (c * t + d));
    }
}

// ============================================
// Fractal Iterations
// ============================================

// Mandelbrot set: z = z² + c, where c is the pixel coordinate
vec3 mandelbrot(vec2 c, int maxIter) {
    vec2 z = vec2(0.0);
    int iter = 0;
    
    // Optimized loop with early bailout at 256 for performance
    for (int i = 0; i < 256; i++) {
        if (i >= maxIter) break;
        if (dot(z, z) > 4.0) break;
        
        // z = z² + c (optimized: single temp variable)
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        iter++;
    }
    
    if (iter >= maxIter) {
        // Inside the set - use gradient based on final z
        float interior = length(z) * 0.1;
        return mix(uColor1 * 0.15, uColor1 * 0.3, interior);
    }
    
    // Smooth coloring using escape time algorithm
    float smoothIter = float(iter) - log2(log2(dot(z, z))) + 4.0;
    float t = smoothIter / float(maxIter);
    
    return palette(t * 3.0, int(uColorPalette + 0.5));
}

// Julia set: z = z² + c, where c is a constant and z starts at pixel coordinate
vec3 juliaSet(vec2 z, vec2 c, int maxIter) {
    int iter = 0;
    
    for (int i = 0; i < 256; i++) {
        if (i >= maxIter) break;
        if (dot(z, z) > 4.0) break;
        
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        iter++;
    }
    
    if (iter >= maxIter) {
        float interior = length(z) * 0.1;
        return mix(uColor1 * 0.15, uColor1 * 0.3, interior);
    }
    
    float smoothIter = float(iter) - log2(log2(dot(z, z))) + 4.0;
    float t = smoothIter / float(maxIter);
    
    return palette(t * 3.0, int(uColorPalette + 0.5));
}

// Burning Ship: z = (|Re(z)| + i|Im(z)|)² + c
vec3 burningShip(vec2 c, int maxIter) {
    vec2 z = vec2(0.0);
    int iter = 0;
    
    for (int i = 0; i < 256; i++) {
        if (i >= maxIter) break;
        if (dot(z, z) > 4.0) break;
        
        // Take absolute values before squaring (creates "burning" effect)
        z = abs(z);
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        iter++;
    }
    
    if (iter >= maxIter) {
        float interior = length(z) * 0.1;
        return mix(uColor1 * 0.15, uColor1 * 0.3, interior);
    }
    
    float smoothIter = float(iter) - log2(log2(dot(z, z))) + 4.0;
    float t = smoothIter / float(maxIter);
    
    return palette(t * 3.0, int(uColorPalette + 0.5));
}

// ============================================
// Main
// ============================================

void main() {
    vec2 uv = vUv;
    
    // Map UV to complex plane with zoom and pan
    vec2 center = vec2(uCenterX, uCenterY);
    float zoom = uZoom;
    
    // Aspect ratio correction
    vec2 c = (uv - 0.5) * 2.0;
    c /= zoom;
    c += center;
    
    // Mouse can set Julia constant when mouse is down
    vec2 juliaC = vec2(-0.4, 0.6);
    if (uMouseDown > 0.5) {
        // Map mouse position to interesting Julia constants
        juliaC = (uMouse - 0.5) * 1.5;
    } else {
        // Animate Julia constant
        float t = uTime * 0.2;
        juliaC = vec2(
            sin(t) * 0.4 + cos(t * 0.7) * 0.3,
            cos(t) * 0.4 + sin(t * 0.5) * 0.3
        );
    }
    
    // Get iterations
    int maxIter = int(uIterations);
    
    // Select fractal type
    int fractalType = int(uFractalType + 0.5);
    vec3 color;
    
    if (fractalType == 0) {
        color = mandelbrot(c, maxIter);
    } else if (fractalType == 1) {
        color = juliaSet(c, juliaC, maxIter);
    } else {
        color = burningShip(c, maxIter);
    }
    
    // Add subtle glow effect at edges
    float edge = length(fwidth(color)) * 10.0;
    color += edge * 0.1;
    
    // Mouse position indicator for Julia constant
    if (uMouseDown > 0.5 && fractalType == 1) {
        float mouseGlow = smoothstep(0.05, 0.0, length(uv - uMouse));
        color += vec3(1.0, 0.5, 0.0) * mouseGlow;
    }
    
    // Tone mapping
    color = color / (color + vec3(0.5)) * 1.2;
    
    gl_FragColor = vec4(color, 1.0);
}
