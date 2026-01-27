varying vec2 vUv;
varying float vDisplacement;
varying vec3 vNormal;
varying vec3 vPosition;

uniform float uTime;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uColor3;
uniform float uColorMix;
uniform float uFresnelPower;
uniform float uFresnelIntensity;
uniform float uGradientShift;

void main() {
  // Normalize displacement for coloring
  float d = vDisplacement * uColorMix + 0.5;
  d += sin(uTime * 0.5) * uGradientShift * 0.1; // Animated color shift
  d = clamp(d, 0.0, 1.0);
  
  // Three-color gradient based on displacement
  vec3 color;
  if (d < 0.5) {
    color = mix(uColor1, uColor2, d * 2.0);
  } else {
    color = mix(uColor2, uColor3, (d - 0.5) * 2.0);
  }
  
  // Fresnel rim lighting
  if (uFresnelIntensity > 0.0) {
    vec3 viewDir = normalize(cameraPosition - vPosition);
    float fresnel = pow(1.0 - abs(dot(viewDir, vNormal)), uFresnelPower);
    color += fresnel * uFresnelIntensity;
  }
  
  gl_FragColor = vec4(color, 1.0);
}
