import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const bosPatternsConfig: ShaderConfig = {
  name: 'BoS: Patterns',
  description: 'Tiled cross pattern from The Book of Shaders',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    uColor1: { value: '#264653', type: 'color', label: 'Color 1' },
    uColor2: { value: '#e9c46a', type: 'color', label: 'Color 2' },
    uScale: { value: 5, min: 1, max: 20, step: 1, type: 'float', label: 'Scale' },
    uRotation: { value: 0.785, min: 0, max: 6.28, step: 0.01, type: 'float', label: 'Rotation' },
    uOffset: { value: 0.5, min: 0, max: 1, step: 0.01, type: 'float', label: 'Row Offset' },
  },
}
