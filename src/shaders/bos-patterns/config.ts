import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const bosPatternsConfig: ShaderConfig = {
  name: 'BoS: Patterns',
  description: 'Tiled patterns with 6 shape types and animation',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    
    // Shape selection: 0=Cross, 1=Circle, 2=Diamond, 3=Star, 4=Triangle, 5=Hexagon
    uShapeType: { value: 0, min: 0, max: 5, step: 1, type: 'float', label: 'Shape (0-5)' },
    
    // Colors
    uColor1: { value: '#264653', type: 'color', label: 'Color 1' },
    uColor2: { value: '#e9c46a', type: 'color', label: 'Color 2' },
    
    // Grid
    uScale: { value: 5, min: 1, max: 20, step: 1, type: 'float', label: 'Grid Scale' },
    
    // Shape properties
    uShapeSize: { value: 0.5, min: 0.1, max: 0.95, step: 0.01, type: 'float', label: 'Shape Size' },
    uShapeRatio: { value: 0.25, min: 0.1, max: 1.0, step: 0.01, type: 'float', label: 'Shape Ratio' },
    uSoftness: { value: 0.01, min: 0.001, max: 0.1, step: 0.001, type: 'float', label: 'Edge Softness' },
    
    // Rotation
    uRotation: { value: 0, min: 0, max: 6.28, step: 0.01, type: 'float', label: 'Rotation' },
    uRotationSpeed: { value: 0, min: 0, max: 2, step: 0.05, type: 'float', label: 'Rot Speed' },
    
    // Row offset
    uOffset: { value: 0.5, min: 0, max: 1, step: 0.01, type: 'float', label: 'Row Offset' },
    uOffsetAnim: { value: 0, min: 0, max: 3, step: 0.1, type: 'float', label: 'Offset Anim' },
    
    // Pulse animation
    uPulseSpeed: { value: 2, min: 0.5, max: 5, step: 0.1, type: 'float', label: 'Pulse Speed' },
    uPulseAmp: { value: 0, min: 0, max: 3, step: 0.1, type: 'float', label: 'Pulse Amp' },
    
    // Morph animation
    uMorphSpeed: { value: 2, min: 0.5, max: 5, step: 0.1, type: 'float', label: 'Morph Speed' },
    uMorphAmp: { value: 0, min: 0, max: 3, step: 0.1, type: 'float', label: 'Morph Amp' },
  },
}
