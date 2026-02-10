/**
 * Gravitational Lensing
 * 
 * Simulates a black hole bending spacetime around it.
 * Light from background stars is deflected following the Einstein ring equation.
 * Features a photon sphere glow and optional accretion disc with Doppler shift.
 * 
 * Key techniques:
 * - Ray deflection based on Schwarzschild geometry (simplified)
 * - Procedural starfield background
 * - Photon sphere at r = 1.5 * Schwarzschild radius
 * - Accretion disc with relativistic Doppler shift
 * 
 * References:
 * - https://www.shadertoy.com/view/3dSyzD
 * - https://ebruneton.github.io/black_hole_shader/
 * - Interstellar's Gargantua (Kip Thorne's team)
 */

varying vec2 vUv;

uniform float uTime;

// Black Hole
uniform float uMass;
uniform vec3 uEventHorizonColor;

// Lensing
uniform float uLensStrength;
uniform float uPhotonSphereGlow;
uniform vec3 uGlowColor;

// Accretion Disc
uniform float uShowAccretionDisc;
uniform float uDiscInnerRadius;
uniform float uDiscOuterRadius;
uniform float uDiscSpeed;
uniform vec3 uDiscColorHot;
uniform vec3 uDiscColorCool;
uniform float uDopplerShift;

// Background
uniform float uStarfieldDensity;
uniform float uStarfieldSpeed;

// Camera
uniform float uViewAngle;
uniform float uOrbitSpeed;

#define PI 3.14159265359
#define TAU 6.28318530718

// ========================================
// NOISE & HASH FUNCTIONS
// ========================================

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float hash3(vec3 p) {
    return fract(sin(dot(p, vec3(127.1, 311.7, 74.7))) * 43758.5453);
}

vec2 hash2(vec2 p) {
    return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), 
                          dot(p, vec2(269.5, 183.3)))) * 43758.5453);
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

// ========================================
// STARFIELD
// ========================================

float starfield(vec2 uv) {
    float stars = 0.0;
    
    // Multiple layers of stars at different scales
    for (float i = 0.0; i < 3.0; i++) {
        float scale = 50.0 + i * 30.0;
        vec2 gridUV = uv * scale;
        vec2 gridId = floor(gridUV);
        vec2 gridLocal = fract(gridUV) - 0.5;
        
        // Random position within cell
        vec2 starPos = hash2(gridId) - 0.5;
        float dist = length(gridLocal - starPos * 0.8);
        
        // Star brightness varies
        float brightness = hash(gridId + i * 100.0);
        
        // Only show some stars based on density
        if (brightness > 1.0 - uStarfieldDensity) {
            // Star size and shape
            float starSize = 0.03 - i * 0.005;
            float star = smoothstep(starSize, 0.0, dist);
            
            // Twinkle
            float twinkle = sin(uTime * 3.0 + hash(gridId) * TAU) * 0.3 + 0.7;
            
            stars += star * brightness * twinkle;
        }
    }
    
    return clamp(stars, 0.0, 1.0);
}

// ========================================
// GRAVITATIONAL LENSING
// ========================================

vec2 gravitationalDeflection(vec2 uv, vec2 center, float mass) {
    vec2 toCenter = uv - center;
    float dist = length(toCenter);
    
    // Schwarzschild radius (event horizon)
    float rs = mass * 0.15; // scaled for visual
    
    // Avoid singularity
    if (dist < rs * 0.5) {
        return vec2(-999.0); // Inside event horizon
    }
    
    // Einstein ring deflection angle
    // Simplified: deflection = 4GM / (c² * impact parameter)
    // Here we approximate for real-time rendering
    float deflection = (rs * rs * uLensStrength) / (dist * dist);
    
    // Direction away from center (light bends toward mass)
    vec2 deflectDir = normalize(toCenter);
    
    // Apply deflection to sample position
    return uv + deflectDir * deflection;
}

// ========================================
// PHOTON SPHERE
// ========================================

float photonSphere(vec2 uv, vec2 center, float mass) {
    float dist = length(uv - center);
    float rs = mass * 0.15;
    
    // Photon sphere at r = 1.5 * rs
    float photonRadius = rs * 1.5;
    float photonWidth = rs * 0.3;
    
    // Glow ring
    float glow = smoothstep(photonWidth, 0.0, abs(dist - photonRadius));
    glow *= uPhotonSphereGlow;
    
    // Extra brightness right at the edge
    float edge = smoothstep(photonWidth * 0.5, 0.0, abs(dist - photonRadius));
    glow += edge * 0.5;
    
    return glow;
}

// ========================================
// ACCRETION DISC
// ========================================

float discNoise(vec2 uv, float time) {
    float n = 0.0;
    n += noise(uv * 10.0 + time) * 0.5;
    n += noise(uv * 20.0 - time * 0.7) * 0.25;
    n += noise(uv * 40.0 + time * 0.3) * 0.125;
    return n;
}

vec4 accretionDisc(vec2 uv, vec2 center, float mass, float viewAngle) {
    if (uShowAccretionDisc < 0.5) return vec4(0.0);
    
    vec2 toCenter = uv - center;
    float dist = length(toCenter);
    float angle = atan(toCenter.y, toCenter.x);
    
    float rs = mass * 0.15;
    float innerR = rs * uDiscInnerRadius;
    float outerR = rs * uDiscOuterRadius;
    
    // View angle affects disc appearance (tilt)
    float tilt = cos(viewAngle * PI / 180.0);
    
    // Elliptical appearance when tilted
    vec2 tiltedUV = toCenter;
    tiltedUV.y /= max(tilt, 0.1);
    float tiltedDist = length(tiltedUV);
    
    // Disc mask
    float discMask = smoothstep(innerR, innerR + rs * 0.2, tiltedDist);
    discMask *= smoothstep(outerR, outerR - rs * 0.5, tiltedDist);
    
    if (discMask < 0.01) return vec4(0.0);
    
    // Radial position for color gradient (0 = inner, 1 = outer)
    float radialPos = (tiltedDist - innerR) / (outerR - innerR);
    radialPos = clamp(radialPos, 0.0, 1.0);
    
    // Swirl pattern
    float swirl = angle + uTime * uDiscSpeed;
    swirl += (1.0 - radialPos) * 2.0; // inner spins faster
    
    // Noise pattern on disc
    vec2 discUV = vec2(swirl, radialPos * 5.0);
    float pattern = discNoise(discUV, uTime * uDiscSpeed * 0.5);
    
    // Spiral arms
    float arms = sin(angle * 3.0 - uTime * uDiscSpeed * 2.0 + radialPos * 4.0);
    arms = arms * 0.5 + 0.5;
    pattern = mix(pattern, arms, 0.3);
    
    // Color: hot (inner) to cool (outer)
    vec3 discColor = mix(uDiscColorHot, uDiscColorCool, radialPos);
    
    // Doppler shift: blue-shift approaching side, red-shift receding
    if (uDopplerShift > 0.0) {
        float orbitalVelocity = (1.0 - radialPos) * 0.5 + 0.5; // faster near center
        float dopplerAngle = angle + PI * 0.5; // 90° offset for orbital motion
        float doppler = sin(dopplerAngle) * orbitalVelocity * uDopplerShift;
        
        // Blue shift (approaching) - boost blue, reduce red
        // Red shift (receding) - boost red, reduce blue
        discColor.r += doppler * 0.3;
        discColor.b -= doppler * 0.3;
    }
    
    // Brightness varies with pattern
    float brightness = 0.7 + pattern * 0.6;
    discColor *= brightness;
    
    // Edge glow
    float edgeGlow = pow(1.0 - abs(radialPos - 0.5) * 2.0, 2.0);
    discColor += edgeGlow * 0.2;
    
    return vec4(discColor, discMask);
}

// ========================================
// EVENT HORIZON
// ========================================

float eventHorizon(vec2 uv, vec2 center, float mass) {
    float dist = length(uv - center);
    float rs = mass * 0.15;
    
    // Hard edge at event horizon
    return smoothstep(rs, rs * 0.8, dist);
}

// ========================================
// MAIN
// ========================================

void main() {
    // Center and normalize UV
    vec2 uv = vUv - 0.5;
    uv *= 2.0;
    
    // Slow camera orbit
    float orbit = uTime * uOrbitSpeed;
    vec2 center = vec2(sin(orbit) * 0.1, cos(orbit * 0.7) * 0.05);
    
    // Calculate view angle (can animate slightly)
    float viewAngle = uViewAngle + sin(uTime * 0.2) * 5.0;
    
    // Apply gravitational lensing to get deflected sample position
    vec2 deflectedUV = gravitationalDeflection(uv, center, uMass);
    
    // Start with black
    vec3 color = vec3(0.0);
    
    // Check if we're inside the event horizon
    float horizon = eventHorizon(uv, center, uMass);
    
    if (deflectedUV.x > -100.0 && horizon > 0.01) {
        // Sample starfield at deflected position
        vec2 starUV = deflectedUV + vec2(uTime * uStarfieldSpeed, 0.0);
        float stars = starfield(starUV);
        color = vec3(stars);
        
        // Add some color variation to stars
        color *= mix(vec3(1.0, 0.9, 0.8), vec3(0.8, 0.9, 1.0), hash(floor(starUV * 50.0)));
    }
    
    // Apply event horizon mask
    color *= horizon;
    
    // Render accretion disc (behind and in front of black hole)
    vec4 disc = accretionDisc(uv, center, uMass, viewAngle);
    
    // Disc behind black hole (masked by event horizon)
    float behindMask = step(0.0, uv.y * sin(viewAngle * PI / 180.0));
    vec3 discBehind = disc.rgb * disc.a * behindMask * horizon;
    
    // Disc in front (not masked)
    float frontMask = 1.0 - behindMask;
    vec3 discFront = disc.rgb * disc.a * frontMask;
    
    color += discBehind;
    
    // Photon sphere glow
    float photon = photonSphere(uv, center, uMass);
    color += uGlowColor * photon;
    
    // Add front disc on top
    color = mix(color, disc.rgb, disc.a * frontMask);
    
    // Subtle glow around event horizon
    float dist = length(uv - center);
    float rs = uMass * 0.15;
    float haloGlow = smoothstep(rs * 2.0, rs, dist) * 0.3;
    color += uGlowColor * haloGlow * (1.0 - horizon);
    
    // Vignette
    float vignette = 1.0 - dot(vUv - 0.5, vUv - 0.5) * 0.5;
    color *= vignette;
    
    gl_FragColor = vec4(color, 1.0);
}
