import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const gravitationalLensingConfig: ShaderConfig = {
  name: 'Gravitational Lensing',
  description: 'Black hole with spacetime-bending distortion, photon sphere, and glowing accretion disc. Interstellar vibes.',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    
    // Black Hole
    uMass: { value: 1.0, min: 0.1, max: 5.0, step: 0.1, type: 'float', label: 'Mass' },
    uEventHorizonColor: { value: '#000000', type: 'color', label: 'Event Horizon' },
    
    // Lensing
    uLensStrength: { value: 1.0, min: 0.0, max: 3.0, step: 0.1, type: 'float', label: 'Lens Strength' },
    uPhotonSphereGlow: { value: 0.8, min: 0.0, max: 1.0, step: 0.05, type: 'float', label: 'Photon Sphere Glow' },
    uGlowColor: { value: '#ff6600', type: 'color', label: 'Glow Color' },
    
    // Accretion Disc
    uShowAccretionDisc: { value: 1.0, min: 0.0, max: 1.0, step: 1.0, type: 'float', label: 'Show Accretion Disc' },
    uDiscInnerRadius: { value: 3.0, min: 1.5, max: 5.0, step: 0.1, type: 'float', label: 'Disc Inner Radius' },
    uDiscOuterRadius: { value: 8.0, min: 5.0, max: 15.0, step: 0.5, type: 'float', label: 'Disc Outer Radius' },
    uDiscSpeed: { value: 1.0, min: 0.1, max: 3.0, step: 0.1, type: 'float', label: 'Disc Speed' },
    uDiscColorHot: { value: '#ffcc00', type: 'color', label: 'Disc Inner (Hot)' },
    uDiscColorCool: { value: '#ff3300', type: 'color', label: 'Disc Outer (Cool)' },
    uDopplerShift: { value: 0.5, min: 0.0, max: 1.0, step: 0.05, type: 'float', label: 'Doppler Shift' },
    
    // Background
    uStarfieldDensity: { value: 0.3, min: 0.0, max: 1.0, step: 0.05, type: 'float', label: 'Star Density' },
    uStarfieldSpeed: { value: 0.02, min: 0.0, max: 0.1, step: 0.01, type: 'float', label: 'Star Drift' },
    
    // Camera
    uViewAngle: { value: 30.0, min: 0.0, max: 90.0, step: 5.0, type: 'float', label: 'View Angle (°)' },
    uOrbitSpeed: { value: 0.1, min: 0.0, max: 0.5, step: 0.01, type: 'float', label: 'Orbit Speed' },
  },
}
