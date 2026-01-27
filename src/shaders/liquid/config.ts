import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const liquidConfig: ShaderConfig = {
  name: 'Liquid Metaballs',
  description: 'Interactive metaballs that follow the cursor',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    uBlobCount: { value: 5, min: 1, max: 8, step: 1, type: 'float', label: 'Blob Count' },
    uBlobSize: { value: 0.12, min: 0.03, max: 0.25, step: 0.01, type: 'float', label: 'Blob Size' },
    uSmoothness: { value: 0.25, min: 0.05, max: 0.5, step: 0.01, type: 'float', label: 'Smoothness' },
    uMouseInfluence: { value: 0.7, min: 0, max: 1, step: 0.1, type: 'float', label: 'Mouse Influence' },
    uColor1: { value: '#00d4ff', type: 'color', label: 'Color 1' },
    uColor2: { value: '#7b2dff', type: 'color', label: 'Color 2' },
    uAnimSpeed: { value: 1.0, min: 0, max: 3, step: 0.1, type: 'float', label: 'Animation Speed' },
    uDistortion: { value: 0.5, min: 0, max: 2, step: 0.1, type: 'float', label: 'Distortion' },
    uMetallic: { value: 0.5, min: 0, max: 1, step: 0.1, type: 'float', label: 'Metallic' },
  },
}
