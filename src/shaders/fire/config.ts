import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const fireConfig: ShaderConfig = {
  name: 'Fire',
  description: 'Procedural flames using FBM + domain warping. Mesmerizing fire that flickers, dances, and breathes.',
  vertexShader,
  fragmentShader,
  uniforms: {
    // Core
    uTime: { value: 0, type: 'float' },
    
    // Flame behavior
    uFlameHeight: { value: 1.2, min: 0.3, max: 2.5, step: 0.1, type: 'float', label: 'Flame Height' },
    uFlameWidth: { value: 1.0, min: 0.2, max: 2.0, step: 0.1, type: 'float', label: 'Flame Width' },
    uSpeed: { value: 0.8, min: 0.1, max: 3.0, step: 0.1, type: 'float', label: 'Speed' },
    
    // Turbulence
    uTurbulence: { value: 0.6, min: 0.0, max: 1.0, step: 0.05, type: 'float', label: 'Turbulence' },
    uFlickerIntensity: { value: 0.3, min: 0.0, max: 1.0, step: 0.05, type: 'float', label: 'Flicker' },
    uOctaves: { value: 5, min: 2, max: 8, step: 1, type: 'float', label: 'Detail (Octaves)' },
    
    // Shape mode: 0=natural, 1=torch, 2=candle, 3=explosion, 4=wall
    uShapeMode: { value: 0, min: 0, max: 4, step: 1, type: 'float', label: 'Shape (0-4)' },
    
    // Color mode: 0=realistic, 1=neon, 2=infernal, 3=ice, 4=custom
    uColorMode: { value: 0, min: 0, max: 4, step: 1, type: 'float', label: 'Color Mode (0-4)' },
    
    // Custom colors (for mode 4)
    uCoreColor: { value: '#ff2200', type: 'color', label: 'Core Color' },
    uMidColor: { value: '#ff8800', type: 'color', label: 'Mid Color' },
    uTipColor: { value: '#ffff00', type: 'color', label: 'Tip Color' },
    uOuterGlow: { value: '#ff4400', type: 'color', label: 'Outer Glow' },
    
    // Effects
    uGlowIntensity: { value: 0.4, min: 0.0, max: 1.0, step: 0.05, type: 'float', label: 'Glow Intensity' },
    uHeatDistortion: { value: 0.3, min: 0.0, max: 1.0, step: 0.05, type: 'float', label: 'Heat Distortion' },
    uSparks: { value: 0.0, min: 0.0, max: 1.0, step: 0.1, type: 'float', label: 'Sparks' },
  },
}
