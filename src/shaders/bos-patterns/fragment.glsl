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
uniform float uShapeSize;
uniform float uShapeRatio;
uniform float uPulseSpeed;
uniform float uPulseAmp;
uniform float uMorphSpeed;
uniform float uMorphAmp;
uniform float uShapeType;
uniform float uSoftness;

#define PI 3.14159265

mat2 rotate2d(float angle) {
  return mat2(cos(angle), -sin(angle),
              sin(angle), cos(angle));
}

// ============================================
// Shape SDFs (centered at 0.5, 0.5)
// ============================================

// 0: Cross
float sdCross(vec2 uv, float size, float ratio) {
  vec2 p = abs(uv - 0.5);
  float d1 = max(p.x - size * ratio * 0.5, p.y - size * 0.5);
  float d2 = max(p.x - size * 0.5, p.y - size * ratio * 0.5);
  return min(d1, d2);
}

// 1: Circle
float sdCircle(vec2 uv, float size, float ratio) {
  vec2 p = uv - 0.5;
  p.x *= ratio + (1.0 - ratio) * 0.5; // ratio affects ellipse
  return length(p) - size * 0.4;
}

// 2: Diamond
float sdDiamond(vec2 uv, float size, float ratio) {
  vec2 p = abs(uv - 0.5);
  p.y *= ratio + 0.5;
  return (p.x + p.y) - size * 0.5;
}

// 3: Star (5-pointed)
float sdStar(vec2 uv, float size, float ratio) {
  vec2 p = uv - 0.5;
  float a = atan(p.y, p.x) + PI;
  float r = length(p);
  
  // 5 points
  float n = 5.0;
  float m = ratio * 2.0 + 2.0; // inner radius ratio
  
  float an = PI / n;
  float en = PI / m;
  vec2 acs = vec2(cos(an), sin(an));
  vec2 ecs = vec2(cos(en), sin(en));
  
  float bn = mod(a, 2.0 * an) - an;
  p = r * vec2(cos(bn), abs(sin(bn)));
  p -= size * 0.4 * acs;
  p += ecs * clamp(-dot(p, ecs), 0.0, size * 0.4 * acs.y / ecs.y);
  
  return length(p) * sign(p.x);
}

// 4: Triangle
float sdTriangle(vec2 uv, float size, float ratio) {
  vec2 p = uv - 0.5;
  p.y -= size * 0.1; // center better
  
  float k = sqrt(3.0);
  p.x = abs(p.x) - size * 0.4;
  p.y = p.y + size * 0.4 / k;
  
  if (p.x + k * p.y > 0.0) {
    p = vec2(p.x - k * p.y, -k * p.x - p.y) / 2.0;
  }
  
  p.x -= clamp(p.x, -size * 0.8, 0.0);
  return -length(p) * sign(p.y);
}

// 5: Hexagon
float sdHexagon(vec2 uv, float size, float ratio) {
  vec2 p = abs(uv - 0.5);
  p.y *= ratio * 0.5 + 0.75;
  
  vec2 k = vec2(-0.866025, 0.5); // cos(60), sin(60)
  p -= 2.0 * min(dot(k, p), 0.0) * k;
  p -= vec2(clamp(p.x, -k.y * size * 0.4, k.y * size * 0.4), size * 0.4);
  
  return length(p) * sign(p.y);
}

// ============================================
// Get shape by type
// ============================================

float getShape(vec2 uv, float size, float ratio, int shapeType) {
  float d;
  
  if (shapeType == 0) {
    d = sdCross(uv, size, ratio);
  } else if (shapeType == 1) {
    d = sdCircle(uv, size, ratio);
  } else if (shapeType == 2) {
    d = sdDiamond(uv, size, ratio);
  } else if (shapeType == 3) {
    d = sdStar(uv, size, ratio);
  } else if (shapeType == 4) {
    d = sdTriangle(uv, size, ratio);
  } else {
    d = sdHexagon(uv, size, ratio);
  }
  
  // Convert SDF to smooth fill
  return 1.0 - smoothstep(-uSoftness, uSoftness, d);
}

// ============================================
// Main
// ============================================

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
  rotation += (gridId.x + gridId.y) * 0.1;
  
  gridUv = gridUv - 0.5;
  gridUv = rotate2d(rotation) * gridUv;
  gridUv = gridUv + 0.5;
  
  // Animated shape size
  float shapeSize = uShapeSize;
  if (uMorphAmp > 0.0) {
    shapeSize += sin(uTime * uMorphSpeed + gridId.x * 0.3 + gridId.y * 0.7) * uMorphAmp * 0.1;
  }
  shapeSize = clamp(shapeSize, 0.1, 0.95);
  
  // Draw pattern
  int shapeType = int(uShapeType);
  float pattern = getShape(gridUv, shapeSize, uShapeRatio, shapeType);
  
  vec3 color = mix(uColor1, uColor2, pattern);
  
  gl_FragColor = vec4(color, 1.0);
}
