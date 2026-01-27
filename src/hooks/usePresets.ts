import { useCallback } from 'react'
import { useShaderStore } from '../stores/shaderStore'
import { shaderRegistry } from '../shaders'

export interface Preset {
  id: string
  name: string
  shaderId: string
  uniformValues: Record<string, any>
  createdAt: number
}

const STORAGE_KEY = 'shader-playground-presets'

// Load presets from localStorage
export function loadPresetsFromStorage(): Record<string, Preset[]> {
  try {
    const stored = localStorage.getItem(STORAGE_KEY)
    return stored ? JSON.parse(stored) : {}
  } catch {
    return {}
  }
}

// Save presets to localStorage
export function savePresetsToStorage(presets: Record<string, Preset[]>) {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(presets))
  } catch (error) {
    console.error('Failed to save presets:', error)
  }
}

export function usePresets() {
  const {
    currentShaderId,
    uniformValues,
    presets,
    addPreset,
    deletePreset,
    loadPreset,
  } = useShaderStore()

  const config = shaderRegistry[currentShaderId]

  // Save current settings as a preset
  const savePreset = useCallback((name: string) => {
    if (!currentShaderId || !name.trim()) return

    const preset: Preset = {
      id: `${currentShaderId}-${Date.now()}`,
      name: name.trim(),
      shaderId: currentShaderId,
      uniformValues: { ...uniformValues },
      createdAt: Date.now(),
    }

    addPreset(currentShaderId, preset)
    return preset
  }, [currentShaderId, uniformValues, addPreset])

  // Delete a preset
  const removePreset = useCallback((presetId: string) => {
    if (!currentShaderId) return
    deletePreset(currentShaderId, presetId)
  }, [currentShaderId, deletePreset])

  // Apply a preset
  const applyPreset = useCallback((presetId: string) => {
    if (!currentShaderId) return
    loadPreset(currentShaderId, presetId)
  }, [currentShaderId, loadPreset])

  // Get presets for current shader
  const currentPresets = presets[currentShaderId] || []

  // Export current settings as JSON
  const exportSettings = useCallback(() => {
    if (!config || !currentShaderId) return null

    return JSON.stringify({
      shaderId: currentShaderId,
      shaderName: config.name,
      uniformValues: uniformValues,
      exportedAt: new Date().toISOString(),
    }, null, 2)
  }, [currentShaderId, config, uniformValues])

  // Import settings from JSON
  const importSettings = useCallback((jsonString: string) => {
    try {
      const data = JSON.parse(jsonString)
      if (data.uniformValues && typeof data.uniformValues === 'object') {
        Object.entries(data.uniformValues).forEach(([key, value]) => {
          useShaderStore.getState().setUniformValue(key, value)
        })
        return true
      }
    } catch (error) {
      console.error('Failed to import settings:', error)
    }
    return false
  }, [])

  // Copy GLSL shader code to clipboard
  const copyShaderCode = useCallback(async () => {
    if (!config) return false

    // Generate uniform declarations with current values
    const uniformDeclarations = Object.entries(config.uniforms)
      .map(([key, uniform]) => {
        const value = uniformValues[key] ?? uniform.value
        let glslType = 'float'
        let defaultComment = `${value}`

        if (uniform.type === 'color') {
          glslType = 'vec3'
          defaultComment = `hex: ${value}`
        } else if (uniform.type === 'vec2') {
          glslType = 'vec2'
        } else if (uniform.type === 'vec3') {
          glslType = 'vec3'
        } else if (uniform.type === 'texture') {
          glslType = 'sampler2D'
          defaultComment = 'texture'
        }

        return `uniform ${glslType} ${key}; // ${uniform.label || key} (default: ${defaultComment})`
      })
      .join('\n')

    const fullShader = `// ${config.name}
// ${config.description || 'Shader Playground Export'}
// Exported from Shader Playground

// ============================================
// Uniforms
// ============================================
${uniformDeclarations}

// ============================================
// Fragment Shader
// ============================================
${config.fragmentShader}`

    try {
      await navigator.clipboard.writeText(fullShader)
      return true
    } catch {
      console.error('Failed to copy to clipboard')
      return false
    }
  }, [config, uniformValues])

  // Download shader as .glsl file
  const downloadShader = useCallback(() => {
    if (!config) return

    const blob = new Blob([config.fragmentShader], { type: 'text/plain' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `${currentShaderId}-shader.glsl`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
  }, [config, currentShaderId])

  // Download current config as JSON
  const downloadConfig = useCallback(() => {
    const json = exportSettings()
    if (!json) return

    const blob = new Blob([json], { type: 'application/json' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `${currentShaderId}-config.json`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
  }, [exportSettings, currentShaderId])

  return {
    presets: currentPresets,
    savePreset,
    removePreset,
    applyPreset,
    exportSettings,
    importSettings,
    copyShaderCode,
    downloadShader,
    downloadConfig,
  }
}
