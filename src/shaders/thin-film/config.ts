import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const thinFilmConfig: ShaderConfig = {
  name: 'Thin-Film Interference',
  description: 'Iridescent colors from soap bubbles & oil slicks — real optical physics creating rainbow interference patterns',
  vertexShader,
  fragmentShader,
  uniforms: {
    // Core
    uTime: { value: 0, type: 'float' },
    
    // Film Thickness (in nanometers — visible light is 380-780nm)
    uThicknessMin: { value: 200, min: 50, max: 500, step: 10, type: 'float', label: 'Min Thickness (nm)' },
    uThicknessMax: { value: 600, min: 200, max: 1500, step: 10, type: 'float', label: 'Max Thickness (nm)' },
    uThicknessVariation: { value: 0.4, min: 0, max: 1, step: 0.01, type: 'float', label: 'Thickness Variation' },
    
    // Refractive Indices
    uN1: { value: 1.0, min: 1.0, max: 2.0, step: 0.01, type: 'float', label: 'N1 (Air/Outer)' },
    uN2: { value: 1.33, min: 1.0, max: 2.5, step: 0.01, type: 'float', label: 'N2 (Film)' },
    uN3: { value: 1.0, min: 1.0, max: 2.5, step: 0.01, type: 'float', label: 'N3 (Substrate)' },
    
    // Animation
    uAnimSpeed: { value: 0.5, min: 0, max: 3, step: 0.1, type: 'float', label: 'Animation Speed' },
    uSwirl: { value: 1.0, min: 0, max: 3, step: 0.1, type: 'float', label: 'Swirl Intensity' },
    uNoiseScale: { value: 3.0, min: 0.5, max: 10, step: 0.1, type: 'float', label: 'Noise Scale' },
    
    // Appearance
    uVisualization: { value: 0, min: 0, max: 2, step: 1, type: 'float', label: 'Mode (0=Bubble, 1=Oil, 2=Abstract)' },
    uColorIntensity: { value: 1.0, min: 0, max: 2, step: 0.05, type: 'float', label: 'Iridescence Intensity' },
    uFresnelStrength: { value: 2.0, min: 0.5, max: 5, step: 0.1, type: 'float', label: 'Edge Intensity (Fresnel)' },
    uBaseColor: { value: '#1a1a2e', type: 'color', label: 'Base Color' },
  },
}
