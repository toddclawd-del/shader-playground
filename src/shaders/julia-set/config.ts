import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const juliaSetConfig: ShaderConfig = {
  name: 'Julia Set Fractal',
  description: 'Classic fractal exploring complex number iteration. Each point shows whether z = z² + c escapes to infinity.',
  vertexShader,
  fragmentShader,
  uniforms: {
    // Core uniform (auto-animated)
    uTime: { value: 0, type: 'float' },
    
    // Navigation controls
    uZoom: { 
      value: 1.0, 
      min: 0.1, 
      max: 50.0, 
      step: 0.1, 
      type: 'float', 
      label: 'Zoom',
      folder: 'Navigation'
    },
    uCenter: { 
      value: [0.0, 0.0], 
      type: 'vec2', 
      label: 'Center',
      folder: 'Navigation'
    },
    
    // Julia set constant c (the magic parameter!)
    uAnimateC: { 
      value: true, 
      type: 'bool', 
      label: 'Animate C',
      folder: 'Julia Constant'
    },
    uAnimSpeed: { 
      value: 0.15, 
      min: 0.01, 
      max: 1.0, 
      step: 0.01, 
      type: 'float', 
      label: 'Animation Speed',
      folder: 'Julia Constant'
    },
    uC: { 
      value: [-0.4, 0.6], 
      type: 'vec2', 
      label: 'C Value (when static)',
      folder: 'Julia Constant'
    },
    
    // Iteration control
    uMaxIterations: { 
      value: 100, 
      min: 10, 
      max: 500, 
      step: 10, 
      type: 'float',  // Leva doesn't handle int well, shader casts it
      label: 'Max Iterations',
      folder: 'Quality'
    },
    
    // Color controls
    uColorCycles: { 
      value: 3.0, 
      min: 0.5, 
      max: 20.0, 
      step: 0.5, 
      type: 'float', 
      label: 'Color Cycles',
      folder: 'Colors'
    },
    uColor1: { 
      value: '#0a0a2e', 
      type: 'color', 
      label: 'Color 1 (Deep)',
      folder: 'Colors'
    },
    uColor2: { 
      value: '#e94560', 
      type: 'color', 
      label: 'Color 2 (Mid)',
      folder: 'Colors'
    },
    uColor3: { 
      value: '#f8f0e3', 
      type: 'color', 
      label: 'Color 3 (Bright)',
      folder: 'Colors'
    },
    uSaturation: { 
      value: 1.0, 
      min: 0.0, 
      max: 1.5, 
      step: 0.05, 
      type: 'float', 
      label: 'Saturation',
      folder: 'Colors'
    },
    uInteriorStyle: { 
      value: false, 
      type: 'bool', 
      label: 'Color Interior',
      folder: 'Colors'
    },
  },
}
