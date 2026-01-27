import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const auroraConfig: ShaderConfig = {
  name: 'Aurora',
  description: 'Flowing aurora borealis with layered colors',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    uLayers: { value: 3, min: 1, max: 5, step: 1, type: 'float', label: 'Layers' },
    uFlowSpeed: { value: 0.5, min: 0, max: 2, step: 0.1, type: 'float', label: 'Flow Speed' },
    uDistortion: { value: 1, min: 0, max: 3, step: 0.1, type: 'float', label: 'Distortion' },
    uIntensity: { value: 1, min: 0.2, max: 2, step: 0.1, type: 'float', label: 'Intensity' },
    uVerticalStretch: { value: 1, min: 0.5, max: 3, step: 0.1, type: 'float', label: 'Vertical Stretch' },
    uColor1: { value: '#00ff88', type: 'color', label: 'Color 1' },
    uColor2: { value: '#00ddff', type: 'color', label: 'Color 2' },
    uColor3: { value: '#ff00ff', type: 'color', label: 'Color 3' },
    uBackgroundColor: { value: '#050510', type: 'color', label: 'Background' },
  },
}
