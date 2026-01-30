import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const gradientMeshConfig: ShaderConfig = {
  name: 'Gradient Mesh',
  description: 'Organic mesh gradient with flowing aurora-like colors and mouse interaction',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    uColor1: { value: '#ff6b6b', type: 'color', label: 'Color 1' },
    uColor2: { value: '#4ecdc4', type: 'color', label: 'Color 2' },
    uColor3: { value: '#a855f7', type: 'color', label: 'Color 3' },
    uColor4: { value: '#3b82f6', type: 'color', label: 'Color 4' },
    uSpeed: { value: 0.5, min: 0.1, max: 2.0, step: 0.1, type: 'float', label: 'Speed' },
    uScale: { value: 1.0, min: 0.5, max: 5.0, step: 0.1, type: 'float', label: 'Scale' },
    uComplexity: { value: 5, min: 1, max: 10, step: 1, type: 'float', label: 'Complexity' },
    uMouseInfluence: { value: 0.5, min: 0, max: 1, step: 0.1, type: 'float', label: 'Mouse Influence' },
  },
}
