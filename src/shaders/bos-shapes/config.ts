import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const bosShapesConfig: ShaderConfig = {
  name: 'BoS: Shapes',
  description: 'SDF shapes with grid, rotation, and pulse animation',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    uShapeType: { value: 0, min: 0, max: 3, step: 1, type: 'float', label: 'Shape (0-3)' },
    uColor: { value: '#ffffff', type: 'color', label: 'Shape Color' },
    uBackground: { value: '#000000', type: 'color', label: 'Background' },
    uRadius: { value: 0.3, min: 0.01, max: 0.5, step: 0.01, type: 'float', label: 'Size' },
    uSoftness: { value: 0.01, min: 0.001, max: 0.2, step: 0.001, type: 'float', label: 'Softness' },
    uRingWidth: { value: 0.1, min: 0.01, max: 0.3, step: 0.01, type: 'float', label: 'Ring Width' },
    uCountX: { value: 1, min: 1, max: 10, step: 1, type: 'float', label: 'Grid X' },
    uCountY: { value: 1, min: 1, max: 10, step: 1, type: 'float', label: 'Grid Y' },
    uAnimSpeed: { value: 2, min: 0, max: 10, step: 0.5, type: 'float', label: 'Anim Speed' },
    uPulseAmp: { value: 0, min: 0, max: 3, step: 0.1, type: 'float', label: 'Pulse Amp' },
    uRotation: { value: 0, min: 0, max: 6.28, step: 0.1, type: 'float', label: 'Rotation' },
    uRotationSpeed: { value: 0, min: 0, max: 3, step: 0.1, type: 'float', label: 'Rot Speed' },
    uInvert: { value: 0, min: 0, max: 1, step: 1, type: 'float', label: 'Invert' },
  },
}
