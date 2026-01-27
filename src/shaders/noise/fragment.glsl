varying vec2 vUv;

uniform float uTime;
uniform float uScale;
uniform float uSpeed;
uniform float uDirX;
uniform float uDirY;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform float uOctaves;
uniform float uContrast;
uniform float uBrightness;
uniform float uThreshold;
uniform float uEdgeSoftness;
uniform float uWarpAmount;
uniform float uWarpScale;

// Classic Perlin 2D Noise
vec4 permute(vec4 x) {
  return mod(((x * 34.0) + 1.0) * x, 289.0);
}

vec2 fade(vec2 t) {
  return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

float cnoise(vec2 P) {
  vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
  vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
  Pi = mod(Pi, 289.0);
  vec4 ix = Pi.xzxz;
  vec4 iy = Pi.yyww;
  vec4 fx = Pf.xzxz;
  vec4 fy = Pf.yyww;
  vec4 i = permute(permute(ix) + iy);
  vec4 gx = 2.0 * fract(i * 0.0243902439) - 1.0;
  vec4 gy = abs(gx) - 0.5;
  vec4 tx = floor(gx + 0.5);
  gx = gx - tx;
  vec2 g00 = vec2(gx.x, gy.x);
  vec2 g10 = vec2(gx.y, gy.y);
  vec2 g01 = vec2(gx.z, gy.z);
  vec2 g11 = vec2(gx.w, gy.w);
  vec4 norm = 1.79284291400159 - 0.85373472095314 * 
    vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11));
  g00 *= norm.x;
  g01 *= norm.y;
  g10 *= norm.z;
  g11 *= norm.w;
  float n00 = dot(g00, vec2(fx.x, fy.x));
  float n10 = dot(g10, vec2(fx.y, fy.y));
  float n01 = dot(g01, vec2(fx.z, fy.z));
  float n11 = dot(g11, vec2(fx.w, fy.w));
  vec2 fade_xy = fade(Pf.xy);
  vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
  float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
  return 2.3 * n_xy;
}

float fbm(vec2 p, int octaves) {
  float value = 0.0;
  float amplitude = 0.5;
  float frequency = 1.0;
  
  for (int i = 0; i < 8; i++) {
    if (i >= octaves) break;
    value += amplitude * cnoise(p * frequency);
    frequency *= 2.0;
    amplitude *= 0.5;
  }
  
  return value;
}

void main() {
  vec2 uv = vUv * uScale;
  
  // Directional animation
  vec2 direction = normalize(vec2(uDirX, uDirY) + 0.001);
  uv += direction * uTime * uSpeed * 0.1;
  
  // Domain warping
  if (uWarpAmount > 0.0) {
    float warpX = fbm(uv * uWarpScale, 3);
    float warpY = fbm(uv * uWarpScale + vec2(5.2, 1.3), 3);
    uv += vec2(warpX, warpY) * uWarpAmount;
  }
  
  float noise = fbm(uv, int(uOctaves));
  noise = noise * 0.5 + 0.5; // Normalize to 0-1
  
  // Contrast and brightness
  noise = (noise - 0.5) * (1.0 + uContrast) + 0.5 + uBrightness;
  
  // Threshold with soft edge
  if (uThreshold > 0.0) {
    noise = smoothstep(uThreshold - uEdgeSoftness, uThreshold + uEdgeSoftness, noise);
  }
  
  noise = clamp(noise, 0.0, 1.0);
  
  vec3 color = mix(uColor1, uColor2, noise);
  
  gl_FragColor = vec4(color, 1.0);
}
