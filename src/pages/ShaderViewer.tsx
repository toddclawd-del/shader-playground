import { useEffect } from 'react'
import { useParams, Link } from 'react-router-dom'
import { Leva } from 'leva'
import { ShaderCanvas } from '../components/ShaderCanvas'
import { ShaderInfo } from '../components/ShaderInfo'
import { useDynamicControls } from '../hooks/useDynamicControls'
import { useShaderStore } from '../stores/shaderStore'
import { shaderRegistry } from '../shaders'

function Controls() {
  useDynamicControls()
  return null
}

export function ShaderViewer() {
  const { shaderId } = useParams<{ shaderId: string }>()
  const { setCurrentShader } = useShaderStore()
  
  useEffect(() => {
    if (shaderId && shaderRegistry[shaderId]) {
      setCurrentShader(shaderId, shaderRegistry[shaderId])
    }
  }, [shaderId, setCurrentShader])
  
  return (
    <div style={{ width: '100vw', height: '100vh', position: 'relative' }}>
      <Link to="/" style={styles.backButton}>← Back</Link>
      <Leva
        collapsed={false}
        flat={false}
        theme={{
          colors: {
            elevation1: '#1a1a2e',
            elevation2: '#16213e',
            elevation3: '#0f3460',
            accent1: '#e94560',
            accent2: '#ff6b6b',
            accent3: '#4ecdc4',
          },
        }}
      />
      <Controls />
      <ShaderCanvas />
      <ShaderInfo />
    </div>
  )
}

const styles: Record<string, React.CSSProperties> = {
  backButton: {
    position: 'absolute',
    top: '1rem',
    left: '1rem',
    zIndex: 1000,
    padding: '0.5rem 1rem',
    background: 'rgba(0,0,0,0.6)',
    border: '1px solid rgba(255,255,255,0.2)',
    borderRadius: '8px',
    color: '#fff',
    textDecoration: 'none',
    fontSize: '0.9rem',
    backdropFilter: 'blur(10px)'
  }
}
