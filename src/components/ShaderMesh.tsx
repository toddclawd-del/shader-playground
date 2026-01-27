import { useRef, useMemo, useEffect } from 'react'
import * as THREE from 'three'
import { useFrame } from '@react-three/fiber'
import { useShaderStore } from '../stores/shaderStore'
import { shaderRegistry } from '../shaders'

// Check if shader uses mouse uniforms
function shaderUsesMouse(fragmentShader: string): boolean {
  return /uniform\s+(vec2|float)\s+uMouse/.test(fragmentShader)
}

export function ShaderMesh() {
  const materialRef = useRef<THREE.ShaderMaterial>(null!)
  const { geometryType, currentShaderId, uniformValues, textures, mouse } = useShaderStore()

  const config = shaderRegistry[currentShaderId]

  // Check if this shader needs mouse uniforms
  const needsMouse = useMemo(() => {
    if (!config) return false
    return shaderUsesMouse(config.fragmentShader)
  }, [config])

  // Build uniforms object
  const uniforms = useMemo(() => {
    if (!config) return {}

    const result: Record<string, THREE.IUniform> = {}

    Object.entries(config.uniforms).forEach(([key, uniformConfig]) => {
      if (uniformConfig.type === 'color') {
        result[key] = { value: new THREE.Color(uniformConfig.value as string) }
      } else if (uniformConfig.type === 'texture') {
        result[key] = { value: null }
      } else {
        result[key] = { value: uniformConfig.value }
      }
    })

    // Auto-inject mouse uniforms if shader uses them
    if (needsMouse) {
      result.uMouse = { value: new THREE.Vector2(0.5, 0.5) }
      result.uMouseVelocity = { value: new THREE.Vector2(0, 0) }
      result.uMouseDown = { value: 0 }
    }

    return result
  }, [config, needsMouse])
  
  // Update uniforms when GUI values change
  useEffect(() => {
    if (!materialRef.current || !config) return
    
    Object.entries(uniformValues).forEach(([key, value]) => {
      if (materialRef.current.uniforms[key] !== undefined) {
        const uniformConfig = config.uniforms[key]
        
        if (uniformConfig?.type === 'color') {
          materialRef.current.uniforms[key].value.set(value)
        } else if (uniformConfig?.type !== 'texture') {
          materialRef.current.uniforms[key].value = value
        }
      }
    })
  }, [uniformValues, config])
  
  // Update textures
  useEffect(() => {
    if (!materialRef.current) return
    
    Object.entries(textures).forEach(([key, texture]) => {
      if (materialRef.current.uniforms[key] !== undefined) {
        materialRef.current.uniforms[key].value = texture
      }
    })
  }, [textures])
  
  // Animate uTime and update mouse uniforms
  useFrame((state) => {
    if (materialRef.current?.uniforms?.uTime) {
      materialRef.current.uniforms.uTime.value = state.clock.elapsedTime
    }

    // Update mouse uniforms each frame
    if (needsMouse && materialRef.current) {
      if (materialRef.current.uniforms.uMouse) {
        materialRef.current.uniforms.uMouse.value.set(mouse.x, mouse.y)
      }
      if (materialRef.current.uniforms.uMouseVelocity) {
        materialRef.current.uniforms.uMouseVelocity.value.set(mouse.velocityX, mouse.velocityY)
      }
      if (materialRef.current.uniforms.uMouseDown) {
        materialRef.current.uniforms.uMouseDown.value = mouse.isDown ? 1 : 0
      }
    }
  })
  
  // Rebuild material when shader changes
  useEffect(() => {
    if (!materialRef.current || !config) return
    
    materialRef.current.vertexShader = config.vertexShader
    materialRef.current.fragmentShader = config.fragmentShader
    materialRef.current.needsUpdate = true
  }, [currentShaderId, config])
  
  if (!config) {
    return (
      <mesh>
        <planeGeometry args={[3, 3]} />
        <meshBasicMaterial color="hotpink" />
      </mesh>
    )
  }
  
  const renderGeometry = () => {
    switch (geometryType) {
      case 'sphere':
        return <sphereGeometry args={[1.5, 256, 256]} />
      case 'torus':
        return <torusGeometry args={[1, 0.4, 128, 256]} />
      case 'box':
        return <boxGeometry args={[2, 2, 2, 128, 128, 128]} />
      case 'plane':
      default:
        return <planeGeometry args={[3, 3, 256, 256]} />
    }
  }
  
  return (
    <mesh>
      {renderGeometry()}
      <shaderMaterial
        ref={materialRef}
        key={currentShaderId}
        vertexShader={config.vertexShader}
        fragmentShader={config.fragmentShader}
        uniforms={uniforms}
        side={THREE.DoubleSide}
      />
    </mesh>
  )
}
