varying vec2 vUv;
varying vec3 vPosition;
varying vec3 vNormal;
varying float vDisplacement;

uniform float uTime;
uniform float uAmplitude;
uniform float uFrequency;
uniform float uSpeed;
uniform float uDirX;
uniform float uDirY;
uniform float uNoiseAmp;
uniform float uNoiseFreq;
uniform float uTwist;
uniform float uWaveType; // 0=sin, 1=ripple, 2=noise-based

// Simple noise function
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
  float amp = 0.5;
  for (int i = 0; i < 4; i++) {
    value += amp * noise(p);
    p *= 2.0;
    amp *= 0.5;
  }
  return value;
}

void main() {
  vUv = uv;
  vNormal = normal;
  
  float time = uTime * uSpeed;
  vec2 dir = vec2(uDirX, uDirY);
  
  float displacement = 0.0;
  int waveType = int(uWaveType);
  
  if (waveType == 0) {
    // Classic sine waves
    displacement = sin(position.x * uFrequency + time + dir.x) * 
                   sin(position.y * uFrequency + time + dir.y) * 
                   uAmplitude;
  } else if (waveType == 1) {
    // Ripple from center
    float dist = length(position.xy);
    displacement = sin(dist * uFrequency - time) * uAmplitude;
    displacement *= exp(-dist * 0.3); // Falloff from center
  } else {
    // Noise-based displacement
    vec2 noiseCoord = position.xy * uFrequency * 0.5 + time * 0.5;
    displacement = (fbm(noiseCoord) - 0.5) * 2.0 * uAmplitude;
  }
  
  // Add high-frequency noise detail
  if (uNoiseAmp > 0.0) {
    vec2 noisePos = position.xy * uNoiseFreq + time;
    displacement += (noise(noisePos) - 0.5) * uNoiseAmp;
  }
  
  vDisplacement = displacement;
  
  // Twist deformation
  vec3 newPosition = position;
  if (uTwist != 0.0) {
    float twistAngle = position.y * uTwist;
    float c = cos(twistAngle);
    float s = sin(twistAngle);
    newPosition.x = position.x * c - position.z * s;
    newPosition.z = position.x * s + position.z * c;
  }
  
  // Apply displacement along normal
  newPosition += normal * displacement;
  vPosition = newPosition;
  
  gl_Position = projectionMatrix * modelViewMatrix * vec4(newPosition, 1.0);
}
