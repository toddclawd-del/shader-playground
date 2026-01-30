import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const reactionDiffusionConfig: ShaderConfig = {
  name: 'Reaction Diffusion',
  description: 'Gray-Scott inspired patterns with turing spots and cell-like structures',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    uFeedRate: { value: 0.055, min: 0.01, max: 0.1, step: 0.005, type: 'float', label: 'Feed Rate' },
    uKillRate: { value: 0.062, min: 0.01, max: 0.1, step: 0.005, type: 'float', label: 'Kill Rate' },
    uDiffusionA: { value: 0.5, min: 0.1, max: 1.0, step: 0.1, type: 'float', label: 'Diffusion A' },
    uDiffusionB: { value: 0.25, min: 0.1, max: 1.0, step: 0.1, type: 'float', label: 'Diffusion B' },
    uBrushSize: { value: 0.1, min: 0.02, max: 0.3, step: 0.02, type: 'float', label: 'Brush Size' },
    uColor1: { value: '#1a1a2e', type: 'color', label: 'Color 1 (Low)' },
    uColor2: { value: '#e94560', type: 'color', label: 'Color 2 (Mid)' },
    uColor3: { value: '#f8f0e3', type: 'color', label: 'Color 3 (High)' },
    uBackgroundColor: { value: '#0f0f23', type: 'color', label: 'Background' },
  },
}
