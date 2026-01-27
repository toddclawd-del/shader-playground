varying vec2 vUv;

uniform float uTime;
uniform float uRippleSpeed;
uniform float uRippleDecay;
uniform float uRefraction;
uniform float uWaveFreq;
uniform float uWaveAmp;
uniform float uRippleSize;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uBackgroundColor;
uniform float uReflectivity;

// Mouse uniforms (auto-injected)
uniform vec2 uMouse;
uniform vec2 uMouseVelocity;
uniform float uMouseDown;

#define PI 3.14159265

// Simple noise for water texture
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

// Ripple function - creates expanding circular waves
float ripple(vec2 uv, vec2 center, float time, float birthTime) {
    float age = time - birthTime;
    if (age < 0.0) return 0.0;

    float dist = length(uv - center);
    float radius = age * uRippleSpeed;

    // Ripple expands outward
    float wave = sin((dist - radius) * 20.0 / uRippleSize) * 0.5 + 0.5;

    // Fade based on distance from expanding edge
    float edgeFade = smoothstep(radius + 0.1, radius, dist) * smoothstep(radius - 0.3, radius, dist);

    // Decay over time
    float timeFade = exp(-age * uRippleDecay);

    return wave * edgeFade * timeFade;
}

// Continuous ripple following mouse
float mouseRipple(vec2 uv, vec2 mousePos, float time) {
    float dist = length(uv - mousePos);

    // Create continuous waves emanating from mouse
    float wave = sin(dist * 30.0 / uRippleSize - time * uRippleSpeed * 5.0);

    // Fade with distance
    float fade = exp(-dist * 3.0);

    // Velocity influence - stronger ripples when moving
    float velocity = length(uMouseVelocity);
    float velocityFade = smoothstep(0.0, 0.5, velocity);

    return wave * fade * (0.2 + velocityFade * 0.8);
}

void main() {
    vec2 uv = vUv;
    vec2 centeredUv = uv - 0.5;
    float time = uTime;

    // Base wave motion
    float baseWave = 0.0;
    baseWave += sin(uv.x * uWaveFreq + time * 0.8) * uWaveAmp;
    baseWave += sin(uv.y * uWaveFreq * 0.7 + time * 0.6) * uWaveAmp * 0.8;
    baseWave += sin((uv.x + uv.y) * uWaveFreq * 0.5 + time * 0.4) * uWaveAmp * 0.6;

    // Add noise-based waves
    float noiseWave = fbm(uv * 5.0 + time * 0.2) * uWaveAmp * 0.5;

    // Mouse position ripple
    vec2 mousePos = uMouse;
    float mouseWave = mouseRipple(uv, mousePos, time);

    // Click ripple - stronger when mouse is down
    float clickWave = 0.0;
    if (uMouseDown > 0.5) {
        float clickDist = length(uv - mousePos);
        clickWave = sin(clickDist * 40.0 / uRippleSize - time * uRippleSpeed * 8.0);
        clickWave *= exp(-clickDist * 2.0);
        clickWave *= 0.5;
    }

    // Combine all waves
    float totalWave = baseWave + noiseWave + mouseWave * 0.3 + clickWave;

    // Calculate displacement for refraction
    vec2 displacement = vec2(
        totalWave * cos(time * 0.5 + uv.y * 10.0),
        totalWave * sin(time * 0.3 + uv.x * 10.0)
    ) * uRefraction * 0.02;

    vec2 distortedUv = uv + displacement;

    // Calculate surface normal approximation
    float h = totalWave;
    float hx = totalWave + sin((uv.x + 0.01) * uWaveFreq + time * 0.8) * uWaveAmp * 0.1;
    float hy = totalWave + sin((uv.y + 0.01) * uWaveFreq * 0.7 + time * 0.6) * uWaveAmp * 0.1;
    vec3 normal = normalize(vec3(h - hx, h - hy, 0.1));

    // Lighting
    vec3 lightDir = normalize(vec3(0.5, 0.5, 1.0));
    vec3 viewDir = vec3(0.0, 0.0, 1.0);

    // Diffuse
    float diff = max(dot(normal, lightDir), 0.0);

    // Specular (water highlights)
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32.0);

    // Fresnel effect
    float fresnel = pow(1.0 - max(dot(viewDir, normal), 0.0), 3.0);

    // Water color gradient based on depth simulation
    float depth = totalWave * 0.5 + 0.5;
    vec3 waterColor = mix(uColor1, uColor2, depth);

    // Add caustics-like pattern
    float caustics = fbm(distortedUv * 20.0 + time * 0.5);
    caustics = pow(caustics, 2.0) * 0.3;

    // Combine colors
    vec3 color = waterColor * (0.6 + diff * 0.4);
    color += vec3(1.0) * spec * uReflectivity;
    color += caustics * uColor1;
    color = mix(color, uBackgroundColor, fresnel * 0.3);

    // Edge darkening (vignette)
    float vignette = 1.0 - length(centeredUv) * 0.5;
    color *= vignette;

    // Add subtle ripple highlights
    float rippleHighlight = smoothstep(0.4, 0.6, mouseWave + clickWave);
    color += vec3(1.0) * rippleHighlight * 0.2;

    gl_FragColor = vec4(color, 1.0);
}
