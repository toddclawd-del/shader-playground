import fragmentShader from './fragment.glsl'
import vertexShader from './vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const oceanConfig: ShaderConfig = {
  name: 'Ocean',
  description:
    'Physics-based Gerstner waves — the same technique used in AAA games. Four layered waves with realistic foam, subsurface scattering, and specular highlights. Works best on a plane.',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    uSpeed: {
      value: 1.0,
      min: 0,
      max: 3,
      step: 0.1,
      type: 'float',
      label: 'Speed',
    },

    // === Wave 1: Primary swell ===
    uWave1Amp: {
      value: 0.15,
      min: 0,
      max: 0.5,
      step: 0.01,
      type: 'float',
      label: 'Wave 1 Height',
    },
    uWave1Freq: {
      value: 2.0,
      min: 0.5,
      max: 8,
      step: 0.1,
      type: 'float',
      label: 'Wave 1 Frequency',
    },
    uWave1Steep: {
      value: 0.5,
      min: 0,
      max: 1,
      step: 0.05,
      type: 'float',
      label: 'Wave 1 Steepness',
    },
    uWave1Dir: {
      value: [1.0, 0.0],
      type: 'vec2',
      label: 'Wave 1 Direction',
    },

    // === Wave 2: Secondary swell ===
    uWave2Amp: {
      value: 0.1,
      min: 0,
      max: 0.5,
      step: 0.01,
      type: 'float',
      label: 'Wave 2 Height',
    },
    uWave2Freq: {
      value: 3.0,
      min: 0.5,
      max: 10,
      step: 0.1,
      type: 'float',
      label: 'Wave 2 Frequency',
    },
    uWave2Steep: {
      value: 0.4,
      min: 0,
      max: 1,
      step: 0.05,
      type: 'float',
      label: 'Wave 2 Steepness',
    },
    uWave2Dir: {
      value: [0.7, 0.7],
      type: 'vec2',
      label: 'Wave 2 Direction',
    },

    // === Wave 3: Chop ===
    uWave3Amp: {
      value: 0.05,
      min: 0,
      max: 0.3,
      step: 0.01,
      type: 'float',
      label: 'Wave 3 Height',
    },
    uWave3Freq: {
      value: 5.0,
      min: 1,
      max: 15,
      step: 0.5,
      type: 'float',
      label: 'Wave 3 Frequency',
    },
    uWave3Steep: {
      value: 0.3,
      min: 0,
      max: 1,
      step: 0.05,
      type: 'float',
      label: 'Wave 3 Steepness',
    },
    uWave3Dir: {
      value: [-0.5, 0.8],
      type: 'vec2',
      label: 'Wave 3 Direction',
    },

    // === Wave 4: Detail ripples ===
    uWave4Amp: {
      value: 0.03,
      min: 0,
      max: 0.2,
      step: 0.005,
      type: 'float',
      label: 'Wave 4 Height',
    },
    uWave4Freq: {
      value: 8.0,
      min: 2,
      max: 20,
      step: 0.5,
      type: 'float',
      label: 'Wave 4 Frequency',
    },
    uWave4Steep: {
      value: 0.2,
      min: 0,
      max: 1,
      step: 0.05,
      type: 'float',
      label: 'Wave 4 Steepness',
    },
    uWave4Dir: {
      value: [0.3, -0.9],
      type: 'vec2',
      label: 'Wave 4 Direction',
    },

    // === Water Colors ===
    uDeepColor: {
      value: '#003366',
      type: 'color',
      label: 'Deep Water',
    },
    uShallowColor: {
      value: '#0077be',
      type: 'color',
      label: 'Shallow Water',
    },
    uFoamColor: {
      value: '#ffffff',
      type: 'color',
      label: 'Foam',
    },
    uSpecularColor: {
      value: '#ffffee',
      type: 'color',
      label: 'Specular',
    },

    // === Foam ===
    uFoamThreshold: {
      value: 0.5,
      min: 0,
      max: 1,
      step: 0.05,
      type: 'float',
      label: 'Foam Threshold',
    },
    uFoamIntensity: {
      value: 1.0,
      min: 0,
      max: 2,
      step: 0.1,
      type: 'float',
      label: 'Foam Intensity',
    },
    uFoamDetail: {
      value: 8.0,
      min: 1,
      max: 20,
      step: 1,
      type: 'float',
      label: 'Foam Detail',
    },

    // === Lighting ===
    uLightDir: {
      value: [0.5, 0.7, 0.3],
      type: 'vec3',
      label: 'Light Direction',
    },
    uFresnelPower: {
      value: 2.0,
      min: 0.5,
      max: 5,
      step: 0.1,
      type: 'float',
      label: 'Fresnel Power',
    },
    uSpecularPower: {
      value: 32.0,
      min: 4,
      max: 128,
      step: 4,
      type: 'float',
      label: 'Specular Sharpness',
    },
    uSpecularIntensity: {
      value: 0.8,
      min: 0,
      max: 2,
      step: 0.1,
      type: 'float',
      label: 'Specular Intensity',
    },

    // === Subsurface Scattering ===
    uSubsurfaceIntensity: {
      value: 0.4,
      min: 0,
      max: 1,
      step: 0.05,
      type: 'float',
      label: 'Subsurface',
    },
    uSubsurfaceColor: {
      value: '#00ffaa',
      type: 'color',
      label: 'Subsurface Color',
    },
  },
}
