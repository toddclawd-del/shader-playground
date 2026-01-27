import { useEffect, useRef } from 'react'
import { useControls, button, folder } from 'leva'
import * as THREE from 'three'
import { useShaderStore } from '../stores/shaderStore'
import { shaderRegistry, shaderList } from '../shaders'
import { usePresets } from './usePresets'

export function useDynamicControls() {
  const {
    currentShaderId,
    setCurrentShader,
    geometryType,
    setGeometryType,
    setUniformValue,
    setTexture,
    resetUniforms,
  } = useShaderStore()

  const config = shaderRegistry[currentShaderId]

  const {
    presets,
    savePreset,
    removePreset,
    applyPreset,
    copyShaderCode,
    downloadShader,
    downloadConfig,
  } = usePresets()

  // Track if we're updating from Leva to prevent loops
  const isUpdatingRef = useRef(false)
  
  // Scene controls - these are stable
  const [, setScene] = useControls('Scene', () => ({
    shader: {
      value: currentShaderId || 'gradient',
      options: Object.fromEntries(shaderList.map((s) => [s.name, s.id])),
      onChange: (value: string) => {
        const newConfig = shaderRegistry[value]
        if (newConfig) {
          setCurrentShader(value, newConfig)
        }
      },
    },
    geometry: {
      value: geometryType,
      options: {
        Plane: 'plane',
        Sphere: 'sphere',
        Torus: 'torus',
        Box: 'box',
      },
      onChange: (value) => setGeometryType(value),
    },
  }), [])
  
  // Update scene controls when store changes
  useEffect(() => {
    setScene({ shader: currentShaderId, geometry: geometryType })
  }, [currentShaderId, geometryType, setScene])
  
  // Build shader controls config - only rebuild when shader changes
  const buildShaderControls = () => {
    if (!config) return { placeholder: { value: 'No shader loaded' } }
    
    const controls: Record<string, any> = {}
    
    Object.entries(config.uniforms).forEach(([key, uniform]) => {
      if (key === 'uTime') return // Skip auto-animated
      
      const label = uniform.label || key.replace('u', '')
      
      if (uniform.type === 'color') {
        controls[label] = {
          value: uniform.value as string,
          onChange: (value: string) => {
            if (!isUpdatingRef.current) {
              setUniformValue(key, value)
            }
          },
        }
      } else if (uniform.type === 'texture') {
        controls[label] = {
          image: undefined,
          onChange: (file: string | undefined) => {
            if (file) {
              const loader = new THREE.TextureLoader()
              loader.load(file, (texture) => {
                texture.needsUpdate = true
                setTexture(key, texture)
              })
            } else {
              setTexture(key, null)
            }
          },
        }
      } else if (uniform.type === 'bool' || (uniform.min === 0 && uniform.max === 1 && uniform.step === 1)) {
        controls[label] = {
          value: Boolean(uniform.value),
          onChange: (value: boolean) => {
            if (!isUpdatingRef.current) {
              setUniformValue(key, value ? 1 : 0)
            }
          },
        }
      } else {
        controls[label] = {
          value: uniform.value as number,
          min: uniform.min,
          max: uniform.max,
          step: uniform.step,
          onChange: (value: number) => {
            if (!isUpdatingRef.current) {
              setUniformValue(key, value)
            }
          },
        }
      }
    })
    
    controls['Reset'] = button(() => {
      if (config) {
        isUpdatingRef.current = true
        resetUniforms(config)
        // Reset Leva values
        const defaults: Record<string, any> = {}
        Object.entries(config.uniforms).forEach(([key, uniform]) => {
          if (key === 'uTime') return
          const label = uniform.label || key.replace('u', '')
          defaults[label] = uniform.type === 'bool' ? Boolean(uniform.value) : uniform.value
        })
        setShaderControls(defaults)
        setTimeout(() => { isUpdatingRef.current = false }, 0)
      }
    })

    // Presets folder
    const presetControls: Record<string, any> = {
      'Save Preset': button(() => {
        const name = prompt('Enter preset name:')
        if (name) {
          savePreset(name)
          console.log(`Saved preset: ${name}`)
        }
      }),
    }

    // Add buttons for each saved preset
    presets.forEach((preset, index) => {
      presetControls[`${index + 1}. ${preset.name}`] = button(() => {
        applyPreset(preset.id)
        // Update Leva controls with preset values
        isUpdatingRef.current = true
        const levaValues: Record<string, any> = {}
        Object.entries(preset.uniformValues).forEach(([key, value]) => {
          if (key === 'uTime') return
          const uniformConfig = config?.uniforms[key]
          const label = uniformConfig?.label || key.replace('u', '')
          levaValues[label] = uniformConfig?.type === 'bool' ? Boolean(value) : value
        })
        setShaderControls(levaValues)
        setTimeout(() => { isUpdatingRef.current = false }, 0)
        console.log(`Loaded preset: ${preset.name}`)
      })
    })

    if (presets.length > 0) {
      presetControls['Delete Last'] = button(() => {
        const lastPreset = presets[presets.length - 1]
        if (lastPreset && confirm(`Delete preset "${lastPreset.name}"?`)) {
          removePreset(lastPreset.id)
        }
      })
    }

    controls['Presets'] = folder(presetControls, { collapsed: true })

    // Export folder
    controls['Export'] = folder({
      'Copy GLSL': button(() => {
        copyShaderCode().then((success) => {
          if (success) {
            console.log('Shader code copied to clipboard!')
          }
        })
      }),
      'Download Shader': button(() => {
        downloadShader()
      }),
      'Download Config': button(() => {
        downloadConfig()
      }),
    }, { collapsed: true })

    return controls
  }

  // Count presets to trigger rebuild when they change
  const presetCount = presets.length

  // Shader-specific controls - key forces rebuild on shader change or preset change
  const [, setShaderControls] = useControls(
    config?.name || 'Shader',
    buildShaderControls,
    { collapsed: false },
    [currentShaderId, presetCount]
  )
}
