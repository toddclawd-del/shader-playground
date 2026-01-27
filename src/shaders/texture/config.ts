import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const textureConfig: ShaderConfig = {
  name: 'Texture FX',
  description: 'Image effects: distortion, glitch, RGB shift, scanlines',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    uTexture: { value: null, type: 'texture', label: 'Texture' },
    uZoom: { value: 1, min: 0.5, max: 3, step: 0.05, type: 'float', label: 'Zoom' },
    uRotation: { value: 0, min: 0, max: 6.28, step: 0.05, type: 'float', label: 'Rotation' },
    uRotationSpeed: { value: 0, min: 0, max: 2, step: 0.05, type: 'float', label: 'Rot Speed' },
    uMirrorX: { value: 0, min: 0, max: 1, step: 1, type: 'float', label: 'Mirror X' },
    uMirrorY: { value: 0, min: 0, max: 1, step: 1, type: 'float', label: 'Mirror Y' },
    uDistortion: { value: 0, min: 0, max: 2, step: 0.01, type: 'float', label: 'Distortion' },
    uDistortFreq: { value: 10, min: 1, max: 30, step: 1, type: 'float', label: 'Distort Freq' },
    uSpeed: { value: 1, min: 0, max: 5, step: 0.1, type: 'float', label: 'Speed' },
    uRgbShift: { value: 0, min: 0, max: 5, step: 0.1, type: 'float', label: 'RGB Shift' },
    uGlitch: { value: 0, min: 0, max: 3, step: 0.1, type: 'float', label: 'Glitch' },
    uScanlines: { value: 0, min: 0, max: 1, step: 0.05, type: 'float', label: 'Scanlines' },
    uScanlineSpeed: { value: 1, min: 0, max: 5, step: 0.1, type: 'float', label: 'Scan Speed' },
    uVignetteSize: { value: 0, min: 0, max: 2, step: 0.05, type: 'float', label: 'Vignette' },
    uVignetteSmooth: { value: 0.5, min: 0.1, max: 1, step: 0.05, type: 'float', label: 'Vig Smooth' },
    uTint: { value: '#ffffff', type: 'color', label: 'Tint Color' },
    uTintStrength: { value: 0, min: 0, max: 1, step: 0.01, type: 'float', label: 'Tint Strength' },
  },
}
