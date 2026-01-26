varying vec2 vUv;

uniform vec3 uColor1;
uniform vec3 uColor2;
uniform float uAngle;
uniform float uTime;
uniform float uAnimated;

void main() {
  // Rotate UV for angled gradient
  float angle = uAngle * 3.14159 / 180.0;
  vec2 rotatedUv = vec2(
    cos(angle) * (vUv.x - 0.5) - sin(angle) * (vUv.y - 0.5) + 0.5,
    sin(angle) * (vUv.x - 0.5) + cos(angle) * (vUv.y - 0.5) + 0.5
  );
  
  float t = rotatedUv.x;
  
  // Optional animation
  if (uAnimated > 0.5) {
    t = fract(t + uTime * 0.1);
  }
  
  vec3 color = mix(uColor1, uColor2, t);
  
  gl_FragColor = vec4(color, 1.0);
}
