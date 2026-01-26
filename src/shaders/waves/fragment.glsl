varying vec2 vUv;
varying float vDisplacement;

uniform float uTime;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uColor3;

void main() {
  // Use displacement for coloring
  float d = vDisplacement * 2.0 + 0.5;
  
  vec3 color;
  if (d < 0.5) {
    color = mix(uColor1, uColor2, d * 2.0);
  } else {
    color = mix(uColor2, uColor3, (d - 0.5) * 2.0);
  }
  
  // Add rim lighting effect based on view angle
  float fresnel = pow(1.0 - abs(dot(vec3(0.0, 0.0, 1.0), normalize(vec3(vUv - 0.5, 0.5)))), 2.0);
  color += fresnel * 0.2;
  
  gl_FragColor = vec4(color, 1.0);
}
