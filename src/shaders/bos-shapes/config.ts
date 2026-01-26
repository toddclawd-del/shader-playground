import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const bosShapesConfig: ShaderConfig = {
  name: 'BoS: Shapes',
  description: 'Circle SDF pattern from The Book of Shaders',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    uColor: { value: '#ffffff', type: 'color', label: 'Shape Color' },
    uBackground: { value: '#000000', type: 'color', label: 'Background' },
    uRadius: { value: 0.3, min: 0.01, max: 0.5, step: 0.01, type: 'float', label: 'Radius' },
    uSoftness: { value: 0.01, min: 0.001, max: 0.2, step: 0.001, type: 'float', label: 'Softness' },
    uCount: { value: 1, min: 1, max: 10, step: 1, type: 'float', label: 'Grid Count' },
    uAnimated: { value: 0, min: 0, max: 1, step: 1, type: 'float', label: 'Animated' },
  },
}
