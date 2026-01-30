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
    uAberrationStrength: { value: 0.6, min: 0, max: 1, step: 0.01, type: 'float', label: 'Aberration Intensity' },
    uMode: { value: 0, min: 0, max: 2, step: 1, type: 'float', label: 'Aberration Mode' },
    uRedOffset: { value: 1.2, min: -2, max: 2, step: 0.1, type: 'float', label: 'Red Channel Shift' },
    uGreenOffset: { value: 0.0, min: -2, max: 2, step: 0.1, type: 'float', label: 'Green Channel Shift' },
    uBlueOffset: { value: -1.2, min: -2, max: 2, step: 0.1, type: 'float', label: 'Blue Channel Shift' },
    uBarrelDistortion: { value: 0.15, min: -0.5, max: 0.5, step: 0.05, type: 'float', label: 'Lens Distortion' },
    uVignette: { value: 0.35, min: 0, max: 1, step: 0.05, type: 'float', label: 'Vignette' },
    uColor1: { value: '#0f172a', type: 'color', label: 'Dark Tone' },
    uColor2: { value: '#f43f5e', type: 'color', label: 'Highlight' },
    uColor3: { value: '#3b82f6', type: 'color', label: 'Accent' },
  },
}
