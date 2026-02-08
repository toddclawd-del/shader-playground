import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const hyperspaceTunnelConfig: ShaderConfig = {
  name: 'Hyperspace Tunnel',
  description: 'Infinite tunnel effect — fly through a procedurally textured cylinder. Trippy hyperspace vibes.',
  vertexShader,
  fragmentShader,
  uniforms: {
    // Core animation
    uTime: { value: 0, type: 'float' },
    uSpeed: { value: 0.8, min: 0.0, max: 3.0, step: 0.05, type: 'float', label: 'Speed' },
    uZoom: { value: 0.5, min: 0.1, max: 2.0, step: 0.05, type: 'float', label: 'Zoom (Depth)' },
    
    // Tunnel shape
    uTwist: { value: 1.0, min: -5.0, max: 5.0, step: 0.1, type: 'float', label: 'Twist' },
    uCenterOffset: { value: [0.0, 0.0], type: 'vec2', label: 'Center Offset' },
    uDistortion: { value: 0.3, min: 0.0, max: 2.0, step: 0.05, type: 'float', label: 'Distortion' },
    
    // Pattern controls
    uPatternStyle: { value: 0, min: 0, max: 5, step: 1, type: 'float', label: 'Pattern (0=Noise, 1=Grid, 2=Hex, 3=Rings, 4=Stripes, 5=Star)' },
    uPatternScale: { value: 2.0, min: 0.5, max: 10.0, step: 0.1, type: 'float', label: 'Pattern Scale' },
    uNoiseOctaves: { value: 4.0, min: 1.0, max: 6.0, step: 1.0, type: 'float', label: 'Noise Octaves' },
    
    // Color controls
    uColorStyle: { value: 1, min: 0, max: 4, step: 1, type: 'float', label: 'Palette (0=Neon, 1=Retro, 2=Matrix, 3=Fire, 4=Custom)' },
    uColor1: { value: '#ff00ff', type: 'color', label: 'Custom Color 1' },
    uColor2: { value: '#00ffff', type: 'color', label: 'Custom Color 2' },
    uColor3: { value: '#ffff00', type: 'color', label: 'Custom Color 3' },
    
    // Effects
    uGlowIntensity: { value: 0.3, min: 0.0, max: 1.5, step: 0.05, type: 'float', label: 'Glow' },
    uFogDensity: { value: 2.0, min: 0.0, max: 5.0, step: 0.1, type: 'float', label: 'Fog Density' },
    uPulseAmount: { value: 0.05, min: 0.0, max: 0.3, step: 0.01, type: 'float', label: 'Pulse' },
    uVignetteStrength: { value: 0.5, min: 0.0, max: 1.5, step: 0.05, type: 'float', label: 'Vignette' },
  },
}
