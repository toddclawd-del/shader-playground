varying vec2 vUv;

uniform float uTime;
uniform float uScale;
uniform float uAnimSpeed;
uniform float uWaveCount;
uniform float uWaveAmplitude;
uniform float uWaveSteepness;
uniform float uRefractiveIndex;
uniform float uWaterDepth;
uniform float uCausticIntensity;
uniform float uCausticSharpness;
uniform float uVisualization;
uniform float uShowWaves;
uniform float uColorMix;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uColor3;
uniform vec3 uBackgroundColor;

#define PI 3.14159265359
#define TAU 6.28318530718

// ============================================
// Hash functions for wave randomization
// ============================================

float hash11(float p) {
    p = fract(p * 0.1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

vec2 hash21(float p) {
    vec3 p3 = fract(vec3(p) * vec3(0.1031, 0.1030, 0.0973));
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.xx + p3.yz) * p3.zy);
}

// ============================================
// Wave Functions
// ============================================

// Single Gerstner wave contribution
// Returns: vec3(x_displacement, y_displacement, height)
vec3 gerstnerWave(vec2 position, float time, vec2 direction, float frequency, float amplitude, float steepness) {
    // Phase speed (how fast wave travels)
    float phase = sqrt(9.81 * frequency);  // Deep water dispersion relation
    
    // Wave position
    float theta = dot(direction, position) * frequency + time * phase;
    
    // Steepness controls circular motion of water particles
    float s = sin(theta);
    float c = cos(theta);
    
    // Gerstner wave: particles move in circles, not just up/down
    // This creates the characteristic sharp crests and flat troughs
    float Q = steepness / (frequency * amplitude * uWaveCount);
    Q = clamp(Q, 0.0, 1.0);
    
    return vec3(
        Q * amplitude * direction.x * c,  // x displacement
        Q * amplitude * direction.y * c,  // y displacement (we use as z in 2D top-down view)
        amplitude * s                      // height
    );
}

// Sum multiple waves with different directions/frequencies
// Returns: vec4(total_displacement.xy, total_height, accumulated_info)
vec4 computeWaves(vec2 p, float time) {
    vec3 totalWave = vec3(0.0);
    
    float waveCount = floor(uWaveCount);
    float baseFreq = 1.0;
    float baseAmp = uWaveAmplitude;
    
    for (float i = 0.0; i < 8.0; i++) {
        if (i >= waveCount) break;
        
        // Pseudo-random direction for each wave
        float angle = hash11(i * 127.1) * TAU;
        vec2 dir = vec2(cos(angle), sin(angle));
        
        // Frequency increases, amplitude decreases for each octave
        float freq = baseFreq * pow(1.4, i);
        float amp = baseAmp * pow(0.6, i);
        
        // Add wave contribution
        totalWave += gerstnerWave(p, time, dir, freq, amp, uWaveSteepness);
    }
    
    return vec4(totalWave, length(totalWave.xy));
}

// ============================================
// Normal Calculation via Finite Differences
// ============================================

vec3 computeNormal(vec2 p, float time, float epsilon) {
    // Sample height at neighboring points
    float h0 = computeWaves(p, time).z;
    float hx = computeWaves(p + vec2(epsilon, 0.0), time).z;
    float hy = computeWaves(p + vec2(0.0, epsilon), time).z;
    
    // Compute gradient (slope in x and y)
    float dhdx = (hx - h0) / epsilon;
    float dhdy = (hy - h0) / epsilon;
    
    // Normal is perpendicular to the tangent plane
    // For a height field z = h(x,y), normal = normalize(-dh/dx, -dh/dy, 1)
    return normalize(vec3(-dhdx, -dhdy, 1.0));
}

// ============================================
// Caustic Calculation
// ============================================

// Snell's Law: sin(θ1)/sin(θ2) = n2/n1
// For light entering water from air: n_air ≈ 1.0, n_water ≈ 1.33
vec3 refractRay(vec3 incident, vec3 normal, float eta) {
    float cosI = -dot(normal, incident);
    float sinT2 = eta * eta * (1.0 - cosI * cosI);
    
    // Total internal reflection check
    if (sinT2 > 1.0) {
        return reflect(incident, normal);
    }
    
    float cosT = sqrt(1.0 - sinT2);
    return eta * incident + (eta * cosI - cosT) * normal;
}

// Compute where refracted ray hits the pool floor
vec2 computeCausticPosition(vec2 surfacePos, vec3 normal, float depth) {
    // Light comes from above (sun direction)
    vec3 lightDir = normalize(vec3(0.0, 0.0, -1.0));  // Straight down
    
    // Refract the light through the water surface
    float eta = 1.0 / uRefractiveIndex;  // air to water
    vec3 refracted = refractRay(lightDir, normal, eta);
    
    // Trace ray from surface down to floor
    // Surface is at z=0, floor is at z=-depth
    float t = depth / max(-refracted.z, 0.001);
    
    return surfacePos + refracted.xy * t;
}

// Main caustic intensity calculation
// This simulates light concentration by measuring how much light rays converge
float computeCausticIntensity(vec2 floorPos, float time) {
    float intensity = 0.0;
    
    // Sample multiple surface points and trace rays to the floor
    // Count how many rays land near our floor position
    float samples = 16.0;
    float accumulator = 0.0;
    
    // Search radius on the surface
    float searchRadius = 0.5 / uScale;
    
    for (float i = 0.0; i < 16.0; i++) {
        // Spiral sampling pattern
        float angle = i * 2.39996322; // Golden angle
        float r = sqrt(i / samples) * searchRadius;
        vec2 offset = vec2(cos(angle), sin(angle)) * r;
        
        // Surface position to sample
        vec2 surfacePos = floorPos + offset;
        
        // Get wave normal at this surface point
        vec3 normal = computeNormal(surfacePos * uScale, time, 0.01);
        
        // Where does light from this surface point land on the floor?
        vec2 landingPos = computeCausticPosition(surfacePos, normal, uWaterDepth);
        
        // How close is it to our current floor position?
        float dist = length(landingPos - floorPos);
        
        // Accumulate based on proximity
        // Closer rays = more light concentration = brighter caustic
        float contribution = exp(-dist * dist * uCausticSharpness * 100.0);
        accumulator += contribution;
    }
    
    // Normalize and boost
    intensity = accumulator / samples;
    intensity = pow(intensity, 0.5) * uCausticIntensity;
    
    return intensity;
}

// ============================================
// Alternative: Fast Fake Caustics
// (Interference pattern approach - cheaper but still looks great)
// ============================================

float fakeCaustics(vec2 p, float time) {
    float caustic = 0.0;
    
    // Multiple overlapping wave patterns create caustic-like interference
    for (float i = 0.0; i < 5.0; i++) {
        float angle = hash11(i * 73.7) * TAU;
        float freq = 2.0 + i * 1.5;
        float speed = 0.3 + hash11(i * 17.3) * 0.4;
        
        vec2 dir = vec2(cos(angle), sin(angle));
        float wave = sin(dot(p * uScale, dir) * freq + time * speed);
        
        // Square and shift to get bright lines
        caustic += pow(max(wave, 0.0), 2.0);
    }
    
    // Voronoi-like brightening for extra realism
    vec2 fp = fract(p * uScale * 2.0 + time * 0.1);
    float voronoi = length(fp - 0.5) * 2.0;
    caustic *= 0.8 + 0.4 * smoothstep(0.5, 0.0, voronoi);
    
    return caustic * uCausticIntensity * 0.3;
}

// ============================================
// Visualization Modes
// ============================================

vec3 visualizeWaves(vec2 p, float time) {
    vec4 waveData = computeWaves(p * uScale, time);
    
    // Height as color
    float h = waveData.z * 2.0 + 0.5;
    return mix(uColor1, uColor2, h);
}

vec3 visualizeNormals(vec2 p, float time) {
    vec3 normal = computeNormal(p * uScale, time, 0.01);
    
    // Map normal to color (x,y,z -> r,g,b)
    return normal * 0.5 + 0.5;
}

// ============================================
// Color Palette
// ============================================

vec3 causticPalette(float t, float intensity) {
    // Underwater light tends toward cyan/blue-green
    vec3 baseColor = uBackgroundColor;
    vec3 brightColor = mix(uColor1, uColor2, t);
    vec3 peakColor = uColor3;
    
    // Blend based on intensity
    vec3 color = baseColor;
    color = mix(color, brightColor, smoothstep(0.2, 0.5, intensity));
    color = mix(color, peakColor, smoothstep(0.7, 1.0, intensity));
    
    return color;
}

// ============================================
// Main
// ============================================

void main() {
    vec2 uv = vUv;
    vec2 p = uv - 0.5;  // Center the coordinates
    
    float time = uTime * uAnimSpeed;
    
    vec3 color;
    
    if (uVisualization < 0.5) {
        // ========================================
        // Mode 0: Full Caustic Simulation
        // ========================================
        
        // Compute caustic intensity at this floor position
        float intensity = computeCausticIntensity(p, time);
        
        // Add fake caustics layer for extra detail
        float fakeDetail = fakeCaustics(p, time) * 0.3;
        intensity += fakeDetail;
        
        // Color based on intensity
        color = causticPalette(uv.x + uv.y * 0.5, intensity);
        
        // Optionally show the wave surface overlay
        if (uShowWaves > 0.5) {
            vec4 waveData = computeWaves(p * uScale, time);
            float waveVis = waveData.z * 0.2 + 0.5;
            vec3 waveColor = mix(uColor1, uColor2, waveVis);
            color = mix(color, waveColor, 0.2 * uShowWaves);
        }
        
    } else if (uVisualization < 1.5) {
        // ========================================
        // Mode 1: Fast Fake Caustics Only
        // (More stylized, very performant)
        // ========================================
        
        float intensity = fakeCaustics(p, time);
        
        // Add some wave-based variation
        vec4 waveData = computeWaves(p * uScale, time);
        intensity *= 0.8 + 0.4 * (waveData.z + 0.5);
        
        color = causticPalette(uv.x * 0.5 + time * 0.05, intensity);
        
    } else if (uVisualization < 2.5) {
        // ========================================
        // Mode 2: Wave Height Visualization
        // (Educational: see the wave field)
        // ========================================
        
        color = visualizeWaves(p, time);
        
    } else {
        // ========================================
        // Mode 3: Normal Visualization
        // (Educational: see surface normals)
        // ========================================
        
        color = visualizeNormals(p, time);
    }
    
    // Apply color mixing with user colors
    vec3 tintedColor = mix(color, color * uColor1, uColorMix * 0.5);
    color = mix(color, tintedColor, uColorMix);
    
    // Subtle vignette
    float vignette = 1.0 - 0.3 * length(p);
    color *= vignette;
    
    // Gamma correction
    color = pow(color, vec3(0.9));
    
    gl_FragColor = vec4(color, 1.0);
}
