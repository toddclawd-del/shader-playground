/*
 * Gerstner Wave Vertex Shader
 * 
 * Physics-based ocean waves. Unlike simple sine displacement,
 * Gerstner waves move vertices in circular orbits, creating
 * realistic sharp crests and smooth troughs.
 * 
 * The key insight: water particles don't just move up/down,
 * they trace circles. The horizontal component creates the
 * characteristic wave shape.
 */

varying vec2 vUv;
varying vec3 vPosition;
varying vec3 vNormal;
varying float vFoam;
varying float vDepth;

uniform float uTime;
uniform float uSpeed;

// Wave 1 - Primary swell
uniform float uWave1Amp;
uniform float uWave1Freq;
uniform float uWave1Steep;
uniform vec2 uWave1Dir;

// Wave 2 - Secondary swell
uniform float uWave2Amp;
uniform float uWave2Freq;
uniform float uWave2Steep;
uniform vec2 uWave2Dir;

// Wave 3 - Chop/detail
uniform float uWave3Amp;
uniform float uWave3Freq;
uniform float uWave3Steep;
uniform vec2 uWave3Dir;

// Wave 4 - More detail
uniform float uWave4Amp;
uniform float uWave4Freq;
uniform float uWave4Steep;
uniform vec2 uWave4Dir;

// Foam threshold
uniform float uFoamThreshold;

/*
 * Gerstner wave function
 * 
 * @param pos - horizontal position
 * @param amp - amplitude (wave height)
 * @param freq - frequency (wave spacing)
 * @param steep - steepness (0-1, controls sharpness)
 * @param dir - wave direction (normalized)
 * @param time - animation time
 * 
 * Returns vec3: (horizontal displacement x, vertical displacement, horizontal displacement y)
 */
vec3 gerstnerWave(vec2 pos, float amp, float freq, float steep, vec2 dir, float time) {
    // Normalize direction
    dir = normalize(dir);
    
    // Phase: how far along the wave we are
    float phase = dot(dir, pos) * freq + time;
    
    // Steepness factor (Q in Gerstner equations)
    // Clamped to avoid loops (when Q > 1/(freq*amp))
    float Q = steep / (freq * amp + 0.001);
    Q = min(Q, 0.9); // Safety clamp
    
    // Horizontal displacement (what makes Gerstner special)
    float cosPhase = cos(phase);
    float sinPhase = sin(phase);
    
    float x = Q * amp * dir.x * cosPhase;
    float y = amp * sinPhase;
    float z = Q * amp * dir.y * cosPhase;
    
    return vec3(x, y, z);
}

/*
 * Calculate normal contribution from a Gerstner wave
 * Using partial derivatives of the wave function
 */
vec3 gerstnerNormal(vec2 pos, float amp, float freq, float steep, vec2 dir, float time) {
    dir = normalize(dir);
    float phase = dot(dir, pos) * freq + time;
    float Q = steep / (freq * amp + 0.001);
    Q = min(Q, 0.9);
    
    float cosPhase = cos(phase);
    float sinPhase = sin(phase);
    
    // Partial derivatives for normal calculation
    float WA = freq * amp;
    
    float nx = dir.x * WA * cosPhase;
    float ny = Q * WA * sinPhase;
    float nz = dir.y * WA * cosPhase;
    
    return vec3(nx, ny, nz);
}

void main() {
    vUv = uv;
    
    float time = uTime * uSpeed;
    vec2 pos = position.xz;
    
    // Accumulate displacement from all waves
    vec3 displacement = vec3(0.0);
    
    displacement += gerstnerWave(pos, uWave1Amp, uWave1Freq, uWave1Steep, uWave1Dir, time);
    displacement += gerstnerWave(pos, uWave2Amp, uWave2Freq, uWave2Steep, uWave2Dir, time * 1.1);
    displacement += gerstnerWave(pos, uWave3Amp, uWave3Freq, uWave3Steep, uWave3Dir, time * 0.9);
    displacement += gerstnerWave(pos, uWave4Amp, uWave4Freq, uWave4Steep, uWave4Dir, time * 1.2);
    
    // Apply displacement
    vec3 newPosition = position;
    newPosition.x += displacement.x;
    newPosition.y += displacement.y;
    newPosition.z += displacement.z;
    
    // Calculate normal from wave contributions
    vec3 normalSum = vec3(0.0);
    normalSum += gerstnerNormal(pos, uWave1Amp, uWave1Freq, uWave1Steep, uWave1Dir, time);
    normalSum += gerstnerNormal(pos, uWave2Amp, uWave2Freq, uWave2Steep, uWave2Dir, time * 1.1);
    normalSum += gerstnerNormal(pos, uWave3Amp, uWave3Freq, uWave3Steep, uWave3Dir, time * 0.9);
    normalSum += gerstnerNormal(pos, uWave4Amp, uWave4Freq, uWave4Steep, uWave4Dir, time * 1.2);
    
    // Reconstruct normal
    vec3 calculatedNormal = normalize(vec3(-normalSum.x, 1.0 - normalSum.y, -normalSum.z));
    vNormal = calculatedNormal;
    
    // Calculate foam based on wave height and steepness
    // Foam appears at wave crests where displacement.y is high
    float heightFactor = displacement.y / (uWave1Amp + uWave2Amp + uWave3Amp + uWave4Amp + 0.001);
    
    // Also factor in curvature (normal deviation from vertical)
    float curvature = 1.0 - dot(calculatedNormal, vec3(0.0, 1.0, 0.0));
    
    vFoam = smoothstep(uFoamThreshold - 0.1, uFoamThreshold + 0.2, heightFactor + curvature * 0.5);
    
    // Depth for coloring (based on original Y, not displaced)
    vDepth = displacement.y;
    
    vPosition = newPosition;
    
    gl_Position = projectionMatrix * modelViewMatrix * vec4(newPosition, 1.0);
}
