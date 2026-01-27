import { useMemo } from 'react'
import { useControls, button } from 'leva'
import * as THREE from 'three'
import { useShaderStore } from '../stores/shaderStore'
import { shaderRegistry, shaderList } from '../shaders'

export function useDynamicControls() {
  const {
    currentShaderId,
    setCurrentShader,
    geometryType,
    setGeometryType,
    uniformValues,
    setUniformValue,
    setTexture,
    resetUniforms,
  } = useShaderStore()
  
  const config = shaderRegistry[currentShaderId]
  
  // Main controls (shader selector, geometry)
  useControls('Scene', {
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
  }, [currentShaderId, geometryType])
  
  // Build shader-specific controls
  const shaderControls = useMemo(() => {
    if (!config) return {}
    
    const controls: Record<string, any> = {}
    
    Object.entries(config.uniforms).forEach(([key, uniform]) => {
      // Skip uTime - it's auto-animated
      if (key === 'uTime') return
      
      const label = uniform.label || key.replace('u', '')
      
      if (uniform.type === 'color') {
        controls[label] = {
          value: uniformValues[key] || uniform.value,
          onChange: (value: string) => setUniformValue(key, value),
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
                setUniformValue(key, texture)
              })
            } else {
              setTexture(key, null)
              setUniformValue(key, null)
            }
          },
        }
      } else if (uniform.type === 'bool' || (uniform.min === 0 && uniform.max === 1 && uniform.step === 1)) {
        controls[label] = {
          value: Boolean(uniformValues[key] ?? uniform.value),
          onChange: (value: boolean) => setUniformValue(key, value ? 1 : 0),
        }
      } else if (uniform.type === 'vec2') {
        controls[label] = {
          value: uniformValues[key] || uniform.value,
          onChange: (value: number[]) => setUniformValue(key, value),
        }
      } else {
        // Float/number
        controls[label] = {
          value: uniformValues[key] ?? uniform.value,
          min: uniform.min,
          max: uniform.max,
          step: uniform.step,
          onChange: (value: number) => setUniformValue(key, value),
        }
      }
    })
    
    // Add reset button
    controls['Reset'] = button(() => {
      if (config) resetUniforms(config)
    })
    
    return controls
  }, [config, uniformValues, currentShaderId, setUniformValue, setTexture, resetUniforms])
  
  // Shader-specific controls panel
  useControls(
    config?.name || 'Shader',
    shaderControls,
    { collapsed: false },
    [config, shaderControls, currentShaderId]
  )
}
