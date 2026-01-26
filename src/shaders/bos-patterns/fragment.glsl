// Based on "The Book of Shaders" by Patricio Gonzalez Vivo
// https://thebookofshaders.com/09/

varying vec2 vUv;

uniform float uTime;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform float uScale;
uniform float uRotation;
uniform float uOffset;

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

float cross(vec2 uv, float size) {
  return box(uv, vec2(size, size / 4.0)) +
         box(uv, vec2(size / 4.0, size));
}

void main() {
  vec2 uv = vUv * uScale;
  
  // Create grid
  vec2 gridId = floor(uv);
  vec2 gridUv = fract(uv);
  
  // Offset alternating rows
  if (mod(gridId.y, 2.0) == 1.0) {
    gridUv.x = fract(gridUv.x + uOffset);
  }
  
  // Rotate
  gridUv = gridUv - 0.5;
  gridUv = rotate2d(uRotation + uTime * 0.5) * gridUv;
  gridUv = gridUv + 0.5;
  
  // Draw pattern
  float pattern = cross(gridUv, 0.4);
  
  vec3 color = mix(uColor1, uColor2, pattern);
  
  gl_FragColor = vec4(color, 1.0);
}
