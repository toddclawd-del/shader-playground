import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const textureConfig: ShaderConfig = {
  name: 'Texture FX',
  description: 'Texture with distortion, RGB shift, and tint effects',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    uTexture: { value: null, type: 'texture', label: 'Texture' },
    uDistortion: { value: 0, min: 0, max: 2, step: 0.01, type: 'float', label: 'Distortion' },
    uSpeed: { value: 1, min: 0, max: 5, step: 0.1, type: 'float', label: 'Speed' },
    uRgbShift: { value: 0, min: 0, max: 5, step: 0.1, type: 'float', label: 'RGB Shift' },
    uTint: { value: '#ffffff', type: 'color', label: 'Tint Color' },
    uTintStrength: { value: 0, min: 0, max: 1, step: 0.01, type: 'float', label: 'Tint Strength' },
  },
}
