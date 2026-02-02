import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const causticsConfig: ShaderConfig = {
  name: 'Caustics',
  description: 'Simulated underwater caustic light patterns created by waves refracting sunlight onto the pool floor. Based on Gerstner waves and Snell\'s law of refraction.',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    
    // Wave Controls
    uScale: { value: 3.0, min: 1.0, max: 10.0, step: 0.1, type: 'float', label: 'Scale' },
    uAnimSpeed: { value: 0.8, min: 0.1, max: 3.0, step: 0.1, type: 'float', label: 'Animation Speed' },
    uWaveCount: { value: 5.0, min: 1.0, max: 8.0, step: 1.0, type: 'float', label: 'Wave Layers' },
    uWaveAmplitude: { value: 0.15, min: 0.01, max: 0.5, step: 0.01, type: 'float', label: 'Wave Height' },
    uWaveSteepness: { value: 0.8, min: 0.0, max: 2.0, step: 0.1, type: 'float', label: 'Wave Steepness' },
    
    // Physics Controls
    uRefractiveIndex: { value: 1.33, min: 1.0, max: 2.0, step: 0.01, type: 'float', label: 'Refractive Index (n)' },
    uWaterDepth: { value: 1.5, min: 0.5, max: 5.0, step: 0.1, type: 'float', label: 'Water Depth' },
    
    // Caustic Appearance
    uCausticIntensity: { value: 2.0, min: 0.5, max: 5.0, step: 0.1, type: 'float', label: 'Intensity' },
    uCausticSharpness: { value: 1.5, min: 0.5, max: 5.0, step: 0.1, type: 'float', label: 'Sharpness' },
    
    // Visualization
    uVisualization: { value: 0.0, min: 0.0, max: 3.0, step: 1.0, type: 'float', label: 'Mode (0=Full, 1=Fast, 2=Waves, 3=Normals)' },
    uShowWaves: { value: 0.0, min: 0.0, max: 1.0, step: 0.1, type: 'float', label: 'Wave Overlay' },
    uColorMix: { value: 0.3, min: 0.0, max: 1.0, step: 0.05, type: 'float', label: 'Color Tinting' },
    
    // Colors
    uColor1: { value: '#00d4ff', type: 'color', label: 'Bright Color' },
    uColor2: { value: '#00ff88', type: 'color', label: 'Mid Color' },
    uColor3: { value: '#ffffff', type: 'color', label: 'Peak Color' },
    uBackgroundColor: { value: '#0a2a3f', type: 'color', label: 'Background' },
  },
}
