import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const plasmaConfig: ShaderConfig = {
  name: 'Plasma',
  description: 'Classic demoscene plasma effect using sine wave composition. A tribute to the 80s/90s demo scene.',
  vertexShader,
  fragmentShader,
  uniforms: {
    // Core
    uTime: { value: 0, type: 'float' },
    uScale: { value: 4.0, min: 0.5, max: 20.0, step: 0.1, type: 'float', label: 'Scale' },
    uSpeed: { value: 1.0, min: 0.0, max: 3.0, step: 0.05, type: 'float', label: 'Speed' },
    
    // Pattern
    uPatternStyle: { value: 1, min: 0, max: 4, step: 1, type: 'float', label: 'Pattern Style (0-4)' },
    uWaveFrequency1: { value: 8.0, min: 1.0, max: 30.0, step: 0.5, type: 'float', label: 'Wave Freq 1' },
    uWaveFrequency2: { value: 6.0, min: 1.0, max: 30.0, step: 0.5, type: 'float', label: 'Wave Freq 2' },
    uWaveFrequency3: { value: 4.0, min: 1.0, max: 30.0, step: 0.5, type: 'float', label: 'Wave Freq 3' },
    uWaveFrequency4: { value: 5.0, min: 1.0, max: 30.0, step: 0.5, type: 'float', label: 'Wave Freq 4' },
    uDistortionAmount: { value: 0.1, min: 0.0, max: 0.5, step: 0.01, type: 'float', label: 'Distortion' },
    
    // Wave Centers
    uCenter1: { value: [0.3, 0.3], type: 'vec2', label: 'Center 1' },
    uCenter2: { value: [0.7, 0.7], type: 'vec2', label: 'Center 2' },
    
    // Color
    uColorStyle: { value: 0, min: 0, max: 7, step: 1, type: 'float', label: 'Color Style (0-7)' },
    uColorCycles: { value: 2.0, min: 0.5, max: 8.0, step: 0.1, type: 'float', label: 'Color Cycles' },
    uColorSpeed: { value: 0.1, min: 0.0, max: 1.0, step: 0.01, type: 'float', label: 'Color Speed' },
    uSaturation: { value: 1.0, min: 0.0, max: 1.5, step: 0.05, type: 'float', label: 'Saturation' },
    uBrightness: { value: 1.0, min: 0.5, max: 1.5, step: 0.05, type: 'float', label: 'Brightness' },
    
    // Custom Colors (for style 6)
    uColor1: { value: '#ff0066', type: 'color', label: 'Color 1' },
    uColor2: { value: '#00ffcc', type: 'color', label: 'Color 2' },
    uColor3: { value: '#6600ff', type: 'color', label: 'Color 3' },
    
    // Custom Cosine Palette (for style 7)
    uPaletteOffset: { value: [0.5, 0.5, 0.5], type: 'vec3', label: 'Palette Offset' },
    uPaletteAmp: { value: [0.5, 0.5, 0.5], type: 'vec3', label: 'Palette Amp' },
    uPaletteFreq: { value: [1.0, 1.0, 1.0], type: 'vec3', label: 'Palette Freq' },
    uPalettePhase: { value: [0.0, 0.1, 0.2], type: 'vec3', label: 'Palette Phase' },
    
    // Effects
    uPulseAmount: { value: 0.0, min: 0.0, max: 0.5, step: 0.01, type: 'float', label: 'Pulse' },
    uVignetteStrength: { value: 0.3, min: 0.0, max: 1.0, step: 0.05, type: 'float', label: 'Vignette' },
  },
}
