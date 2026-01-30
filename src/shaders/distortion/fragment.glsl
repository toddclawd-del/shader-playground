varying vec2 vUv;

uniform float uTime;
uniform float uDistortionType; // 0=ripple, 1=wave, 2=twist, 3=bulge
uniform float uStrength;
uniform float uFrequency;
uniform float uSpeed;
uniform float uMouseRadius;
uniform vec2 uMouse;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uBackgroundColor;

#define PI 3.14159265359

// ============================================
// Noise for organic patterns
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

// ============================================
// Distortion Functions
// ============================================

// Ripple distortion - concentric waves from center/mouse
vec2 rippleDistortion(vec2 uv, vec2 center, float time) {
    vec2 toCenter = uv - center;
    float dist = length(toCenter);
    
    // Create expanding ripples
    float ripple = sin(dist * uFrequency - time * uSpeed * 5.0);
    
    // Fade ripple with distance
    float fade = smoothstep(1.0, 0.0, dist);
    
    // Mouse influence creates stronger ripple near cursor
    float mouseNear = smoothstep(uMouseRadius + 0.2, uMouseRadius, length(uv - uMouse));
    fade = max(fade, mouseNear);
    
    // Distort along the radial direction
    vec2 offset = normalize(toCenter) * ripple * uStrength * fade * 0.1;
    
    return uv + offset;
}

// Wave distortion - sinusoidal waves
vec2 waveDistortion(vec2 uv, float time) {
    float waveX = sin(uv.y * uFrequency + time * uSpeed) * uStrength * 0.1;
    float waveY = sin(uv.x * uFrequency * 1.3 + time * uSpeed * 0.7) * uStrength * 0.1;
    
    // Add mouse influence
    vec2 toMouse = uv - uMouse;
    float mouseDist = length(toMouse);
    float mouseEffect = smoothstep(uMouseRadius + 0.3, uMouseRadius, mouseDist);
    
    waveX += sin(mouseDist * 20.0 - time * 3.0) * mouseEffect * uStrength * 0.05;
    waveY += cos(mouseDist * 20.0 - time * 3.0) * mouseEffect * uStrength * 0.05;
    
    return uv + vec2(waveX, waveY);
}

// Twist distortion - rotational swirl
vec2 twistDistortion(vec2 uv, vec2 center, float time) {
    vec2 toCenter = uv - center;
    float dist = length(toCenter);
    float angle = atan(toCenter.y, toCenter.x);
    
    // Twist amount decreases with distance
    float twist = uStrength * (1.0 - dist) * sin(time * uSpeed * 0.5);
    
    // Add mouse swirl
    vec2 toMouse = uv - uMouse;
    float mouseDist = length(toMouse);
    float mouseSwirl = smoothstep(uMouseRadius + 0.3, 0.0, mouseDist);
    twist += mouseSwirl * uStrength * 2.0;
    
    // Apply rotation
    float newAngle = angle + twist;
    vec2 rotated = vec2(cos(newAngle), sin(newAngle)) * dist;
    
    return center + rotated;
}

// Bulge distortion - magnification effect
vec2 bulgeDistortion(vec2 uv, vec2 center, float time) {
    vec2 toCenter = uv - center;
    float dist = length(toCenter);
    
    // Pulsing bulge
    float pulse = sin(time * uSpeed) * 0.5 + 0.5;
    float bulgeAmount = uStrength * pulse;
    
    // Add mouse bulge
    vec2 toMouse = uv - uMouse;
    float mouseDist = length(toMouse);
    float mouseBulge = smoothstep(uMouseRadius + 0.2, 0.0, mouseDist);
    bulgeAmount += mouseBulge * uStrength;
    
    // Bulge formula: push pixels outward from center
    float factor = 1.0 + bulgeAmount * (1.0 - dist * 2.0);
    factor = max(factor, 0.5);
    
    return center + toCenter / factor;
}

// ============================================
// Visualization
// ============================================

vec3 createPattern(vec2 uv, float time) {
    // Create a grid pattern to visualize distortion
    vec2 grid = fract(uv * uFrequency * 2.0);
    
    // Checkerboard
    float check = step(0.5, grid.x) * step(0.5, grid.y) +
                  (1.0 - step(0.5, grid.x)) * (1.0 - step(0.5, grid.y));
    
    // Smooth lines
    float lineX = smoothstep(0.02, 0.0, abs(grid.x - 0.5));
    float lineY = smoothstep(0.02, 0.0, abs(grid.y - 0.5));
    float lines = max(lineX, lineY);
    
    // Add circular patterns
    float circles = length(fract(uv * uFrequency) - 0.5);
    circles = smoothstep(0.3, 0.28, circles);
    
    // Combine patterns
    vec3 color = mix(uBackgroundColor, uColor1, check * 0.3);
    color = mix(color, uColor2, lines * 0.8);
    color = mix(color, uColor1, circles * 0.5);
    
    // Add noise texture
    float n = noise(uv * 50.0 + time);
    color += n * 0.05;
    
    return color;
}

// ============================================
// Main
// ============================================

void main() {
    vec2 uv = vUv;
    vec2 center = vec2(0.5);
    float time = uTime;
    
    // Apply selected distortion type
    vec2 distortedUv = uv;
    
    int distType = int(uDistortionType + 0.5);
    
    if (distType == 0) {
        // Ripple
        distortedUv = rippleDistortion(uv, center, time);
    } else if (distType == 1) {
        // Wave
        distortedUv = waveDistortion(uv, time);
    } else if (distType == 2) {
        // Twist
        distortedUv = twistDistortion(uv, center, time);
    } else {
        // Bulge
        distortedUv = bulgeDistortion(uv, center, time);
    }
    
    // Create pattern with distorted UVs
    vec3 color = createPattern(distortedUv, time);
    
    // Add highlight at mouse position
    float mouseGlow = smoothstep(uMouseRadius, 0.0, length(uv - uMouse));
    color += uColor2 * mouseGlow * 0.3;
    
    // Subtle vignette
    float vignette = 1.0 - length(vUv - 0.5) * 0.4;
    color *= vignette;
    
    gl_FragColor = vec4(color, 1.0);
}
