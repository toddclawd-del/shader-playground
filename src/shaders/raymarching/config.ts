import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const raymarchingConfig: ShaderConfig = {
  name: 'Ray Marching',
  description: '3D SDF scenes with sphere tracing',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    uShapeType: { value: 0, min: 0, max: 3, step: 1, type: 'float', label: 'Shape (0-3)' },
    uBooleanOp: { value: 0, min: 0, max: 2, step: 1, type: 'float', label: 'Boolean Op (0-2)' },
    uSmoothness: { value: 0.2, min: 0, max: 0.5, step: 0.01, type: 'float', label: 'Smoothness' },
    uMouseLook: { value: 1, min: 0, max: 1, step: 1, type: 'float', label: 'Mouse Look' },
    uAOStrength: { value: 1, min: 0, max: 2, step: 0.1, type: 'float', label: 'AO Strength' },
    uColor1: { value: '#ff6b6b', type: 'color', label: 'Color 1' },
    uColor2: { value: '#4ecdc4', type: 'color', label: 'Color 2' },
    uBackgroundColor: { value: '#1a1a2e', type: 'color', label: 'Background' },
    uAnimSpeed: { value: 1.0, min: 0, max: 3, step: 0.1, type: 'float', label: 'Animation Speed' },
  },
}
