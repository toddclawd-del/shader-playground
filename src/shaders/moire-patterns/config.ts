import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const moirePatternsConfig: ShaderConfig = {
  name: 'Moiré Patterns',
  description: 'Hypnotic interference patterns from overlapping periodic structures. The same phenomenon behind silk shimmer, screen door photography, and aliasing artifacts.',
  vertexShader,
  fragmentShader,
  uniforms: {
    // Time (auto-animated)
    uTime: { value: 0, type: 'float' },
    
    // Pattern Type: 0=Radial, 1=Linear, 2=Grid, 3=Combined, 4=Spiral
    uPatternType: { 
      value: 0, 
      min: 0, 
      max: 4, 
      step: 1, 
      type: 'float', 
      label: 'Pattern (0=Radial, 1=Linear, 2=Grid, 3=Combined, 4=Spiral)',
    },
    
    // Frequencies - the KEY to moiré: slightly different frequencies create interference
    uFrequency1: { 
      value: 15.0, 
      min: 5.0, 
      max: 50.0, 
      step: 0.5, 
      type: 'float', 
      label: 'Frequency 1',
    },
    uFrequency2: { 
      value: 16.0, 
      min: 5.0, 
      max: 50.0, 
      step: 0.5, 
      type: 'float', 
      label: 'Frequency 2',
    },
    
    // Rotation - small angle differences create dramatic moiré
    uRotation1: { 
      value: 0.0, 
      min: 0.0, 
      max: 6.283, 
      step: 0.01, 
      type: 'float', 
      label: 'Rotation 1',
    },
    uRotation2: { 
      value: 0.05, 
      min: 0.0, 
      max: 6.283, 
      step: 0.01, 
      type: 'float', 
      label: 'Rotation 2',
    },
    
    // Line/band width
    uLineWidth: { 
      value: 0.3, 
      min: 0.05, 
      max: 0.8, 
      step: 0.01, 
      type: 'float', 
      label: 'Line Width',
    },
    
    // Center offset for radial patterns
    uCenterOffset: { 
      value: 1.0, 
      min: 0.0, 
      max: 5.0, 
      step: 0.1, 
      type: 'float', 
      label: 'Center Offset',
    },
    
    // Animation
    uAnimSpeed: { 
      value: 0.3, 
      min: 0.0, 
      max: 2.0, 
      step: 0.05, 
      type: 'float', 
      label: 'Animation Speed',
    },
    uWaveDistortion: { 
      value: 0.0, 
      min: 0.0, 
      max: 1.0, 
      step: 0.05, 
      type: 'float', 
      label: 'Wave Distortion',
    },
    
    // Appearance
    uContrast: { 
      value: 1.0, 
      min: 0.3, 
      max: 3.0, 
      step: 0.1, 
      type: 'float', 
      label: 'Contrast',
    },
    uColorPhase: { 
      value: 0.0, 
      min: 0.0, 
      max: 1.0, 
      step: 0.01, 
      type: 'float', 
      label: 'Color Phase',
    },
    
    // Colors
    uColor1: { value: '#ff3366', type: 'color', label: 'Color 1' },
    uColor2: { value: '#33ccff', type: 'color', label: 'Color 2' },
    uColor3: { value: '#ffcc33', type: 'color', label: 'Color 3' },
    uBackgroundColor: { value: '#0a0a0f', type: 'color', label: 'Background' },
  },
}
