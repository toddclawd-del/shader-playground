import { useShaderStore } from '../stores/shaderStore'
import { shaderRegistry } from '../shaders'

export function ShaderInfo() {
  const { currentShaderId } = useShaderStore()
  const config = shaderRegistry[currentShaderId]
  
  if (!config) return null
  
  return (
    <div
      style={{
        position: 'absolute',
        bottom: 20,
        left: 20,
        color: '#fff',
        fontFamily: 'monospace',
        fontSize: 14,
        background: 'rgba(0,0,0,0.7)',
        padding: '12px 16px',
        borderRadius: 8,
        maxWidth: 300,
      }}
    >
      <h3 style={{ margin: '0 0 8px 0', fontSize: 16 }}>{config.name}</h3>
      {config.description && (
        <p style={{ margin: 0, opacity: 0.8 }}>{config.description}</p>
      )}
    </div>
  )
}
