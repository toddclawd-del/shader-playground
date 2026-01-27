import { useMouse } from '../hooks/useMouse'

export function MouseHandler() {
  const { handlePointerMove, handlePointerDown, handlePointerUp } = useMouse()

  return (
    <mesh
      onPointerMove={handlePointerMove}
      onPointerDown={handlePointerDown}
      onPointerUp={handlePointerUp}
      onPointerLeave={handlePointerUp}
      visible={false}
    >
      {/* Invisible plane to capture mouse events across the entire viewport */}
      <planeGeometry args={[100, 100]} />
      <meshBasicMaterial transparent opacity={0} />
    </mesh>
  )
}
