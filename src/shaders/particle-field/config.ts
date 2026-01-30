import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const particleFieldConfig: ShaderConfig = {
  name: 'Particle Field',
  description: 'GPU-simulated particles with curl noise movement and mouse interaction',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    uParticleCount: { value: 50, min: 10, max: 100, step: 1, type: 'float', label: 'Particle Count' },
    uParticleSize: { value: 3, min: 1, max: 10, step: 0.5, type: 'float', label: 'Particle Size' },
    uSpeed: { value: 1.0, min: 0.1, max: 2.0, step: 0.1, type: 'float', label: 'Speed' },
    uMouseForce: { value: 0.5, min: -1, max: 1, step: 0.1, type: 'float', label: 'Mouse Force (±attract/repel)' },
    uColorMode: { value: 0, min: 0, max: 2, step: 1, type: 'float', label: 'Color Mode (0=Solid, 1=Velocity, 2=Position)' },
    uShape: { value: 1, min: 0, max: 2, step: 1, type: 'float', label: 'Shape (0=Points, 1=Circles, 2=Squares)' },
    uColor1: { value: '#ff6b6b', type: 'color', label: 'Color 1' },
    uColor2: { value: '#4ecdc4', type: 'color', label: 'Color 2' },
    uBackgroundColor: { value: '#0a0a0f', type: 'color', label: 'Background' },
  },
}
