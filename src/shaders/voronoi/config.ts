import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const voronoiConfig: ShaderConfig = {
  name: 'Voronoi Cells',
  description: 'Organic cellular patterns with animated points and customizable edges',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    uScale: { value: 5, min: 1, max: 20, step: 0.5, type: 'float', label: 'Cell Count' },
    uAnimationSpeed: { value: 0.5, min: 0, max: 2, step: 0.1, type: 'float', label: 'Animation Speed' },
    uEdgeWidth: { value: 0.05, min: 0, max: 0.2, step: 0.01, type: 'float', label: 'Edge Width' },
    uEdgeSharpness: { value: 0.8, min: 0, max: 1, step: 0.05, type: 'float', label: 'Edge Sharpness' },
    uCellColorMix: { value: 0.8, min: 0, max: 1, step: 0.05, type: 'float', label: 'Cell Color Mix' },
    uDistanceGlow: { value: 0.3, min: 0, max: 1, step: 0.05, type: 'float', label: 'Center Glow' },
    uJitter: { value: 1, min: 0, max: 1, step: 0.05, type: 'float', label: 'Point Jitter' },
    uColor1: { value: '#ff6b6b', type: 'color', label: 'Color 1' },
    uColor2: { value: '#4ecdc4', type: 'color', label: 'Color 2' },
    uColor3: { value: '#ffe66d', type: 'color', label: 'Color 3' },
    uEdgeColor: { value: '#1a1a2e', type: 'color', label: 'Edge Color' },
    uBackgroundColor: { value: '#16213e', type: 'color', label: 'Background' },
  },
}
