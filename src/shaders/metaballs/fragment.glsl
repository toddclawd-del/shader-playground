precision highp float;

varying vec2 vUv;

uniform float uTime;
uniform float uBlobCount;
uniform float uBlobSize;
uniform float uThreshold;
uniform float uSpeed;
uniform float uSmooth;
uniform float uGlow;
uniform float uOrganic;
uniform float uPulse;
uniform int uColorMode;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uColor3;
uniform vec3 uBackgroundColor;
uniform float uBorderWidth;
uniform float uBorderGlow;

#define PI 3.14159265359
#define TAU 6.28318530718
#define MAX_BLOBS 12

// Hash for pseudo-random blob behavior
float hash(float n) {
  return fract(sin(n) * 43758.5453123);
}

// Smooth min for organic blending
float smin(float a, float b, float k) {
  float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
  return mix(b, a, h) - k * h * (1.0 - h);
}

// Get blob position (unique motion per blob)
vec2 getBlobPos(int i) {
  float fi = float(i);
  float seed1 = hash(fi * 13.37);
  float seed2 = hash(fi * 7.89);
  float seed3 = hash(fi * 3.14);
  
  float t = uTime * uSpeed;
  
  // Organic Lissajous-like motion
  float freqX = 0.5 + seed1 * 0.8;
  float freqY = 0.4 + seed2 * 0.9;
  float phaseX = seed3 * TAU;
  float phaseY = seed1 * TAU;
  
  float x = sin(t * freqX + phaseX) * 0.3 + sin(t * freqY * 0.7 + phaseY) * 0.15;
  float y = cos(t * freqY + phaseY) * 0.3 + cos(t * freqX * 0.6 + phaseX) * 0.15;
  
  // Add organic noise-like wobble
  if (uOrganic > 0.0) {
    x += sin(t * 2.1 + fi) * 0.08 * uOrganic;
    y += cos(t * 1.9 + fi * 1.5) * 0.08 * uOrganic;
  }
  
  return vec2(x, y) + 0.5;
}

// Get blob radius (with optional pulse)
float getBlobRadius(int i) {
  float fi = float(i);
  float baseSize = uBlobSize * (0.7 + hash(fi * 5.67) * 0.6);
  
  if (uPulse > 0.0) {
    float pulsePhase = hash(fi * 11.11) * TAU;
    float pulseFreq = 0.8 + hash(fi * 2.22) * 0.4;
    baseSize *= 1.0 + sin(uTime * uSpeed * pulseFreq + pulsePhase) * uPulse * 0.3;
  }
  
  return baseSize;
}

// Calculate metaball field value
float metaballField(vec2 p) {
  float field = 0.0;
  int blobCount = int(uBlobCount);
  
  for (int i = 0; i < MAX_BLOBS; i++) {
    if (i >= blobCount) break;
    
    vec2 blobPos = getBlobPos(i);
    float radius = getBlobRadius(i);
    
    float d = length(p - blobPos);
    
    // Classic metaball: sum of radius²/distance²
    // Creates smooth falloff that merges when blobs overlap
    float contribution = (radius * radius) / (d * d + 0.0001);
    
    if (uSmooth > 0.0) {
      // Smooth blending using smin
      field = field + contribution * (1.0 - uSmooth) + smin(field, contribution, uSmooth * 0.5) * uSmooth;
    } else {
      field += contribution;
    }
  }
  
  return field;
}

// Color palettes
vec3 getColor(float t, float field) {
  t = clamp(t, 0.0, 1.0);
  
  if (uColorMode == 0) {
    // Custom gradient
    return mix(uColor1, uColor2, t);
  } else if (uColorMode == 1) {
    // Lava lamp (warm organics)
    vec3 a = vec3(0.9, 0.2, 0.1);
    vec3 b = vec3(1.0, 0.6, 0.1);
    vec3 c = vec3(1.0, 0.9, 0.3);
    float t2 = t * 2.0;
    if (t2 < 1.0) return mix(a, b, t2);
    return mix(b, c, t2 - 1.0);
  } else if (uColorMode == 2) {
    // Plasma (psychedelic)
    vec3 a = vec3(0.2, 0.0, 0.4);
    vec3 b = vec3(0.9, 0.1, 0.5);
    vec3 c = vec3(0.1, 0.9, 0.9);
    return mix(mix(a, b, t), c, sin(t * PI) * 0.5 + 0.5);
  } else if (uColorMode == 3) {
    // Ocean
    vec3 deep = vec3(0.0, 0.1, 0.3);
    vec3 mid = vec3(0.0, 0.4, 0.6);
    vec3 surface = vec3(0.3, 0.8, 0.9);
    float t2 = t * 2.0;
    if (t2 < 1.0) return mix(deep, mid, t2);
    return mix(mid, surface, t2 - 1.0);
  } else if (uColorMode == 4) {
    // Neon
    vec3 a = vec3(1.0, 0.0, 0.5);
    vec3 b = vec3(0.0, 1.0, 1.0);
    return mix(a, b, t) * (1.0 + field * 0.2);
  } else {
    // Monochrome
    return mix(vec3(0.1), vec3(1.0), t);
  }
}

void main() {
  vec2 uv = vUv;
  
  // Aspect ratio correction
  float aspect = 1.0; // Assuming square, adjust if needed
  vec2 p = uv;
  
  // Calculate field
  float field = metaballField(p);
  
  // Threshold determines the "surface"
  float threshold = uThreshold;
  
  // Calculate distance from threshold for effects
  float surfaceDist = field - threshold;
  
  // Base color
  vec3 color = uBackgroundColor;
  float alpha = 1.0;
  
  if (field >= threshold) {
    // Inside the metaball
    float intensity = (field - threshold) / (field + 0.001);
    intensity = clamp(intensity, 0.0, 1.0);
    
    // Get blob color based on intensity
    color = getColor(intensity, field);
    
    // Add internal glow/depth
    float depthFactor = 1.0 - pow(intensity, 2.0);
    color *= 0.8 + depthFactor * 0.4;
    
  } else if (uBorderWidth > 0.0 || uGlow > 0.0) {
    // Border/glow effect outside threshold
    float distFromSurface = threshold - field;
    
    // Border
    if (uBorderWidth > 0.0 && distFromSurface < uBorderWidth * 0.1) {
      float borderT = 1.0 - distFromSurface / (uBorderWidth * 0.1);
      vec3 borderColor = getColor(0.8, field);
      color = mix(color, borderColor, borderT * uBorderGlow);
    }
    
    // Outer glow
    if (uGlow > 0.0) {
      float glowDist = distFromSurface / (uGlow * 0.3);
      float glowIntensity = exp(-glowDist * 3.0);
      vec3 glowColor = getColor(0.5, field);
      color = mix(color, glowColor, glowIntensity * 0.6);
    }
  }
  
  // Add subtle inner glow at edges (fresnel-like)
  if (field >= threshold) {
    float edgeDist = (field - threshold) / threshold;
    if (edgeDist < 0.3) {
      float edgeGlow = 1.0 - edgeDist / 0.3;
      vec3 edgeColor = getColor(1.0, field);
      color = mix(color, edgeColor, edgeGlow * 0.3 * uGlow);
    }
  }
  
  gl_FragColor = vec4(color, alpha);
}
