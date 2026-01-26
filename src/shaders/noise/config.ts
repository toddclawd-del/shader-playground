import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const noiseConfig: ShaderConfig = {
  name: 'Perlin Noise',
  description: 'Classic Perlin noise with FBM (Fractional Brownian Motion)',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    uScale: { value: 3.0, min: 0.1, max: 20, step: 0.1, type: 'float', label: 'Scale' },
    uSpeed: { value: 1.0, min: 0, max: 5, step: 0.1, type: 'float', label: 'Speed' },
    uOctaves: { value: 4, min: 1, max: 8, step: 1, type: 'float', label: 'Octaves' },
    uColor1: { value: '#1a1a2e', type: 'color', label: 'Color 1' },
    uColor2: { value: '#e94560', type: 'color', label: 'Color 2' },
  },
}
