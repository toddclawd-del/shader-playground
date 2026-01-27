import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const glassConfig: ShaderConfig = {
  name: 'Glass',
  description: 'Frosted glass with refraction, blur, and chromatic aberration',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    
    // Core glass properties
    uBlur: { value: 2.0, min: 0, max: 10, step: 0.1, type: 'float', label: 'Blur' },
    uRefraction: { value: 0.5, min: 0, max: 2, step: 0.05, type: 'float', label: 'Refraction' },
    uChromaticAberration: { value: 1.0, min: 0, max: 5, step: 0.1, type: 'float', label: 'Chromatic Aberr' },
    
    // Frost effect
    uFrost: { value: 0.3, min: 0, max: 1, step: 0.05, type: 'float', label: 'Frost' },
    uFrostScale: { value: 10, min: 1, max: 50, step: 1, type: 'float', label: 'Frost Scale' },
    
    // Animation
    uDistortSpeed: { value: 1, min: 0, max: 5, step: 0.1, type: 'float', label: 'Distort Speed' },
    
    // Reflection
    uReflection: { value: 0.3, min: 0, max: 1, step: 0.05, type: 'float', label: 'Reflection' },
    
    // Edge glow
    uEdgeGlow: { value: 0.2, min: 0, max: 1, step: 0.05, type: 'float', label: 'Edge Glow' },
    uEdgeColor: { value: '#4fc3f7', type: 'color', label: 'Edge Color' },
    
    // Color adjustments
    uColor1: { value: '#1a1a2e', type: 'color', label: 'BG Color 1' },
    uColor2: { value: '#2d3a4a', type: 'color', label: 'BG Color 2' },
    uTint: { value: '#ffffff', type: 'color', label: 'Tint' },
    uTintStrength: { value: 0, min: 0, max: 1, step: 0.05, type: 'float', label: 'Tint Strength' },
    uOpacity: { value: 0.9, min: 0, max: 1, step: 0.05, type: 'float', label: 'Opacity' },
  },
}
