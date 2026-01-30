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
    uFeedRate: { value: 0.06, min: 0.01, max: 0.1, step: 0.005, type: 'float', label: 'Growth Rate' },
    uKillRate: { value: 0.055, min: 0.01, max: 0.1, step: 0.005, type: 'float', label: 'Decay Rate' },
    uDiffusionA: { value: 0.6, min: 0.1, max: 1.0, step: 0.1, type: 'float', label: 'Pattern Scale' },
    uDiffusionB: { value: 0.3, min: 0.1, max: 1.0, step: 0.1, type: 'float', label: 'Detail Level' },
    uBrushSize: { value: 0.12, min: 0.02, max: 0.3, step: 0.02, type: 'float', label: 'Brush Size' },
    uColor1: { value: '#0c1220', type: 'color', label: 'Deep Tone' },
    uColor2: { value: '#dc2626', type: 'color', label: 'Mid Tone' },
    uColor3: { value: '#fef3c7', type: 'color', label: 'Highlight' },
    uBackgroundColor: { value: '#030712', type: 'color', label: 'Background' },
  },
}
