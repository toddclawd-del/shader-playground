import { useRef, useCallback } from 'react'
import { useThree, useFrame } from '@react-three/fiber'
import * as THREE from 'three'
import { useShaderStore } from '../stores/shaderStore'

export interface MouseState {
  position: THREE.Vector2
  velocity: THREE.Vector2
  isDown: boolean
  lastPosition: THREE.Vector2
  lastTime: number
}

export function useMouse() {
  const { setMouseState } = useShaderStore()
  const { size, camera } = useThree()

  const state = useRef<MouseState>({
    position: new THREE.Vector2(0.5, 0.5),
    velocity: new THREE.Vector2(0, 0),
    isDown: false,
    lastPosition: new THREE.Vector2(0.5, 0.5),
    lastTime: performance.now(),
  })

  const raycaster = useRef(new THREE.Raycaster())
  const plane = useRef(new THREE.Plane(new THREE.Vector3(0, 0, 1), 0))
  const intersectPoint = useRef(new THREE.Vector3())

  // Convert screen coordinates to normalized UV (0-1)
  const screenToUV = useCallback((clientX: number, clientY: number): THREE.Vector2 => {
    // Convert to normalized device coordinates (-1 to 1)
    const ndc = new THREE.Vector2(
      (clientX / size.width) * 2 - 1,
      -(clientY / size.height) * 2 + 1
    )

    // Cast ray from camera through mouse position
    raycaster.current.setFromCamera(ndc, camera)

    // Intersect with plane at z=0
    if (raycaster.current.ray.intersectPlane(plane.current, intersectPoint.current)) {
      // Map from world coordinates to UV (assuming plane is 3x3 centered at origin)
      return new THREE.Vector2(
        (intersectPoint.current.x / 3 + 0.5),
        (intersectPoint.current.y / 3 + 0.5)
      )
    }

    // Fallback to simple screen-based UV
    return new THREE.Vector2(
      clientX / size.width,
      1 - clientY / size.height
    )
  }, [size, camera])

  const handlePointerMove = useCallback((event: THREE.Event & { clientX: number; clientY: number }) => {
    const now = performance.now()
    const dt = Math.max(now - state.current.lastTime, 1) / 1000 // Convert to seconds

    const newPos = screenToUV(event.clientX, event.clientY)

    // Calculate velocity
    const velocity = new THREE.Vector2(
      (newPos.x - state.current.lastPosition.x) / dt,
      (newPos.y - state.current.lastPosition.y) / dt
    )

    // Clamp velocity for stability
    velocity.clampLength(0, 10)

    // Smooth velocity with previous value
    state.current.velocity.lerp(velocity, 0.5)
    state.current.position.copy(newPos)
    state.current.lastPosition.copy(newPos)
    state.current.lastTime = now

    setMouseState({
      x: state.current.position.x,
      y: state.current.position.y,
      velocityX: state.current.velocity.x,
      velocityY: state.current.velocity.y,
      isDown: state.current.isDown,
    })
  }, [screenToUV, setMouseState])

  const handlePointerDown = useCallback(() => {
    state.current.isDown = true
    setMouseState({
      x: state.current.position.x,
      y: state.current.position.y,
      velocityX: state.current.velocity.x,
      velocityY: state.current.velocity.y,
      isDown: true,
    })
  }, [setMouseState])

  const handlePointerUp = useCallback(() => {
    state.current.isDown = false
    setMouseState({
      x: state.current.position.x,
      y: state.current.position.y,
      velocityX: state.current.velocity.x,
      velocityY: state.current.velocity.y,
      isDown: false,
    })
  }, [setMouseState])

  // Decay velocity over time when not moving
  useFrame(() => {
    if (state.current.velocity.length() > 0.001) {
      state.current.velocity.multiplyScalar(0.95)

      setMouseState({
        x: state.current.position.x,
        y: state.current.position.y,
        velocityX: state.current.velocity.x,
        velocityY: state.current.velocity.y,
        isDown: state.current.isDown,
      })
    }
  })

  return {
    handlePointerMove,
    handlePointerDown,
    handlePointerUp,
  }
}
