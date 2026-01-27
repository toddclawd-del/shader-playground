varying vec2 vUv;

uniform float uTime;
uniform sampler2D uTexture;
uniform float uDistortion;
uniform float uDistortFreq;
uniform float uSpeed;
uniform float uRgbShift;
uniform vec3 uTint;
uniform float uTintStrength;
uniform float uZoom;
uniform float uRotation;
uniform float uRotationSpeed;
uniform float uVignetteSize;
uniform float uVignetteSmooth;
uniform float uScanlines;
uniform float uScanlineSpeed;
uniform float uGlitch;
uniform float uMirrorX;
uniform float uMirrorY;

mat2 rotate2d(float angle) {
  return mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
}

float random(vec2 st) {
  return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void main() {
  vec2 uv = vUv;
  
  // Center for transformations
  uv -= 0.5;
  
  // Rotation
  float rot = uRotation + uTime * uRotationSpeed;
  uv = rotate2d(rot) * uv;
  
  // Zoom
  uv /= uZoom;
  
  uv += 0.5;
  
  // Mirror
  if (uMirrorX > 0.5) {
    uv.x = abs(uv.x - 0.5) + 0.5;
  }
  if (uMirrorY > 0.5) {
    uv.y = abs(uv.y - 0.5) + 0.5;
  }
  
  // Distortion
  if (uDistortion > 0.0) {
    float distortX = sin(uv.y * uDistortFreq + uTime * uSpeed) * uDistortion * 0.1;
    float distortY = cos(uv.x * uDistortFreq + uTime * uSpeed) * uDistortion * 0.1;
    uv += vec2(distortX, distortY);
  }
  
  // Glitch effect
  if (uGlitch > 0.0) {
    float glitchLine = step(0.99 - uGlitch * 0.1, random(vec2(floor(uv.y * 20.0), floor(uTime * 10.0))));
    uv.x += glitchLine * (random(vec2(uTime)) - 0.5) * 0.1 * uGlitch;
  }
  
  vec4 color;
  
  // RGB shift
  if (uRgbShift > 0.0) {
    float shift = uRgbShift * 0.01;
    color.r = texture2D(uTexture, uv + vec2(shift, 0.0)).r;
    color.g = texture2D(uTexture, uv).g;
    color.b = texture2D(uTexture, uv - vec2(shift, 0.0)).b;
    color.a = texture2D(uTexture, uv).a;
  } else {
    color = texture2D(uTexture, uv);
  }
  
  // Apply tint
  color.rgb = mix(color.rgb, color.rgb * uTint, uTintStrength);
  
  // Scanlines
  if (uScanlines > 0.0) {
    float scanline = sin((vUv.y + uTime * uScanlineSpeed * 0.1) * 400.0) * 0.5 + 0.5;
    color.rgb *= 1.0 - scanline * uScanlines * 0.3;
  }
  
  // Vignette
  if (uVignetteSize > 0.0) {
    vec2 vignetteUv = vUv * (1.0 - vUv.yx);
    float vignette = vignetteUv.x * vignetteUv.y * 15.0;
    vignette = pow(vignette, uVignetteSize * uVignetteSmooth);
    color.rgb *= vignette;
  }
  
  gl_FragColor = color;
}
