// Based on "The Book of Shaders" by Patricio Gonzalez Vivo

varying vec2 vUv;

uniform float uTime;
uniform vec3 uColor;
uniform vec3 uBackground;
uniform float uRadius;
uniform float uSoftness;
uniform float uCountX;
uniform float uCountY;
uniform float uAnimSpeed;
uniform float uPulseAmp;
uniform float uRotation;
uniform float uRotationSpeed;
uniform float uRingWidth;
uniform float uShapeType; // 0=circle, 1=square, 2=ring, 3=diamond
uniform float uInvert;

float circle(vec2 uv, vec2 center, float radius, float softness) {
  float d = distance(uv, center);
  return 1.0 - smoothstep(radius - softness, radius + softness, d);
}

float ring(vec2 uv, vec2 center, float radius, float width, float softness) {
  float d = distance(uv, center);
  float inner = smoothstep(radius - width - softness, radius - width + softness, d);
  float outer = 1.0 - smoothstep(radius - softness, radius + softness, d);
  return inner * outer;
}

float square(vec2 uv, vec2 center, float size, float softness) {
  vec2 d = abs(uv - center);
  float maxD = max(d.x, d.y);
  return 1.0 - smoothstep(size - softness, size + softness, maxD);
}

float diamond(vec2 uv, vec2 center, float size, float softness) {
  vec2 d = abs(uv - center);
  float sumD = d.x + d.y;
  return 1.0 - smoothstep(size - softness, size + softness, sumD);
}

mat2 rotate2d(float angle) {
  return mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
}

void main() {
  vec2 uv = vUv;
  
  float shape = 0.0;
  
  // Grid
  float countX = max(1.0, uCountX);
  float countY = max(1.0, uCountY);
  vec2 gridUv = fract(uv * vec2(countX, countY));
  vec2 gridId = floor(uv * vec2(countX, countY));
  
  // Center the grid cell
  vec2 cellCenter = vec2(0.5);
  
  // Per-cell rotation
  float rotAngle = uRotation + uTime * uRotationSpeed + (gridId.x + gridId.y) * 0.2;
  gridUv = (gridUv - 0.5) * rotate2d(rotAngle) + 0.5;
  
  // Animation offset per cell
  float animOffset = sin(uTime * uAnimSpeed + gridId.x * 0.7 + gridId.y * 0.5);
  
  // Animated radius with pulse
  float radius = uRadius + animOffset * uPulseAmp * 0.1;
  radius = max(0.01, radius);
  
  // Draw shape based on type
  int shapeType = int(uShapeType);
  if (shapeType == 0) {
    shape = circle(gridUv, cellCenter, radius, uSoftness);
  } else if (shapeType == 1) {
    shape = square(gridUv, cellCenter, radius, uSoftness);
  } else if (shapeType == 2) {
    shape = ring(gridUv, cellCenter, radius, uRingWidth, uSoftness);
  } else {
    shape = diamond(gridUv, cellCenter, radius, uSoftness);
  }
  
  // Invert option
  if (uInvert > 0.5) {
    shape = 1.0 - shape;
  }
  
  vec3 color = mix(uBackground, uColor, shape);
  
  gl_FragColor = vec4(color, 1.0);
}
