import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const chromaticAberrationConfig: ShaderConfig = {
  name: 'Chromatic Aberration',
  description: 'RGB channel separation with barrel distortion and vignette effects',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    uAberrationStrength: { value: 0.5, min: 0, max: 1, step: 0.01, type: 'float', label: 'Aberration Strength' },
    uMode: { value: 0, min: 0, max: 2, step: 1, type: 'float', label: 'Mode (0=Radial, 1=Directional, 2=Mouse)' },
    uRedOffset: { value: 1.0, min: -2, max: 2, step: 0.1, type: 'float', label: 'Red Offset' },
    uGreenOffset: { value: 0.0, min: -2, max: 2, step: 0.1, type: 'float', label: 'Green Offset' },
    uBlueOffset: { value: -1.0, min: -2, max: 2, step: 0.1, type: 'float', label: 'Blue Offset' },
    uBarrelDistortion: { value: 0.2, min: -0.5, max: 0.5, step: 0.05, type: 'float', label: 'Barrel Distortion' },
    uVignette: { value: 0.3, min: 0, max: 1, step: 0.05, type: 'float', label: 'Vignette' },
    uColor1: { value: '#1a1a2e', type: 'color', label: 'Color 1' },
    uColor2: { value: '#e94560', type: 'color', label: 'Color 2' },
    uColor3: { value: '#0f3460', type: 'color', label: 'Color 3' },
  },
}
