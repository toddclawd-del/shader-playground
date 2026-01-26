varying vec2 vUv;
varying vec3 vPosition;
varying vec3 vNormal;
varying float vDisplacement;

uniform float uTime;
uniform float uAmplitude;
uniform float uFrequency;

void main() {
  vUv = uv;
  vNormal = normal;
  
  // Calculate displacement
  float displacement = sin(position.x * uFrequency + uTime) * 
                       sin(position.y * uFrequency + uTime) * 
                       uAmplitude;
  
  vDisplacement = displacement;
  
  // Displace along normal
  vec3 newPosition = position + normal * displacement;
  vPosition = newPosition;
  
  gl_Position = projectionMatrix * modelViewMatrix * vec4(newPosition, 1.0);
}
