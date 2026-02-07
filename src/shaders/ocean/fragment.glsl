/*
 * Ocean Fragment Shader
 * 
 * Realistic water coloring with:
 * - Depth-based color gradient (shallow -> deep)
 * - Foam at wave crests
 * - Fresnel effect (water darker when looking straight down)
 * - Specular highlights
 * - Subsurface scattering approximation
 */

varying vec2 vUv;
varying vec3 vPosition;
varying vec3 vNormal;
varying float vFoam;
varying float vDepth;

uniform float uTime;

// Water colors
uniform vec3 uShallowColor;
uniform vec3 uDeepColor;
uniform vec3 uFoamColor;
uniform vec3 uSpecularColor;

// Lighting
uniform float uFresnelPower;
uniform float uSpecularPower;
uniform float uSpecularIntensity;
uniform vec3 uLightDir;

// Foam
uniform float uFoamIntensity;
uniform float uFoamDetail;

// Subsurface
uniform float uSubsurfaceIntensity;
uniform vec3 uSubsurfaceColor;

// Simple noise for foam detail
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

void main() {
    // Normalize the normal (interpolation can denormalize)
    vec3 normal = normalize(vNormal);
    
    // View direction (assuming camera at origin looking at scene)
    vec3 viewDir = normalize(-vPosition);
    
    // Light direction
    vec3 lightDir = normalize(uLightDir);
    
    // ==================== BASE COLOR ====================
    // Depth-based color mixing
    float depthFactor = smoothstep(-0.3, 0.3, vDepth);
    vec3 waterColor = mix(uDeepColor, uShallowColor, depthFactor);
    
    // ==================== FRESNEL ====================
    // Water appears lighter at grazing angles
    float fresnel = pow(1.0 - max(dot(normal, viewDir), 0.0), uFresnelPower);
    fresnel = clamp(fresnel, 0.0, 1.0);
    
    // Add fresnel brightening
    waterColor = mix(waterColor, uShallowColor * 1.2, fresnel * 0.5);
    
    // ==================== SUBSURFACE SCATTERING ====================
    // Light passing through wave crests
    float subsurface = pow(max(dot(viewDir, -lightDir), 0.0), 2.0);
    subsurface *= max(vDepth, 0.0); // Only on elevated parts
    waterColor += uSubsurfaceColor * subsurface * uSubsurfaceIntensity;
    
    // ==================== SPECULAR ====================
    // Blinn-Phong specular
    vec3 halfDir = normalize(lightDir + viewDir);
    float specular = pow(max(dot(normal, halfDir), 0.0), uSpecularPower);
    specular *= uSpecularIntensity;
    
    // Add specular
    waterColor += uSpecularColor * specular;
    
    // ==================== FOAM ====================
    // Add noise to foam for organic look
    vec2 foamUV = vPosition.xz * uFoamDetail;
    float foamNoise = fbm(foamUV + uTime * 0.5);
    
    // Secondary noise layer for detail
    float foamNoise2 = fbm(foamUV * 2.0 - uTime * 0.3);
    
    // Combine foam factor with noise
    float foam = vFoam * uFoamIntensity;
    foam *= 0.5 + 0.5 * foamNoise;
    foam *= 0.7 + 0.3 * foamNoise2;
    
    // Clamp and apply
    foam = clamp(foam, 0.0, 1.0);
    
    // Mix in foam color
    waterColor = mix(waterColor, uFoamColor, foam);
    
    // ==================== FINAL ====================
    // Add slight ambient occlusion in troughs
    float ao = smoothstep(-0.2, 0.1, vDepth);
    waterColor *= 0.7 + 0.3 * ao;
    
    // Subtle color variation based on position
    float variation = fbm(vPosition.xz * 0.5) * 0.1;
    waterColor += vec3(variation * 0.5, variation * 0.3, variation * 0.1);
    
    gl_FragColor = vec4(waterColor, 1.0);
}
