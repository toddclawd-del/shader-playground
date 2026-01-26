// Based on "The Book of Shaders" by Patricio Gonzalez Vivo
// https://thebookofshaders.com/07/

varying vec2 vUv;

uniform float uTime;
uniform vec3 uColor;
uniform vec3 uBackground;
uniform float uRadius;
uniform float uSoftness;
uniform float uCount;
uniform float uAnimated;

float circle(vec2 uv, vec2 center, float radius, float softness) {
  float d = distance(uv, center);
  return 1.0 - smoothstep(radius - softness, radius + softness, d);
}

float rectangle(vec2 uv, vec2 center, vec2 size, float softness) {
  vec2 d = abs(uv - center) - size;
  float outside = length(max(d, 0.0));
  float inside = min(max(d.x, d.y), 0.0);
  return 1.0 - smoothstep(-softness, softness, outside + inside);
}

void main() {
  vec2 uv = vUv;
  
  float shape = 0.0;
  
  // Grid of shapes
  float count = max(1.0, uCount);
  vec2 gridUv = fract(uv * count);
  vec2 gridId = floor(uv * count);
  
  // Animate position
  float offset = 0.0;
  if (uAnimated > 0.5) {
    offset = sin(uTime + gridId.x * 0.5 + gridId.y * 0.3) * 0.1;
  }
  
  // Draw circle in each grid cell
  shape = circle(gridUv, vec2(0.5, 0.5 + offset), uRadius, uSoftness);
  
  vec3 color = mix(uBackground, uColor, shape);
  
  gl_FragColor = vec4(color, 1.0);
}
