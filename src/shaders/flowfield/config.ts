import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const flowfieldConfig: ShaderConfig = {
  name: 'Flow Field',
  description: 'Curl noise particles with mouse interaction',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    uNoiseScale: { value: 3, min: 1, max: 10, step: 0.5, type: 'float', label: 'Noise Scale' },
    uNoiseSpeed: { value: 0.3, min: 0, max: 1, step: 0.05, type: 'float', label: 'Noise Speed' },
    uMouseForce: { value: 0.5, min: 0, max: 2, step: 0.1, type: 'float', label: 'Mouse Force' },
    uTrailLength: { value: 2, min: 0.5, max: 5, step: 0.1, type: 'float', label: 'Trail Length' },
    uParticleDensity: { value: 15, min: 5, max: 30, step: 1, type: 'float', label: 'Particle Density' },
    uParticleSize: { value: 0.02, min: 0.005, max: 0.05, step: 0.005, type: 'float', label: 'Particle Size' },
    uColor1: { value: '#ff6b9d', type: 'color', label: 'Color 1' },
    uColor2: { value: '#c44dff', type: 'color', label: 'Color 2' },
    uBackgroundColor: { value: '#0a0a0f', type: 'color', label: 'Background' },
    uColorMix: { value: 0.5, min: 0, max: 1, step: 0.1, type: 'float', label: 'Color Mix' },
  },
}
