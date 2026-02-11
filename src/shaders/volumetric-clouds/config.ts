import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const volumetricCloudsConfig: ShaderConfig = {
  name: 'Volumetric Clouds',
  description: 'True volumetric raymarching with FBM noise and light scattering. Endless morphing cloud formations with golden-hour glow.',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    
    // Density & Shape
    uCloudDensity: { value: 0.5, min: 0.1, max: 2.0, step: 0.01, type: 'float', label: 'Cloud Density' },
    uCloudCoverage: { value: 0.55, min: 0.0, max: 1.0, step: 0.01, type: 'float', label: 'Cloud Coverage' },
    uCloudHeight: { value: 1.5, min: 0.5, max: 4.0, step: 0.1, type: 'float', label: 'Cloud Height' },
    
    // Motion
    uWindSpeed: { value: 0.3, min: 0.0, max: 1.0, step: 0.01, type: 'float', label: 'Wind Speed' },
    uTurbulence: { value: 0.5, min: 0.0, max: 1.0, step: 0.01, type: 'float', label: 'Turbulence' },
    
    // Lighting
    uSunDirection: { value: [0.5, 0.3, 0.8], type: 'vec3', label: 'Sun Direction' },
    uSunColor: { value: '#FFE4B5', type: 'color', label: 'Sun Color' },
    uAmbientColor: { value: '#87CEEB', type: 'color', label: 'Ambient Color' },
    uScatterStrength: { value: 0.6, min: 0.0, max: 1.0, step: 0.01, type: 'float', label: 'Scatter Strength' },
    
    // Quality
    uRaySteps: { value: 64, min: 16, max: 128, step: 8, type: 'float', label: 'Ray Steps' },
    uNoiseOctaves: { value: 5, min: 2, max: 8, step: 1, type: 'float', label: 'Noise Octaves' },
  },
}
