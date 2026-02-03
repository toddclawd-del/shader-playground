import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const kaleidoscopeConfig: ShaderConfig = {
  name: 'Kaleidoscope',
  description: 'N-fold mirror symmetry creates hypnotic mandala patterns. Combines polar coordinates with reflection to generate infinite variations from simple noise and geometric patterns.',
  vertexShader,
  fragmentShader,
  uniforms: {
    // Time (auto-animated)
    uTime: { value: 0, type: 'float' },
    
    // Symmetry controls
    uSegments: { value: 6, min: 2, max: 24, step: 1, type: 'float', label: 'Segments' },
    uRotation: { value: 0, min: 0, max: 6.28318, step: 0.01, type: 'float', label: 'Rotation' },
    uRotationSpeed: { value: 0.1, min: -1, max: 1, step: 0.01, type: 'float', label: 'Auto Rotate' },
    uZoom: { value: 1.0, min: 0.2, max: 5.0, step: 0.1, type: 'float', label: 'Zoom' },
    
    // Pattern controls
    uPatternStyle: { value: 0, min: 0, max: 4, step: 1, type: 'float', label: 'Style (0=Noise, 1=Voronoi, 2=Waves, 3=Spirals, 4=Geometric)' },
    uPatternScale: { value: 2.0, min: 0.5, max: 10.0, step: 0.1, type: 'float', label: 'Pattern Scale' },
    uDistortion: { value: 0.3, min: 0, max: 2.0, step: 0.05, type: 'float', label: 'Distortion' },
    uComplexity: { value: 5, min: 1, max: 8, step: 1, type: 'float', label: 'Complexity' },
    
    // Animation
    uPulse: { value: 0.0, min: 0, max: 1.0, step: 0.05, type: 'float', label: 'Pulse' },
    uFlowSpeed: { value: 1.0, min: 0, max: 3.0, step: 0.1, type: 'float', label: 'Flow Speed' },
    
    // Colors
    uColor1: { value: '#1a0533', type: 'color', label: 'Color 1 (Dark)' },
    uColor2: { value: '#6b2d5c', type: 'color', label: 'Color 2 (Mid)' },
    uColor3: { value: '#f7b267', type: 'color', label: 'Color 3 (Light)' },
    uColorCycles: { value: 2.0, min: 0.5, max: 10.0, step: 0.5, type: 'float', label: 'Color Cycles' },
    uSaturation: { value: 1.0, min: 0, max: 2.0, step: 0.1, type: 'float', label: 'Saturation' },
    uBrightness: { value: 1.0, min: 0.2, max: 2.0, step: 0.1, type: 'float', label: 'Brightness' },
    
    // Effects
    uCenterGlow: { value: 0.3, min: 0, max: 1.0, step: 0.05, type: 'float', label: 'Center Glow' },
    uEdgeFade: { value: 0.5, min: 0, max: 1.0, step: 0.05, type: 'float', label: 'Edge Fade' },
    uChromatic: { value: 0.0, min: 0, max: 2.0, step: 0.1, type: 'float', label: 'Chromatic Aberration' },
  },
}
