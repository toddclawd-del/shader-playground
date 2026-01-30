import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const voronoiAdvancedConfig: ShaderConfig = {
  name: 'Voronoi Advanced',
  description: 'Animated Voronoi cells with mouse interaction to attract or repel points',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    uCellCount: { value: 8, min: 3, max: 30, step: 1, type: 'float', label: 'Cell Count' },
    uEdgeThickness: { value: 0.05, min: 0, max: 0.15, step: 0.01, type: 'float', label: 'Edge Thickness' },
    uAnimationSpeed: { value: 0.5, min: 0, max: 2, step: 0.1, type: 'float', label: 'Animation Speed' },
    uColorMode: { value: 0, min: 0, max: 2, step: 1, type: 'float', label: 'Color Mode (0=Cells, 1=Edges, 2=Distance)' },
    uMouseMode: { value: 1, min: -1, max: 1, step: 1, type: 'float', label: 'Mouse Mode (-1=Repel, 0=None, 1=Attract)' },
    uColor1: { value: '#ff6b6b', type: 'color', label: 'Color 1' },
    uColor2: { value: '#4ecdc4', type: 'color', label: 'Color 2' },
    uColor3: { value: '#ffe66d', type: 'color', label: 'Color 3' },
    uEdgeColor: { value: '#1a1a2e', type: 'color', label: 'Edge Color' },
    uBackgroundColor: { value: '#16213e', type: 'color', label: 'Background' },
  },
}
