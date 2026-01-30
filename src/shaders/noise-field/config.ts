import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const noiseFieldConfig: ShaderConfig = {
  name: 'Noise Field',
  description: 'Multiple noise types (Perlin, Simplex, Worley) with FBM and various color modes',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    uNoiseType: { value: 0, min: 0, max: 2, step: 1, type: 'float', label: 'Noise Type (0=Perlin, 1=Simplex, 2=Worley)' },
    uOctaves: { value: 4, min: 1, max: 8, step: 1, type: 'float', label: 'Octaves' },
    uFrequency: { value: 3.0, min: 0.5, max: 10, step: 0.5, type: 'float', label: 'Frequency' },
    uAmplitude: { value: 1.0, min: 0.1, max: 2.0, step: 0.1, type: 'float', label: 'Amplitude' },
    uSpeed: { value: 1.0, min: 0.1, max: 3.0, step: 0.1, type: 'float', label: 'Speed' },
    uColorMode: { value: 1, min: 0, max: 2, step: 1, type: 'float', label: 'Color Mode (0=Grayscale, 1=Gradient, 2=Heatmap)' },
    uColor1: { value: '#1a1a2e', type: 'color', label: 'Color 1' },
    uColor2: { value: '#e94560', type: 'color', label: 'Color 2' },
    uBackgroundColor: { value: '#0a0a0f', type: 'color', label: 'Background' },
  },
}
