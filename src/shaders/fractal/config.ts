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
    uFractalType: { value: 0, min: 0, max: 2, step: 1, type: 'float', label: 'Type (0=Mandelbrot, 1=Julia, 2=Burning Ship)' },
    uZoom: { value: 1.0, min: 0.1, max: 50.0, step: 0.1, type: 'float', label: 'Zoom' },
    uCenterX: { value: -0.5, min: -2, max: 2, step: 0.01, type: 'float', label: 'Center X' },
    uCenterY: { value: 0.0, min: -2, max: 2, step: 0.01, type: 'float', label: 'Center Y' },
    uIterations: { value: 100, min: 10, max: 500, step: 10, type: 'float', label: 'Iterations' },
    uColorPalette: { value: 0, min: 0, max: 3, step: 1, type: 'float', label: 'Palette (0=Classic, 1=Fire, 2=Ocean, 3=Neon)' },
    uColor1: { value: '#0a0a2e', type: 'color', label: 'Color 1 (Deep)' },
    uColor2: { value: '#e94560', type: 'color', label: 'Color 2 (Mid)' },
    uColor3: { value: '#f8f0e3', type: 'color', label: 'Color 3 (Bright)' },
  },
}
