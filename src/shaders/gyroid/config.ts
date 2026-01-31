import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const gyroidConfig: ShaderConfig = {
  name: 'Gyroid',
  description: 'Triply periodic minimal surface — organic patterns from elegant math',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    
    // Pattern controls
    uScale: { value: 3.0, min: 0.5, max: 10.0, step: 0.1, type: 'float', label: 'Scale' },
    uSliceSpeed: { value: 0.3, min: 0, max: 2.0, step: 0.05, type: 'float', label: 'Slice Speed' },
    uSliceOffset: { value: 0, min: -10, max: 10, step: 0.1, type: 'float', label: 'Slice Offset' },
    uThickness: { value: 0.15, min: 0.01, max: 0.5, step: 0.01, type: 'float', label: 'Surface Thickness' },
    uDistortion: { value: 0.0, min: 0, max: 1.0, step: 0.05, type: 'float', label: 'Distortion' },
    
    // FBM controls
    uOctaves: { value: 1, min: 1, max: 6, step: 1, type: 'float', label: 'Octaves' },
    uLacunarity: { value: 2.0, min: 1.5, max: 3.0, step: 0.1, type: 'float', label: 'Lacunarity' },
    uPersistence: { value: 0.5, min: 0.2, max: 0.8, step: 0.05, type: 'float', label: 'Persistence' },
    
    // Visualization mode
    uVisualization: { value: 3, min: 0, max: 4, step: 1, type: 'float', label: 'Mode (0-4)' },
    uContourFrequency: { value: 5.0, min: 1, max: 20, step: 0.5, type: 'float', label: 'Contour Frequency' },
    uGlow: { value: 0.3, min: 0, max: 1.0, step: 0.05, type: 'float', label: 'Glow' },
    uColorMix: { value: 0.0, min: 0, max: 1.0, step: 0.05, type: 'float', label: 'Custom Color Mix' },
    
    // Colors
    uColor1: { value: '#e94560', type: 'color', label: 'Color 1' },
    uColor2: { value: '#0f3460', type: 'color', label: 'Color 2' },
    uColor3: { value: '#4ecca3', type: 'color', label: 'Color 3' },
    uBackgroundColor: { value: '#1a1a2e', type: 'color', label: 'Background' },
  },
}
