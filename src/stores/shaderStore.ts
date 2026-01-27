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

export interface MouseStateData {
  x: number
  y: number
  velocityX: number
  velocityY: number
  isDown: boolean
}

export interface Preset {
  id: string
  name: string
  shaderId: string
  uniformValues: Record<string, any>
  createdAt: number
}

const PRESETS_STORAGE_KEY = 'shader-playground-presets'

// Load presets from localStorage
function loadPresetsFromStorage(): Record<string, Preset[]> {
  try {
    const stored = localStorage.getItem(PRESETS_STORAGE_KEY)
    return stored ? JSON.parse(stored) : {}
  } catch {
    return {}
  }
}

// Save presets to localStorage
function savePresetsToStorage(presets: Record<string, Preset[]>) {
  try {
    localStorage.setItem(PRESETS_STORAGE_KEY, JSON.stringify(presets))
  } catch (error) {
    console.error('Failed to save presets:', error)
  }
}

interface ShaderState {
  // Current shader
  currentShaderId: string

  // Geometry
  geometryType: GeometryType

  // Live uniform values (separate from config defaults)
  uniformValues: Record<string, any>

  // Textures
  textures: Record<string, THREE.Texture | null>

  // Mouse state
  mouse: MouseStateData

  // Presets (keyed by shader ID)
  presets: Record<string, Preset[]>

  // Actions
  setCurrentShader: (id: string, config: ShaderConfig) => void
  setGeometryType: (type: GeometryType) => void
  setUniformValue: (name: string, value: any) => void
  setTexture: (name: string, texture: THREE.Texture | null) => void
  resetUniforms: (config: ShaderConfig) => void
  setMouseState: (state: MouseStateData) => void

  // Preset actions
  addPreset: (shaderId: string, preset: Preset) => void
  deletePreset: (shaderId: string, presetId: string) => void
  loadPreset: (shaderId: string, presetId: string) => void
}

export const useShaderStore = create<ShaderState>((set, get) => ({
  currentShaderId: '',
  geometryType: 'plane',
  uniformValues: {},
  textures: {},
  mouse: {
    x: 0.5,
    y: 0.5,
    velocityX: 0,
    velocityY: 0,
    isDown: false,
  },
  presets: loadPresetsFromStorage(),

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

  setMouseState: (mouseState) => set({ mouse: mouseState }),

  addPreset: (shaderId, preset) => {
    set((state) => {
      const shaderPresets = state.presets[shaderId] || []
      const newPresets = {
        ...state.presets,
        [shaderId]: [...shaderPresets, preset],
      }
      savePresetsToStorage(newPresets)
      return { presets: newPresets }
    })
  },

  deletePreset: (shaderId, presetId) => {
    set((state) => {
      const shaderPresets = state.presets[shaderId] || []
      const newPresets = {
        ...state.presets,
        [shaderId]: shaderPresets.filter((p) => p.id !== presetId),
      }
      savePresetsToStorage(newPresets)
      return { presets: newPresets }
    })
  },

  loadPreset: (shaderId, presetId) => {
    const state = get()
    const shaderPresets = state.presets[shaderId] || []
    const preset = shaderPresets.find((p) => p.id === presetId)
    if (preset) {
      set({ uniformValues: { ...preset.uniformValues } })
    }
  },
}))
