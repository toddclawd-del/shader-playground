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
    uDistortionType: { value: 0, min: 0, max: 3, step: 1, type: 'float', label: 'Type (0=Ripple, 1=Wave, 2=Twist, 3=Bulge)' },
    uStrength: { value: 0.5, min: 0, max: 1, step: 0.05, type: 'float', label: 'Strength' },
    uFrequency: { value: 10, min: 1, max: 20, step: 1, type: 'float', label: 'Frequency' },
    uSpeed: { value: 1.0, min: 0, max: 2, step: 0.1, type: 'float', label: 'Speed' },
    uMouseRadius: { value: 0.2, min: 0.1, max: 0.5, step: 0.05, type: 'float', label: 'Mouse Radius' },
    uColor1: { value: '#6366f1', type: 'color', label: 'Color 1' },
    uColor2: { value: '#ec4899', type: 'color', label: 'Color 2' },
    uBackgroundColor: { value: '#0f0f23', type: 'color', label: 'Background' },
  },
}
