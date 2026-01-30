import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const distortionConfig: ShaderConfig = {
  name: 'UV Distortion',
  description: 'Various UV distortion effects: ripple, wave, twist, and bulge',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    uDistortionType: { value: 2, min: 0, max: 3, step: 1, type: 'float', label: 'Distortion Type' },
    uStrength: { value: 0.6, min: 0, max: 1, step: 0.05, type: 'float', label: 'Strength' },
    uFrequency: { value: 8, min: 1, max: 20, step: 1, type: 'float', label: 'Pattern Density' },
    uSpeed: { value: 1.2, min: 0, max: 2, step: 0.1, type: 'float', label: 'Animation Speed' },
    uMouseRadius: { value: 0.25, min: 0.1, max: 0.5, step: 0.05, type: 'float', label: 'Mouse Radius' },
    uColor1: { value: '#8b5cf6', type: 'color', label: 'Primary Color' },
    uColor2: { value: '#06b6d4', type: 'color', label: 'Accent Color' },
    uBackgroundColor: { value: '#0c0a1d', type: 'color', label: 'Background' },
  },
}
