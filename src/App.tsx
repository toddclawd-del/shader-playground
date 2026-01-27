import { useEffect } from 'react'
import { Leva } from 'leva'
import { ShaderCanvas } from './components/ShaderCanvas'
import { ShaderInfo } from './components/ShaderInfo'
import { useDynamicControls } from './hooks/useDynamicControls'
import { useShaderStore } from './stores/shaderStore'
import { shaderRegistry } from './shaders'

function Controls() {
  useDynamicControls()
  return null
}

function App() {
  const { currentShaderId, setCurrentShader } = useShaderStore()
  
  // Initialize with first shader
  useEffect(() => {
    if (!currentShaderId) {
      const firstShaderId = Object.keys(shaderRegistry)[0]
      const firstConfig = shaderRegistry[firstShaderId]
      if (firstShaderId && firstConfig) {
        setCurrentShader(firstShaderId, firstConfig)
      }
    }
  }, [currentShaderId, setCurrentShader])
  
  return (
    <div style={{ width: '100vw', height: '100vh', position: 'relative' }}>
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

export default App
