import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const metaballsConfig: ShaderConfig = {
  name: 'Metaballs',
  description: 'Classic demoscene blobby effect — organic shapes that merge and split. Lava lamp vibes.',
  vertexShader,
  fragmentShader,
  uniforms: {
    // Time
    uTime: { value: 0, type: 'float' },
    
    // Blob configuration
    uBlobCount: { value: 6, min: 2, max: 12, step: 1, type: 'float', label: 'Blob Count' },
    uBlobSize: { value: 0.12, min: 0.03, max: 0.3, step: 0.005, type: 'float', label: 'Blob Size' },
    uThreshold: { value: 1.0, min: 0.3, max: 3.0, step: 0.05, type: 'float', label: 'Threshold (Surface)' },
    
    // Animation
    uSpeed: { value: 0.5, min: 0.0, max: 2.0, step: 0.05, type: 'float', label: 'Speed' },
    uOrganic: { value: 0.5, min: 0.0, max: 1.0, step: 0.05, type: 'float', label: 'Organic Wobble' },
    uPulse: { value: 0.3, min: 0.0, max: 1.0, step: 0.05, type: 'float', label: 'Pulse' },
    
    // Blending
    uSmooth: { value: 0.0, min: 0.0, max: 1.0, step: 0.05, type: 'float', label: 'Smooth Blend' },
    
    // Visual effects
    uGlow: { value: 0.5, min: 0.0, max: 2.0, step: 0.05, type: 'float', label: 'Glow' },
    uBorderWidth: { value: 0.3, min: 0.0, max: 1.0, step: 0.05, type: 'float', label: 'Border Width' },
    uBorderGlow: { value: 0.8, min: 0.0, max: 1.5, step: 0.05, type: 'float', label: 'Border Intensity' },
    
    // Colors
    uColorMode: { value: 1, min: 0, max: 5, step: 1, type: 'int', label: 'Palette (0=Custom, 1=Lava, 2=Plasma, 3=Ocean, 4=Neon, 5=Mono)' },
    uColor1: { value: '#ff3366', type: 'color', label: 'Custom Color 1' },
    uColor2: { value: '#33ffcc', type: 'color', label: 'Custom Color 2' },
    uColor3: { value: '#ffcc33', type: 'color', label: 'Custom Color 3' },
    uBackgroundColor: { value: '#0a0a0f', type: 'color', label: 'Background' },
  },
}
