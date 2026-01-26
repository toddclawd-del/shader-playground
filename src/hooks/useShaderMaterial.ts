import { useMemo, useRef, useEffect } from 'react'
import * as THREE from 'three'
import { useFrame } from '@react-three/fiber'
import { useShaderStore } from '../stores/shaderStore'
import { shaderRegistry } from '../shaders'

export function useShaderMaterial() {
  const materialRef = useRef<THREE.ShaderMaterial>(null)
  const { currentShaderId, uniformValues, textures } = useShaderStore()
  
  const config = shaderRegistry[currentShaderId]
  
  // Build initial uniforms object
  const uniforms = useMemo(() => {
    if (!config) return {}
    
    const result: Record<string, THREE.IUniform> = {}
    
    Object.entries(config.uniforms).forEach(([key, uniformConfig]) => {
      if (uniformConfig.type === 'color') {
        result[key] = { value: new THREE.Color(uniformConfig.value as string) }
      } else if (uniformConfig.type === 'texture') {
        result[key] = { value: textures[key] || null }
      } else {
        result[key] = { value: uniformConfig.value }
      }
    })
    
    return result
  }, [config, currentShaderId])
  
  // Update uniforms when values change
  useEffect(() => {
    if (!materialRef.current || !config) return
    
    Object.entries(uniformValues).forEach(([key, value]) => {
      if (materialRef.current!.uniforms[key]) {
        const uniformConfig = config.uniforms[key]
        
        if (uniformConfig?.type === 'color') {
          materialRef.current!.uniforms[key].value = new THREE.Color(value)
        } else {
          materialRef.current!.uniforms[key].value = value
        }
      }
    })
  }, [uniformValues, config])
  
  // Update textures
  useEffect(() => {
    if (!materialRef.current) return
    
    Object.entries(textures).forEach(([key, texture]) => {
      if (materialRef.current!.uniforms[key]) {
        materialRef.current!.uniforms[key].value = texture
      }
    })
  }, [textures])
  
  // Animate uTime
  useFrame((state) => {
    if (materialRef.current?.uniforms.uTime) {
      materialRef.current.uniforms.uTime.value = state.clock.elapsedTime
    }
  })
  
  const material = useMemo(() => {
    if (!config) return null
    
    return new THREE.ShaderMaterial({
      vertexShader: config.vertexShader,
      fragmentShader: config.fragmentShader,
      uniforms,
      side: THREE.DoubleSide,
    })
  }, [config, uniforms])
  
  return { material, materialRef }
}
