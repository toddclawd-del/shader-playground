import { useRef, useEffect } from 'react'
import * as THREE from 'three'
import { useShaderStore } from '../stores/shaderStore'
import { useShaderMaterial } from '../hooks/useShaderMaterial'

export function ShaderMesh() {
  const meshRef = useRef<THREE.Mesh>(null)
  const { geometryType, currentShaderId } = useShaderStore()
  const { material, materialRef } = useShaderMaterial()
  
  // Attach material ref
  useEffect(() => {
    if (meshRef.current && material) {
      meshRef.current.material = material
      ;(materialRef as any).current = material
    }
  }, [material, materialRef])
  
  // Force material update when shader changes
  useEffect(() => {
    if (material) {
      material.needsUpdate = true
    }
  }, [currentShaderId, material])
  
  if (!material) return null
  
  const renderGeometry = () => {
    switch (geometryType) {
      case 'sphere':
        return <sphereGeometry args={[1.5, 64, 64]} />
      case 'torus':
        return <torusGeometry args={[1, 0.4, 32, 100]} />
      case 'box':
        return <boxGeometry args={[2, 2, 2, 32, 32, 32]} />
      case 'plane':
      default:
        return <planeGeometry args={[3, 3, 64, 64]} />
    }
  }
  
  return (
    <mesh ref={meshRef}>
      {renderGeometry()}
      <primitive object={material} attach="material" />
    </mesh>
  )
}
