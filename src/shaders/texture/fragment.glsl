varying vec2 vUv;

uniform float uTime;
uniform sampler2D uTexture;
uniform float uDistortion;
uniform float uSpeed;
uniform float uRgbShift;
uniform vec3 uTint;
uniform float uTintStrength;

void main() {
  vec2 uv = vUv;
  
  // Distortion
  if (uDistortion > 0.0) {
    float distortX = sin(uv.y * 10.0 + uTime * uSpeed) * uDistortion * 0.1;
    float distortY = cos(uv.x * 10.0 + uTime * uSpeed) * uDistortion * 0.1;
    uv += vec2(distortX, distortY);
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
  
  gl_FragColor = color;
}
