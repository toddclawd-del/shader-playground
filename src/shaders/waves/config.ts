import fragmentShader from './fragment.glsl'
import vertexShader from '../common/displace-vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const wavesConfig: ShaderConfig = {
  name: 'Waves',
  description: 'Vertex displacement with multiple wave types and twist',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    uWaveType: { value: 0, min: 0, max: 2, step: 1, type: 'float', label: 'Wave Type (0-2)' },
    uAmplitude: { value: 0.3, min: 0, max: 1, step: 0.01, type: 'float', label: 'Amplitude' },
    uFrequency: { value: 3.0, min: 0.1, max: 10, step: 0.1, type: 'float', label: 'Frequency' },
    uSpeed: { value: 1.0, min: 0, max: 5, step: 0.1, type: 'float', label: 'Speed' },
    uDirX: { value: 0, min: -3, max: 3, step: 0.1, type: 'float', label: 'Dir X' },
    uDirY: { value: 0, min: -3, max: 3, step: 0.1, type: 'float', label: 'Dir Y' },
    uNoiseAmp: { value: 0, min: 0, max: 0.5, step: 0.01, type: 'float', label: 'Noise Amp' },
    uNoiseFreq: { value: 5, min: 1, max: 20, step: 0.5, type: 'float', label: 'Noise Freq' },
    uTwist: { value: 0, min: -2, max: 2, step: 0.05, type: 'float', label: 'Twist' },
    uColorMix: { value: 2, min: 0.5, max: 5, step: 0.1, type: 'float', label: 'Color Mix' },
    uGradientShift: { value: 0, min: 0, max: 2, step: 0.1, type: 'float', label: 'Color Shift' },
    uFresnelPower: { value: 2, min: 0.5, max: 5, step: 0.1, type: 'float', label: 'Fresnel Power' },
    uFresnelIntensity: { value: 0, min: 0, max: 1, step: 0.05, type: 'float', label: 'Fresnel' },
    uColor1: { value: '#0d1b2a', type: 'color', label: 'Valley Color' },
    uColor2: { value: '#1b4965', type: 'color', label: 'Mid Color' },
    uColor3: { value: '#5fa8d3', type: 'color', label: 'Peak Color' },
  },
}
