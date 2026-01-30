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
    uParticleCount: { value: 40, min: 10, max: 80, step: 1, type: 'float', label: 'Particle Count' },
    uParticleSize: { value: 4, min: 1, max: 10, step: 0.5, type: 'float', label: 'Particle Size' },
    uSpeed: { value: 0.8, min: 0.1, max: 2.0, step: 0.1, type: 'float', label: 'Flow Speed' },
    uMouseForce: { value: 0.7, min: -1, max: 1, step: 0.1, type: 'float', label: 'Mouse Attraction' },
    uColorMode: { value: 1, min: 0, max: 2, step: 1, type: 'float', label: 'Coloring Mode' },
    uShape: { value: 1, min: 0, max: 2, step: 1, type: 'float', label: 'Particle Shape' },
    uColor1: { value: '#f97316', type: 'color', label: 'Primary' },
    uColor2: { value: '#8b5cf6', type: 'color', label: 'Secondary' },
    uBackgroundColor: { value: '#030712', type: 'color', label: 'Background' },
  },
}
