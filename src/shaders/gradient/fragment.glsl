varying vec2 vUv;

uniform float uTime;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uColor3;
uniform float uAngle;
uniform float uAnimSpeed;
uniform float uWaveFreq;
uniform float uWaveAmp;
uniform float uHardness;
uniform float uMidPoint;
uniform float uPulseSpeed;
uniform float uPulseAmp;

void main() {
  vec2 uv = vUv;
  
  // Wave distortion
  if (uWaveAmp > 0.0) {
    uv.x += sin(uv.y * uWaveFreq + uTime * 2.0) * uWaveAmp * 0.1;
    uv.y += cos(uv.x * uWaveFreq + uTime * 2.0) * uWaveAmp * 0.1;
  }
  
  // Rotate UV for angled gradient
  float angle = uAngle * 3.14159 / 180.0;
  vec2 rotatedUv = vec2(
    cos(angle) * (uv.x - 0.5) - sin(angle) * (uv.y - 0.5) + 0.5,
    sin(angle) * (uv.x - 0.5) + cos(angle) * (uv.y - 0.5) + 0.5
  );
  
  float t = rotatedUv.x;
  
  // Animation
  if (uAnimSpeed > 0.0) {
    t = fract(t + uTime * uAnimSpeed * 0.1);
  }
  
  // Pulse effect
  if (uPulseAmp > 0.0) {
    t += sin(uTime * uPulseSpeed) * uPulseAmp * 0.1;
  }
  
  // Hardness (sharpness of gradient)
  float midPoint = uMidPoint;
  if (uHardness > 0.0) {
    t = smoothstep(midPoint - (1.0 - uHardness) * 0.5, midPoint + (1.0 - uHardness) * 0.5, t);
  }
  
  // Three-color gradient
  vec3 color;
  if (t < midPoint) {
    color = mix(uColor1, uColor2, t / midPoint);
  } else {
    color = mix(uColor2, uColor3, (t - midPoint) / (1.0 - midPoint));
  }
  
  gl_FragColor = vec4(color, 1.0);
}
