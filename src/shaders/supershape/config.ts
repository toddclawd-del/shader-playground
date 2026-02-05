import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const supershapeConfig: ShaderConfig = {
  name: 'Supershape',
  description:
    "Johan Gielis' Superformula — one equation that generates circles, stars, flowers, polygons, and organic blobs. Morph between 8 preset shapes or dial in your own parameters.",
  vertexShader,
  fragmentShader,
  uniforms: {
    // Time (auto-animated)
    uTime: { value: 0, type: 'float' },

    // --- Superformula Parameters ---
    uM: {
      value: 5,
      min: 0,
      max: 20,
      step: 0.1,
      type: 'float',
      label: 'm (Symmetry)',
    },
    uN1: {
      value: 0.3,
      min: 0.01,
      max: 100,
      step: 0.1,
      type: 'float',
      label: 'n1 (Inflation)',
    },
    uN2: {
      value: 0.3,
      min: 0.01,
      max: 100,
      step: 0.1,
      type: 'float',
      label: 'n2 (Cos Exponent)',
    },
    uN3: {
      value: 0.3,
      min: 0.01,
      max: 100,
      step: 0.1,
      type: 'float',
      label: 'n3 (Sin Exponent)',
    },
    uA: {
      value: 1.0,
      min: 0.1,
      max: 3.0,
      step: 0.05,
      type: 'float',
      label: 'a (Cos Scale)',
    },
    uB: {
      value: 1.0,
      min: 0.1,
      max: 3.0,
      step: 0.05,
      type: 'float',
      label: 'b (Sin Scale)',
    },

    // --- Visualization ---
    uVisualization: {
      value: 0,
      min: 0,
      max: 4,
      step: 1,
      type: 'float',
      label: 'Mode (0=Neon 1=SDF 2=Fill 3=Morph 4=Layer)',
    },
    uScale: {
      value: 0.5,
      min: 0.1,
      max: 1.5,
      step: 0.05,
      type: 'float',
      label: 'Scale',
    },
    uLineWidth: {
      value: 0.012,
      min: 0.002,
      max: 0.06,
      step: 0.002,
      type: 'float',
      label: 'Line Width',
    },
    uGlow: {
      value: 1.0,
      min: 0,
      max: 2.0,
      step: 0.05,
      type: 'float',
      label: 'Glow',
    },

    // --- Animation ---
    uAnimSpeed: {
      value: 1.0,
      min: 0,
      max: 3.0,
      step: 0.1,
      type: 'float',
      label: 'Anim Speed',
    },
    uRotationSpeed: {
      value: 0.15,
      min: -1.0,
      max: 1.0,
      step: 0.05,
      type: 'float',
      label: 'Rotation Speed',
    },
    uAutoMorph: {
      value: false,
      type: 'bool',
      label: 'Auto Morph',
    },
    uMorphSpeed: {
      value: 1.0,
      min: 0.1,
      max: 3.0,
      step: 0.1,
      type: 'float',
      label: 'Morph Speed',
    },
    uBreathe: {
      value: 0.3,
      min: 0,
      max: 1.0,
      step: 0.05,
      type: 'float',
      label: 'Breathe',
    },

    // --- Colors ---
    uColor1: { value: '#00f2ff', type: 'color', label: 'Color 1 (Primary)' },
    uColor2: { value: '#ff00c8', type: 'color', label: 'Color 2 (Secondary)' },
    uColor3: { value: '#f7ff00', type: 'color', label: 'Color 3 (Accent)' },
    uBackgroundColor: {
      value: '#050510',
      type: 'color',
      label: 'Background',
    },

    // --- Layered mode ---
    uLayers: {
      value: 3,
      min: 1,
      max: 5,
      step: 1,
      type: 'float',
      label: 'Layer Count',
    },
    uLayerSpread: {
      value: 1.0,
      min: 0.2,
      max: 3.0,
      step: 0.1,
      type: 'float',
      label: 'Layer Spread',
    },
  },
}
