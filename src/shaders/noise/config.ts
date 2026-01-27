import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const noiseConfig: ShaderConfig = {
  name: 'Perlin Noise',
  description: 'FBM noise with domain warping and threshold controls',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    uScale: { value: 3.0, min: 0.1, max: 20, step: 0.1, type: 'float', label: 'Scale' },
    uSpeed: { value: 1.0, min: 0, max: 5, step: 0.1, type: 'float', label: 'Speed' },
    uDirX: { value: 1.0, min: -1, max: 1, step: 0.1, type: 'float', label: 'Dir X' },
    uDirY: { value: 0.0, min: -1, max: 1, step: 0.1, type: 'float', label: 'Dir Y' },
    uOctaves: { value: 4, min: 1, max: 8, step: 1, type: 'float', label: 'Octaves' },
    uContrast: { value: 0, min: -1, max: 2, step: 0.05, type: 'float', label: 'Contrast' },
    uBrightness: { value: 0, min: -0.5, max: 0.5, step: 0.01, type: 'float', label: 'Brightness' },
    uThreshold: { value: 0, min: 0, max: 1, step: 0.01, type: 'float', label: 'Threshold' },
    uEdgeSoftness: { value: 0.1, min: 0.01, max: 0.5, step: 0.01, type: 'float', label: 'Edge Soft' },
    uWarpAmount: { value: 0, min: 0, max: 2, step: 0.05, type: 'float', label: 'Warp Amount' },
    uWarpScale: { value: 1, min: 0.2, max: 5, step: 0.1, type: 'float', label: 'Warp Scale' },
    uColor1: { value: '#1a1a2e', type: 'color', label: 'Color 1' },
    uColor2: { value: '#e94560', type: 'color', label: 'Color 2' },
  },
}
