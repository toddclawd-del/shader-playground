import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const rippleConfig: ShaderConfig = {
  name: 'Water Ripples',
  description: 'Interactive water surface with mouse ripples',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    uRippleSpeed: { value: 0.5, min: 0.1, max: 2, step: 0.1, type: 'float', label: 'Ripple Speed' },
    uRippleDecay: { value: 2, min: 0.5, max: 5, step: 0.1, type: 'float', label: 'Ripple Decay' },
    uRippleSize: { value: 1, min: 0.5, max: 3, step: 0.1, type: 'float', label: 'Ripple Size' },
    uRefraction: { value: 1, min: 0, max: 3, step: 0.1, type: 'float', label: 'Refraction' },
    uWaveFreq: { value: 8, min: 2, max: 20, step: 1, type: 'float', label: 'Wave Frequency' },
    uWaveAmp: { value: 0.1, min: 0, max: 0.3, step: 0.01, type: 'float', label: 'Wave Amplitude' },
    uColor1: { value: '#0077be', type: 'color', label: 'Water Color 1' },
    uColor2: { value: '#00a8cc', type: 'color', label: 'Water Color 2' },
    uBackgroundColor: { value: '#001f3f', type: 'color', label: 'Deep Color' },
    uReflectivity: { value: 0.5, min: 0, max: 1, step: 0.1, type: 'float', label: 'Reflectivity' },
  },
}
