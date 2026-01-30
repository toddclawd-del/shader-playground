import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const truchetTilesConfig: ShaderConfig = {
  name: 'Truchet Tiles',
  description: 'Procedural tiling pattern where randomly rotated tiles connect to form continuous paths. Creates woven, maze-like, and organic patterns from simple rules.',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    
    // Pattern controls
    uScale: { 
      value: 8.0, 
      min: 2.0, 
      max: 30.0, 
      step: 1.0, 
      type: 'float', 
      label: 'Grid Size'
    },
    uLineWidth: { 
      value: 0.12, 
      min: 0.02, 
      max: 0.3, 
      step: 0.01, 
      type: 'float', 
      label: 'Line Width'
    },
    uTileStyle: { 
      value: 0, 
      min: 0, 
      max: 4, 
      step: 1, 
      type: 'float', 
      label: 'Style (0-4)'
    },
    uAntiAlias: { 
      value: 1.5, 
      min: 0.5, 
      max: 4.0, 
      step: 0.1, 
      type: 'float', 
      label: 'Anti-Aliasing'
    },
    
    // Animation controls
    uAnimSpeed: { 
      value: 0.3, 
      min: 0.0, 
      max: 2.0, 
      step: 0.05, 
      type: 'float', 
      label: 'Animation Speed'
    },
    uColorSpeed: { 
      value: 0.2, 
      min: 0.0, 
      max: 1.0, 
      step: 0.05, 
      type: 'float', 
      label: 'Color Flow'
    },
    uAnimateTiles: { 
      value: false, 
      type: 'bool', 
      label: 'Animate Flips'
    },
    
    // Colors
    uColor1: { value: '#00d4ff', type: 'color', label: 'Color 1' },
    uColor2: { value: '#ff0080', type: 'color', label: 'Color 2' },
    uColor3: { value: '#ffcc00', type: 'color', label: 'Color 3' },
    uBackgroundColor: { value: '#0a0a1a', type: 'color', label: 'Background' },
  },
}
