import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const domainWarpConfig: ShaderConfig = {
  name: 'Domain Warping',
  description: 'Organic marble patterns via recursive noise distortion (Inigo Quilez technique)',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    uScale: { value: 3.0, min: 0.5, max: 10.0, step: 0.1, type: 'float', label: 'Scale' },
    uWarpIntensity1: { value: 4.0, min: 0.0, max: 8.0, step: 0.1, type: 'float', label: 'Warp 1 Intensity' },
    uWarpIntensity2: { value: 4.0, min: 0.0, max: 8.0, step: 0.1, type: 'float', label: 'Warp 2 Intensity' },
    uAnimSpeed: { value: 0.3, min: 0.0, max: 2.0, step: 0.05, type: 'float', label: 'Animation Speed' },
    uOctaves: { value: 5, min: 1, max: 8, step: 1, type: 'float', label: 'Noise Octaves' },
    uLacunarity: { value: 2.0, min: 1.5, max: 3.0, step: 0.1, type: 'float', label: 'Lacunarity' },
    uGain: { value: 0.5, min: 0.3, max: 0.7, step: 0.05, type: 'float', label: 'Gain (Persistence)' },
    uColorVariation: { value: 0.6, min: 0.0, max: 1.0, step: 0.05, type: 'float', label: 'Color Variation' },
    uColor1: { value: '#1a1a2e', type: 'color', label: 'Color 1 (Base)' },
    uColor2: { value: '#e94560', type: 'color', label: 'Color 2 (Pattern)' },
    uColor3: { value: '#0f3460', type: 'color', label: 'Color 3 (Warp Q)' },
    uColor4: { value: '#16213e', type: 'color', label: 'Color 4 (Warp R)' },
    uBackgroundColor: { value: '#0a0a12', type: 'color', label: 'Background' },
  },
}
