// Based on "The Book of Shaders" by Patricio Gonzalez Vivo

varying vec2 vUv;

uniform float uTime;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform float uScale;
uniform float uRotation;
uniform float uRotationSpeed;
uniform float uOffset;
uniform float uOffsetAnim;
uniform float uCrossSize;
uniform float uCrossRatio;
uniform float uPulseSpeed;
uniform float uPulseAmp;
uniform float uMorphSpeed;
uniform float uMorphAmp;

mat2 rotate2d(float angle) {
  return mat2(cos(angle), -sin(angle),
              sin(angle), cos(angle));
}

float box(vec2 uv, vec2 size) {
  size = vec2(0.5) - size * 0.5;
  vec2 bl = smoothstep(size, size + vec2(0.001), uv);
  vec2 tr = smoothstep(size, size + vec2(0.001), 1.0 - uv);
  return bl.x * bl.y * tr.x * tr.y;
}

float crossShape(vec2 uv, float size, float ratio) {
  return box(uv, vec2(size, size * ratio)) +
         box(uv, vec2(size * ratio, size));
}

void main() {
  vec2 uv = vUv * uScale;
  
  // Animated scale pulse
  float scalePulse = 1.0 + sin(uTime * uPulseSpeed) * uPulseAmp * 0.1;
  uv *= scalePulse;
  
  // Create grid
  vec2 gridId = floor(uv);
  vec2 gridUv = fract(uv);
  
  // Animated row offset
  float animatedOffset = uOffset;
  if (uOffsetAnim > 0.0) {
    animatedOffset += sin(uTime * uOffsetAnim + gridId.y * 0.5) * 0.25;
  }
  
  // Offset alternating rows
  if (mod(gridId.y, 2.0) == 1.0) {
    gridUv.x = fract(gridUv.x + animatedOffset);
  }
  
  // Rotate with animation
  float rotation = uRotation + uTime * uRotationSpeed;
  // Add per-cell rotation variation
  rotation += (gridId.x + gridId.y) * 0.1;
  
  gridUv = gridUv - 0.5;
  gridUv = rotate2d(rotation) * gridUv;
  gridUv = gridUv + 0.5;
  
  // Animated cross size
  float crossSize = uCrossSize;
  if (uMorphAmp > 0.0) {
    crossSize += sin(uTime * uMorphSpeed + gridId.x * 0.3 + gridId.y * 0.7) * uMorphAmp * 0.1;
  }
  crossSize = clamp(crossSize, 0.1, 0.9);
  
  // Draw pattern
  float pattern = crossShape(gridUv, crossSize, uCrossRatio);
  
  vec3 color = mix(uColor1, uColor2, pattern);
  
  gl_FragColor = vec4(color, 1.0);
}
