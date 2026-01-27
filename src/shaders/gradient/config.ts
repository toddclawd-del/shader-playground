import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const gradientConfig: ShaderConfig = {
  name: 'Gradient',
  description: 'Three-color gradient with wave distortion and animation',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    uColor1: { value: '#ff6b6b', type: 'color', label: 'Color 1' },
    uColor2: { value: '#4ecdc4', type: 'color', label: 'Color 2' },
    uColor3: { value: '#45b7d1', type: 'color', label: 'Color 3' },
    uAngle: { value: 45, min: 0, max: 360, step: 1, type: 'float', label: 'Angle' },
    uMidPoint: { value: 0.5, min: 0.1, max: 0.9, step: 0.01, type: 'float', label: 'Mid Point' },
    uHardness: { value: 0, min: 0, max: 0.99, step: 0.01, type: 'float', label: 'Hardness' },
    uAnimSpeed: { value: 0, min: 0, max: 5, step: 0.1, type: 'float', label: 'Scroll Speed' },
    uWaveFreq: { value: 5, min: 1, max: 20, step: 0.5, type: 'float', label: 'Wave Freq' },
    uWaveAmp: { value: 0, min: 0, max: 2, step: 0.05, type: 'float', label: 'Wave Amp' },
    uPulseSpeed: { value: 2, min: 0.5, max: 10, step: 0.5, type: 'float', label: 'Pulse Speed' },
    uPulseAmp: { value: 0, min: 0, max: 2, step: 0.05, type: 'float', label: 'Pulse Amp' },
  },
}
