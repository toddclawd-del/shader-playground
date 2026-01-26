import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const gradientConfig: ShaderConfig = {
  name: 'Gradient',
  description: 'Simple two-color gradient with angle control',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    uColor1: { value: '#ff6b6b', type: 'color', label: 'Color 1' },
    uColor2: { value: '#4ecdc4', type: 'color', label: 'Color 2' },
    uAngle: { value: 45, min: 0, max: 360, step: 1, type: 'float', label: 'Angle' },
    uAnimated: { value: 0, min: 0, max: 1, step: 1, type: 'float', label: 'Animated' },
  },
}
