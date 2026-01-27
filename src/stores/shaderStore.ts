import { create } from 'zustand'
import * as THREE from 'three'

export type UniformConfig = {
  value: number | string | boolean | number[] | THREE.Texture | null
  min?: number
  max?: number
  step?: number
  type?: 'float' | 'color' | 'vec2' | 'vec3' | 'bool' | 'texture'
  label?: string
}

export type ShaderConfig = {
  name: string
  description?: string
  vertexShader: string
  fragmentShader: string
  uniforms: Record<string, UniformConfig>
}

export type GeometryType = 'plane' | 'sphere' | 'torus' | 'box'

interface ShaderState {
  // Current shader
  currentShaderId: string
  
  // Geometry
  geometryType: GeometryType
  
  // Live uniform values (separate from config defaults)
  uniformValues: Record<string, any>
  
  // Textures
  textures: Record<string, THREE.Texture | null>
  
  // Actions
  setCurrentShader: (id: string, config: ShaderConfig) => void
  setGeometryType: (type: GeometryType) => void
  setUniformValue: (name: string, value: any) => void
  setTexture: (name: string, texture: THREE.Texture | null) => void
  resetUniforms: (config: ShaderConfig) => void
}

export const useShaderStore = create<ShaderState>((set) => ({
  currentShaderId: '',
  geometryType: 'plane',
  uniformValues: {},
  textures: {},
  
  setCurrentShader: (id, config) => {
    // Reset uniform values to defaults when switching shaders
    const defaults: Record<string, any> = {}
    Object.entries(config.uniforms).forEach(([key, uniform]) => {
      defaults[key] = uniform.value
    })
    set({ currentShaderId: id, uniformValues: defaults })
  },
  
  setGeometryType: (type) => set({ geometryType: type }),
  
  setUniformValue: (name, value) => {
    set((state) => ({
      uniformValues: { ...state.uniformValues, [name]: value },
    }))
  },
  
  setTexture: (name, texture) => {
    set((state) => ({
      textures: { ...state.textures, [name]: texture },
    }))
  },
  
  resetUniforms: (config) => {
    const defaults: Record<string, any> = {}
    Object.entries(config.uniforms).forEach(([key, uniform]) => {
      defaults[key] = uniform.value
    })
    set({ uniformValues: defaults })
  },
}))
