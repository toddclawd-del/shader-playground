import { Canvas } from '@react-three/fiber'
import { OrbitControls, Stats, PerspectiveCamera } from '@react-three/drei'
import { ShaderMesh } from './ShaderMesh'
import { MouseHandler } from './MouseHandler'

export function ShaderCanvas() {
  return (
    <Canvas
      gl={{ antialias: true, alpha: true }}
      style={{ background: '#111' }}
    >
      <PerspectiveCamera makeDefault position={[0, 0, 4]} fov={50} />

      <ambientLight intensity={0.5} />
      <pointLight position={[10, 10, 10]} />

      <MouseHandler />
      <ShaderMesh />

      <OrbitControls
        enableDamping
        dampingFactor={0.05}
        minDistance={2}
        maxDistance={10}
      />

      <Stats />
    </Canvas>
  )
}
