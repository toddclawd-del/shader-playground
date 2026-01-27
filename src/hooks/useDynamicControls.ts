import { useEffect, useRef } from 'react'
import { useControls, button, folder } from 'leva'
import * as THREE from 'three'
import { useShaderStore } from '../stores/shaderStore'
import { shaderRegistry, shaderList } from '../shaders'

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
    
    return controls
  }
  
  // Shader-specific controls - key forces rebuild on shader change
  const [, setShaderControls] = useControls(
    config?.name || 'Shader',
    buildShaderControls,
    { collapsed: false },
    [currentShaderId]
  )
}
