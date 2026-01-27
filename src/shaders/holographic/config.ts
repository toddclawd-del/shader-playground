import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const holographicConfig: ShaderConfig = {
  name: 'Holographic',
  description: 'Iridescent rainbow shifting based on view angle and position',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    
    // Fresnel (view-angle effect)
    uFresnelPower: { value: 2.0, min: 0.5, max: 5, step: 0.1, type: 'float', label: 'Fresnel Power' },
    uFresnelIntensity: { value: 1.0, min: 0, max: 2, step: 0.1, type: 'float', label: 'Fresnel Intensity' },
    
    // Rainbow controls
    uRainbowSpeed: { value: 0.5, min: 0, max: 3, step: 0.1, type: 'float', label: 'Rainbow Speed' },
    uRainbowScale: { value: 1.0, min: 0.1, max: 5, step: 0.1, type: 'float', label: 'Rainbow Scale' },
    uRainbowSpread: { value: 0.33, min: 0.1, max: 0.5, step: 0.01, type: 'float', label: 'Rainbow Spread' },
    
    // Color adjustments
    uSaturation: { value: 0.8, min: 0, max: 1, step: 0.05, type: 'float', label: 'Saturation' },
    uBrightness: { value: 0.9, min: 0, max: 1, step: 0.05, type: 'float', label: 'Brightness' },
    uShiftAmount: { value: 1.0, min: 0, max: 3, step: 0.1, type: 'float', label: 'View Shift' },
    
    // Noise/variation
    uNoiseAmount: { value: 0.3, min: 0, max: 1, step: 0.05, type: 'float', label: 'Noise Amount' },
    uNoiseScale: { value: 5, min: 1, max: 20, step: 1, type: 'float', label: 'Noise Scale' },
    
    // Animation
    uPulseSpeed: { value: 2, min: 0, max: 10, step: 0.5, type: 'float', label: 'Pulse Speed' },
    uPulseAmount: { value: 0.5, min: 0, max: 2, step: 0.1, type: 'float', label: 'Pulse Amount' },
    
    // Scanlines (retro effect)
    uScanlines: { value: 0, min: 0, max: 1, step: 0.05, type: 'float', label: 'Scanlines' },
    uScanlineSpeed: { value: 1, min: 0, max: 5, step: 0.1, type: 'float', label: 'Scanline Speed' },
    
    // Base color mix
    uBaseColor: { value: '#ffffff', type: 'color', label: 'Base Color' },
    uBaseColorMix: { value: 0, min: 0, max: 1, step: 0.05, type: 'float', label: 'Base Color Mix' },
    
    // Interactivity
    uMouseReactive: { value: 0.5, min: 0, max: 2, step: 0.1, type: 'float', label: 'Mouse Reactive' },
  },
}
