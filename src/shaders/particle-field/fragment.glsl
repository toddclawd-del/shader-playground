varying vec2 vUv;

uniform float uTime;
uniform float uParticleCount;
uniform float uParticleSize;
uniform float uSpeed;
uniform float uMouseForce; // -1 to 1, negative = repel, positive = attract
uniform float uColorMode; // 0=solid, 1=velocity, 2=position
uniform float uShape; // 0=points, 1=circles, 2=squares
uniform vec2 uMouse;
uniform float uMouseDown;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uBackgroundColor;

#define PI 3.14159265359
#define MAX_PARTICLES 100.0

// ============================================
// Hash Functions for Particle Positions
// ============================================

float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

vec2 hash2(float n) {
    return fract(sin(vec2(n, n + 1.0)) * vec2(43758.5453123, 22578.1459123));
}

vec3 hash3(float n) {
    return fract(sin(vec3(n, n + 1.0, n + 2.0)) * vec3(43758.5453123, 22578.1459123, 19642.3490423));
}

// ============================================
// Noise for Particle Movement
// ============================================

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    float n = i.x + i.y * 57.0;
    return mix(
        mix(hash(n), hash(n + 1.0), f.x),
        mix(hash(n + 57.0), hash(n + 58.0), f.x),
        f.y
    );
}

// Curl noise for organic motion
vec2 curlNoise(vec2 p) {
    float eps = 0.01;
    float n1 = noise(p + vec2(eps, 0.0));
    float n2 = noise(p - vec2(eps, 0.0));
    float n3 = noise(p + vec2(0.0, eps));
    float n4 = noise(p - vec2(0.0, eps));
    
    return vec2(n3 - n4, -(n1 - n2)) / (2.0 * eps);
}

// ============================================
// Particle Simulation
// ============================================

// Get particle position for given ID at current time
vec2 getParticlePos(float id, float time) {
    // Initial random position
    vec2 basePos = hash2(id * 17.0);
    
    // Add noise-based movement
    float speed = uSpeed * 0.2;
    vec2 noiseOffset = curlNoise(basePos * 3.0 + time * speed) * 0.3;
    
    // Circular orbit component
    float angle = time * speed * (0.5 + hash(id) * 0.5) + hash(id + 100.0) * PI * 2.0;
    float radius = 0.1 + hash(id + 200.0) * 0.15;
    vec2 orbit = vec2(cos(angle), sin(angle)) * radius;
    
    vec2 pos = basePos + noiseOffset + orbit * 0.3;
    
    // Mouse interaction
    vec2 toMouse = uMouse - pos;
    float mouseDist = length(toMouse);
    float mouseInfluence = smoothstep(0.4, 0.0, mouseDist);
    
    // Apply force (attract or repel based on uMouseForce sign)
    pos += normalize(toMouse) * mouseInfluence * uMouseForce * 0.15;
    
    // Stronger effect when mouse is down
    if (uMouseDown > 0.5) {
        pos += normalize(toMouse) * mouseInfluence * uMouseForce * 0.1;
    }
    
    // Wrap around edges
    pos = fract(pos);
    
    return pos;
}

// Get particle velocity (for color mode)
vec2 getParticleVelocity(float id, float time) {
    vec2 pos1 = getParticlePos(id, time);
    vec2 pos2 = getParticlePos(id, time - 0.016);
    return (pos1 - pos2) * 60.0; // Approximate velocity
}

// ============================================
// Particle Rendering
// ============================================

// Draw a single particle
float drawParticle(vec2 uv, vec2 particlePos, float size) {
    vec2 diff = uv - particlePos;
    float dist = length(diff);
    
    int shape = int(uShape + 0.5);
    
    if (shape == 0) {
        // Points (soft gaussian)
        return exp(-dist * dist / (size * size * 0.5));
    } else if (shape == 1) {
        // Circles
        return smoothstep(size, size * 0.8, dist);
    } else {
        // Squares
        vec2 absDiff = abs(diff);
        float maxDist = max(absDiff.x, absDiff.y);
        return smoothstep(size, size * 0.8, maxDist);
    }
}

// Get particle color based on mode
vec3 getParticleColor(float id, vec2 pos, vec2 velocity) {
    int mode = int(uColorMode + 0.5);
    
    if (mode == 0) {
        // Solid color - interpolate between colors based on ID
        return mix(uColor1, uColor2, hash(id * 7.0));
    } else if (mode == 1) {
        // Velocity-based color
        float speed = length(velocity);
        return mix(uColor1, uColor2, clamp(speed * 5.0, 0.0, 1.0));
    } else {
        // Position-based color
        return mix(uColor1, uColor2, (pos.x + pos.y) * 0.5);
    }
}

// ============================================
// Main
// ============================================

void main() {
    vec2 uv = vUv;
    float time = uTime;
    
    // Start with background
    vec3 color = uBackgroundColor;
    
    // Particle size in UV space
    float size = uParticleSize * 0.01;
    
    // Number of particles to render
    int numParticles = int(min(uParticleCount, MAX_PARTICLES));
    
    // Render each particle
    for (int i = 0; i < 100; i++) {
        if (i >= numParticles) break;
        
        float id = float(i);
        
        // Get particle state
        vec2 pos = getParticlePos(id, time);
        vec2 vel = getParticleVelocity(id, time);
        
        // Draw particle
        float particle = drawParticle(uv, pos, size);
        
        // Get particle color
        vec3 particleColor = getParticleColor(id, pos, vel);
        
        // Add glow
        float glow = drawParticle(uv, pos, size * 2.0) * 0.3;
        
        // Composite
        color = mix(color, particleColor, particle);
        color += particleColor * glow * 0.5;
    }
    
    // Add subtle trails (motion blur effect)
    for (int i = 0; i < 100; i++) {
        if (i >= numParticles) break;
        
        float id = float(i);
        for (int j = 1; j < 5; j++) {
            float trailTime = time - float(j) * 0.02;
            vec2 trailPos = getParticlePos(id, trailTime);
            float trail = drawParticle(uv, trailPos, size * 0.5);
            vec3 trailColor = getParticleColor(id, trailPos, vec2(0.0));
            color += trailColor * trail * 0.1 / float(j);
        }
    }
    
    // Mouse glow
    float mouseGlow = smoothstep(0.15, 0.0, length(uv - uMouse));
    vec3 glowColor = mix(uColor1, uColor2, 0.5);
    color += glowColor * mouseGlow * 0.2 * (1.0 + uMouseDown);
    
    // Tone mapping
    color = color / (color + vec3(1.0)) * 1.2;
    
    gl_FragColor = vec4(color, 1.0);
}
