/**
 * Volumetric Clouds (Protean Clouds)
 * 
 * True volumetric raymarching through 3D density fields.
 * FBM noise with domain warping creates organic, flowing cloud formations.
 * Light scattering (Henyey-Greenstein) for that atmospheric glow.
 * 
 * Based on nimitz's Protean Clouds: https://www.shadertoy.com/view/3l23Rh
 * 
 * Key techniques:
 * - Volumetric raymarching with early termination
 * - Fractional Brownian Motion for density
 * - Domain warping for organic motion
 * - Beer-Lambert absorption
 * - Phase function for light scattering
 */

varying vec2 vUv;

uniform float uTime;

// Density & Shape
uniform float uCloudDensity;
uniform float uCloudCoverage;
uniform float uCloudHeight;

// Motion
uniform float uWindSpeed;
uniform float uTurbulence;

// Lighting
uniform vec3 uSunDirection;
uniform vec3 uSunColor;
uniform vec3 uAmbientColor;
uniform float uScatterStrength;

// Quality
uniform float uRaySteps;
uniform float uNoiseOctaves;

#define PI 3.14159265359
#define TAU 6.28318530718

// ========================================
// NOISE FUNCTIONS
// ========================================

// High quality 3D noise
float hash31(vec3 p) {
    p = fract(p * 0.1031);
    p += dot(p, p.zyx + 31.32);
    return fract((p.x + p.y) * p.z);
}

vec3 hash33(vec3 p) {
    p = vec3(
        dot(p, vec3(127.1, 311.7, 74.7)),
        dot(p, vec3(269.5, 183.3, 246.1)),
        dot(p, vec3(113.5, 271.9, 124.6))
    );
    return fract(sin(p) * 43758.5453123);
}

float noise3D(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    
    // Quintic interpolation for smoother results
    f = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
    
    float a = hash31(i);
    float b = hash31(i + vec3(1.0, 0.0, 0.0));
    float c = hash31(i + vec3(0.0, 1.0, 0.0));
    float d = hash31(i + vec3(1.0, 1.0, 0.0));
    float e = hash31(i + vec3(0.0, 0.0, 1.0));
    float g = hash31(i + vec3(1.0, 0.0, 1.0));
    float h = hash31(i + vec3(0.0, 1.0, 1.0));
    float j = hash31(i + vec3(1.0, 1.0, 1.0));
    
    return mix(
        mix(mix(a, b, f.x), mix(c, d, f.x), f.y),
        mix(mix(e, g, f.x), mix(h, j, f.x), f.y),
        f.z
    );
}

// ========================================
// FRACTIONAL BROWNIAN MOTION
// ========================================

float fbm(vec3 p, int octaves) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    float maxValue = 0.0;
    
    for (int i = 0; i < 8; i++) {
        if (i >= octaves) break;
        
        value += amplitude * noise3D(p * frequency);
        maxValue += amplitude;
        
        amplitude *= 0.5;
        frequency *= 2.0;
        
        // Slight rotation between octaves for more natural look
        p = p.yzx * 1.02;
    }
    
    return value / maxValue;
}

// FBM with domain warping - creates organic swirly patterns
float fbmWarped(vec3 p, int octaves) {
    // First pass of FBM for warping
    vec3 warp = vec3(
        fbm(p + vec3(0.0, 0.0, 0.0), 3),
        fbm(p + vec3(5.2, 1.3, 2.8), 3),
        fbm(p + vec3(2.8, 7.1, 4.3), 3)
    );
    
    // Apply warp with turbulence control
    p += warp * uTurbulence * 2.0;
    
    return fbm(p, octaves);
}

// ========================================
// CLOUD DENSITY
// ========================================

float cloudDensity(vec3 p) {
    // Wind animation
    vec3 wind = vec3(uTime * uWindSpeed * 0.5, 0.0, uTime * uWindSpeed * 0.2);
    vec3 samplePos = p + wind;
    
    // Base FBM for cloud shape
    int octaves = int(uNoiseOctaves);
    float density = fbmWarped(samplePos * 0.3, octaves);
    
    // Add some smaller detail
    density += fbm(samplePos * 1.5 + wind * 0.5, max(octaves - 2, 2)) * 0.3;
    
    // Coverage threshold - higher coverage = more clouds
    density = density - (1.0 - uCloudCoverage);
    
    // Remap and apply density multiplier
    density = max(density, 0.0) * uCloudDensity;
    
    // Vertical falloff - clouds thin out at edges
    float heightFalloff = 1.0 - abs(p.y) / uCloudHeight;
    heightFalloff = smoothstep(0.0, 0.4, heightFalloff);
    
    return density * heightFalloff;
}

// ========================================
// LIGHT SCATTERING
// ========================================

// Henyey-Greenstein phase function
// g > 0: forward scattering (looking toward sun = brighter)
// g < 0: back scattering
// g = 0: isotropic
float henyeyGreenstein(float cosTheta, float g) {
    float g2 = g * g;
    return (1.0 - g2) / (4.0 * PI * pow(1.0 + g2 - 2.0 * g * cosTheta, 1.5));
}

// Combined phase function with forward and back scatter
float phaseFunction(float cosTheta) {
    // Mix of forward scatter (silver lining) and back scatter
    float forward = henyeyGreenstein(cosTheta, 0.6);
    float back = henyeyGreenstein(cosTheta, -0.3);
    return mix(back, forward, 0.7) * uScatterStrength;
}

// ========================================
// LIGHT MARCHING
// ========================================

float lightMarch(vec3 pos, vec3 sunDir) {
    float density = 0.0;
    float stepSize = 0.2;
    
    // Short march toward sun to calculate shadow/self-shadowing
    for (int i = 0; i < 6; i++) {
        pos += sunDir * stepSize;
        density += max(cloudDensity(pos), 0.0) * stepSize;
    }
    
    // Beer-Lambert absorption
    return exp(-density * 2.0);
}

// ========================================
// MAIN RAYMARCHING
// ========================================

vec4 raymarch(vec3 ro, vec3 rd, vec3 sunDir) {
    // Ray bounds (cloud layer)
    float near = 0.5;
    float far = 10.0;
    
    // Accumulated values
    vec3 color = vec3(0.0);
    float transmittance = 1.0;
    
    // Step size based on quality setting
    float steps = uRaySteps;
    float stepSize = (far - near) / steps;
    
    // Jitter starting position to reduce banding
    float jitter = hash31(vec3(gl_FragCoord.xy, uTime)) * stepSize;
    float t = near + jitter;
    
    for (int i = 0; i < 128; i++) {
        if (float(i) >= steps) break;
        if (transmittance < 0.01) break; // Early termination
        
        vec3 pos = ro + rd * t;
        
        // Sample density
        float density = cloudDensity(pos);
        
        if (density > 0.001) {
            // Calculate lighting at this point
            float lightTransmittance = lightMarch(pos, sunDir);
            
            // Phase function for scattering
            float cosTheta = dot(rd, sunDir);
            float phase = phaseFunction(cosTheta);
            
            // Light contribution
            vec3 sunLight = uSunColor * lightTransmittance * phase;
            vec3 ambient = uAmbientColor * 0.3;
            
            // Inscattered light
            vec3 luminance = sunLight + ambient;
            
            // Beer-Lambert absorption for this segment
            float segmentTransmittance = exp(-density * stepSize * 8.0);
            
            // Accumulate color (front-to-back compositing)
            vec3 segmentColor = luminance * density;
            color += segmentColor * transmittance * (1.0 - segmentTransmittance);
            
            // Update transmittance
            transmittance *= segmentTransmittance;
        }
        
        t += stepSize;
    }
    
    return vec4(color, 1.0 - transmittance);
}

// ========================================
// SKY GRADIENT
// ========================================

vec3 skyGradient(vec3 rd, vec3 sunDir) {
    // Base sky color
    float height = rd.y * 0.5 + 0.5;
    vec3 sky = mix(uAmbientColor * 0.8, uAmbientColor * 0.4, height);
    
    // Sun glow
    float sunDot = max(dot(rd, sunDir), 0.0);
    vec3 sunGlow = uSunColor * pow(sunDot, 32.0) * 0.5;
    sunGlow += uSunColor * pow(sunDot, 8.0) * 0.2;
    
    // Horizon glow
    float horizonGlow = pow(1.0 - abs(rd.y), 8.0);
    sky += mix(uSunColor, uAmbientColor, 0.5) * horizonGlow * 0.3;
    
    return sky + sunGlow;
}

// ========================================
// MAIN
// ========================================

void main() {
    // Setup UV and aspect ratio
    vec2 uv = vUv - 0.5;
    uv.x *= 1.0; // Can adjust for aspect ratio
    
    // Camera setup - looking into the cloud volume
    vec3 ro = vec3(0.0, 0.0, -3.0); // Ray origin
    vec3 rd = normalize(vec3(uv, 1.0)); // Ray direction
    
    // Slight camera motion
    float camTime = uTime * 0.1;
    ro.x += sin(camTime) * 0.5;
    ro.y += cos(camTime * 0.7) * 0.3;
    
    // Sun direction (normalized)
    vec3 sunDir = normalize(uSunDirection);
    
    // Background sky
    vec3 sky = skyGradient(rd, sunDir);
    
    // Raymarch through clouds
    vec4 clouds = raymarch(ro, rd, sunDir);
    
    // Composite clouds over sky
    vec3 color = mix(sky, clouds.rgb, clouds.a);
    
    // Subtle tone mapping
    color = color / (1.0 + color);
    
    // Gamma correction
    color = pow(color, vec3(1.0 / 2.2));
    
    // Vignette
    float vignette = 1.0 - dot(vUv - 0.5, vUv - 0.5) * 0.5;
    color *= vignette;
    
    gl_FragColor = vec4(color, 1.0);
}
