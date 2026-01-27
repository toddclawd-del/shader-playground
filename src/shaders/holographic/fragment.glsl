varying vec2 vUv;
varying vec3 vPosition;
varying vec3 vNormal;

uniform float uTime;
uniform vec2 uMouse;
uniform float uFresnelPower;
uniform float uFresnelIntensity;
uniform float uRainbowSpeed;
uniform float uRainbowScale;
uniform float uRainbowSpread;
uniform float uSaturation;
uniform float uBrightness;
uniform float uShiftAmount;
uniform float uNoiseAmount;
uniform float uNoiseScale;
uniform float uScanlines;
uniform float uScanlineSpeed;
uniform vec3 uBaseColor;
uniform float uBaseColorMix;
uniform float uMouseReactive;
uniform float uPulseSpeed;
uniform float uPulseAmount;

// ============================================
// Color utilities
// ============================================

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

// ============================================
// Noise
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
// Holographic color generation
// ============================================

vec3 holographicColor(vec2 uv, float time, float angle) {
    // Base hue from position and time
    float hue = uv.x * uRainbowScale + uv.y * uRainbowScale * 0.5;
    hue += time * uRainbowSpeed;
    
    // Add angle-based shift (simulates view-dependent iridescence)
    hue += angle * uShiftAmount;
    
    // Add noise variation
    if (uNoiseAmount > 0.0) {
        float n = fbm(uv * uNoiseScale + time * 0.5);
        hue += n * uNoiseAmount;
    }
    
    // Pulse effect
    if (uPulseAmount > 0.0) {
        float pulse = sin(time * uPulseSpeed + length(uv - 0.5) * 10.0);
        hue += pulse * uPulseAmount * 0.1;
    }
    
    // Create rainbow spread
    vec3 color1 = hsv2rgb(vec3(fract(hue), uSaturation, uBrightness));
    vec3 color2 = hsv2rgb(vec3(fract(hue + uRainbowSpread), uSaturation, uBrightness));
    vec3 color3 = hsv2rgb(vec3(fract(hue + uRainbowSpread * 2.0), uSaturation, uBrightness));
    
    // Blend based on position
    float blend = sin(uv.x * 20.0 + uv.y * 15.0 + time * 2.0) * 0.5 + 0.5;
    vec3 rainbow = mix(mix(color1, color2, blend), color3, sin(blend * 3.14159) * 0.5 + 0.5);
    
    return rainbow;
}

// ============================================
// Main
// ============================================

void main() {
    vec2 uv = vUv;
    float time = uTime;
    
    // Calculate view angle for iridescence
    vec3 viewDir = normalize(cameraPosition - vPosition);
    float viewAngle = dot(viewDir, vNormal);
    
    // Fresnel effect (stronger color at glancing angles)
    float fresnel = pow(1.0 - abs(viewAngle), uFresnelPower);
    fresnel *= uFresnelIntensity;
    
    // Mouse interaction
    float mouseEffect = 0.0;
    if (uMouseReactive > 0.0) {
        vec2 mouseDir = uv - uMouse;
        float mouseDist = length(mouseDir);
        mouseEffect = (1.0 - smoothstep(0.0, 0.5, mouseDist)) * uMouseReactive;
        
        // Shift hue based on mouse proximity
        time += mouseEffect * 2.0;
    }
    
    // Generate holographic color
    vec3 holoColor = holographicColor(uv, time, viewAngle + mouseEffect);
    
    // Apply fresnel - more color at edges
    vec3 color = holoColor * (0.5 + fresnel * 0.5);
    
    // Add specular-like highlights
    float highlight = pow(fresnel, 3.0);
    color += vec3(1.0) * highlight * 0.3;
    
    // Scanlines (optional retro effect)
    if (uScanlines > 0.0) {
        float scanline = sin((uv.y + time * uScanlineSpeed * 0.1) * 200.0);
        scanline = scanline * 0.5 + 0.5;
        color *= 1.0 - scanline * uScanlines * 0.2;
    }
    
    // Mix with base color
    color = mix(color, uBaseColor * holoColor, uBaseColorMix);
    
    // Add shimmering highlights
    float shimmer = noise(uv * 50.0 + time * 3.0);
    shimmer = pow(shimmer, 5.0);
    color += vec3(1.0) * shimmer * 0.15;
    
    // Subtle rainbow edge glow
    float edgeDist = min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y));
    float edgeGlow = smoothstep(0.1, 0.0, edgeDist);
    vec3 edgeColor = hsv2rgb(vec3(fract(time * 0.1 + edgeDist * 2.0), 0.8, 1.0));
    color += edgeColor * edgeGlow * 0.3;
    
    gl_FragColor = vec4(color, 1.0);
}
