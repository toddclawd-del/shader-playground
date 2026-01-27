import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const bosPatternsConfig: ShaderConfig = {
  name: 'BoS: Patterns',
  description: 'Animated tiled cross pattern with morphing and rotation',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    uColor1: { value: '#264653', type: 'color', label: 'Color 1' },
    uColor2: { value: '#e9c46a', type: 'color', label: 'Color 2' },
    uScale: { value: 5, min: 1, max: 20, step: 1, type: 'float', label: 'Scale' },
    uCrossSize: { value: 0.4, min: 0.1, max: 0.8, step: 0.01, type: 'float', label: 'Cross Size' },
    uCrossRatio: { value: 0.25, min: 0.1, max: 0.9, step: 0.01, type: 'float', label: 'Cross Ratio' },
    uRotation: { value: 0.785, min: 0, max: 6.28, step: 0.01, type: 'float', label: 'Rotation' },
    uRotationSpeed: { value: 0, min: 0, max: 2, step: 0.05, type: 'float', label: 'Rot Speed' },
    uOffset: { value: 0.5, min: 0, max: 1, step: 0.01, type: 'float', label: 'Row Offset' },
    uOffsetAnim: { value: 0, min: 0, max: 3, step: 0.1, type: 'float', label: 'Offset Anim' },
    uPulseSpeed: { value: 2, min: 0.5, max: 5, step: 0.1, type: 'float', label: 'Pulse Speed' },
    uPulseAmp: { value: 0, min: 0, max: 3, step: 0.1, type: 'float', label: 'Pulse Amp' },
    uMorphSpeed: { value: 2, min: 0.5, max: 5, step: 0.1, type: 'float', label: 'Morph Speed' },
    uMorphAmp: { value: 0, min: 0, max: 3, step: 0.1, type: 'float', label: 'Morph Amp' },
  },
}
