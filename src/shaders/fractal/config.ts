import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const fractalConfig: ShaderConfig = {
  name: 'Fractal Explorer',
  description: 'Explore Mandelbrot, Julia, and Burning Ship fractals with zoom and custom colors',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    uFractalType: { value: 1, min: 0, max: 2, step: 1, type: 'float', label: 'Fractal Type' },
    uZoom: { value: 1.5, min: 0.1, max: 50.0, step: 0.1, type: 'float', label: 'Zoom Level' },
    uCenterX: { value: -0.5, min: -2, max: 2, step: 0.01, type: 'float', label: 'Pan X' },
    uCenterY: { value: 0.0, min: -2, max: 2, step: 0.01, type: 'float', label: 'Pan Y' },
    uIterations: { value: 150, min: 10, max: 256, step: 10, type: 'float', label: 'Detail Level' },
    uColorPalette: { value: 1, min: 0, max: 3, step: 1, type: 'float', label: 'Color Palette' },
    uColor1: { value: '#020617', type: 'color', label: 'Deep' },
    uColor2: { value: '#ea580c', type: 'color', label: 'Midtone' },
    uColor3: { value: '#fef9c3', type: 'color', label: 'Bright' },
  },
}
