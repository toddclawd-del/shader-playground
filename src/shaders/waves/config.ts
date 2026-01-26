import fragmentShader from './fragment.glsl'
import vertexShader from '../common/displace-vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const wavesConfig: ShaderConfig = {
  name: 'Waves',
  description: 'Vertex displacement waves with tri-color gradient',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    uAmplitude: { value: 0.3, min: 0, max: 1, step: 0.01, type: 'float', label: 'Amplitude' },
    uFrequency: { value: 3.0, min: 0.1, max: 10, step: 0.1, type: 'float', label: 'Frequency' },
    uColor1: { value: '#0d1b2a', type: 'color', label: 'Valley Color' },
    uColor2: { value: '#1b4965', type: 'color', label: 'Mid Color' },
    uColor3: { value: '#5fa8d3', type: 'color', label: 'Peak Color' },
  },
}
