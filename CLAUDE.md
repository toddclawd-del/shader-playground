# Shader Playground - Claude Code Guide

## Build & Development Commands

```bash
npm run dev      # Start development server (Vite)
npm run build    # Build for production
npm run preview  # Preview production build
npm run lint     # Run ESLint
```

## Architecture Overview

**Stack:** React + TypeScript + Three.js (via react-three-fiber) + Zustand + Leva

### Core Components

| File | Purpose |
|------|---------|
| `src/App.tsx` | Entry point, initializes first shader on mount |
| `src/components/ShaderCanvas.tsx` | Three.js Canvas setup, camera, lights, OrbitControls |
| `src/components/ShaderMesh.tsx` | Renders geometry with shader material, manages uniforms, animates uTime |
| `src/components/ShaderInfo.tsx` | Displays current shader name and description |

### State Management

| File | Purpose |
|------|---------|
| `src/stores/shaderStore.ts` | Zustand store for shader state, geometry type, uniform values, textures |
| `src/hooks/useDynamicControls.ts` | Generates Leva GUI controls dynamically from shader config |
| `src/hooks/useMouse.ts` | Tracks mouse position, velocity, and click state for interactive shaders |

### Shader System

| File | Purpose |
|------|---------|
| `src/shaders/index.ts` | Central registry - all shaders must be registered here |
| `src/shaders/common/vertex.glsl` | Basic vertex shader (vUv, vPosition, vNormal) |
| `src/shaders/common/displace-vertex.glsl` | Vertex shader for displacement effects |
| `src/shaders/common/noise.glsl` | Shared noise functions (perlin, simplex, curl, FBM) |
| `src/shaders/common/sdf.glsl` | Shared SDF functions (primitives, boolean ops) |

## How to Add a New Shader

### 1. Create shader directory

```
src/shaders/{shader-name}/
├── config.ts
└── fragment.glsl
```

### 2. Create fragment.glsl

```glsl
varying vec2 vUv;

uniform float uTime;
uniform vec3 uColor1;
// ... other uniforms matching config

void main() {
    vec3 color = uColor1;
    // shader logic here
    gl_FragColor = vec4(color, 1.0);
}
```

### 3. Create config.ts

```typescript
import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const myShaderConfig: ShaderConfig = {
  name: 'My Shader',
  description: 'A brief description',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    uColor1: { value: '#ff6b6b', type: 'color', label: 'Primary Color' },
    uSpeed: { value: 1.0, min: 0.1, max: 5.0, step: 0.1, type: 'float', label: 'Speed' },
    uAmount: { value: 0.5, min: 0, max: 1, step: 0.01, type: 'float', label: 'Amount' },
  },
}
```

### 4. Register in src/shaders/index.ts

```typescript
import { myShaderConfig } from './my-shader/config'

export const shaderRegistry: Record<string, ShaderConfig> = {
  // ... existing shaders
  'my-shader': myShaderConfig,
}
```

## Uniform Types

| Type | Config | GLSL | GUI Control |
|------|--------|------|-------------|
| `float` | `{ value: 1.0, min: 0, max: 2, step: 0.1, type: 'float' }` | `uniform float uValue;` | Slider |
| `color` | `{ value: '#ff6b6b', type: 'color' }` | `uniform vec3 uColor;` | Color picker |
| `bool` | `{ value: false, type: 'bool' }` | `uniform float uEnabled;` (0/1) | Toggle |
| `vec2` | `{ value: [0.5, 0.5], type: 'vec2' }` | `uniform vec2 uPos;` | 2D point |
| `texture` | `{ value: null, type: 'texture' }` | `uniform sampler2D uTexture;` | File upload |

## Mouse Uniforms (Auto-Injected)

Shaders can use these mouse uniforms - they're automatically injected if the shader references them:

```glsl
uniform vec2 uMouse;           // Normalized UV position (0-1)
uniform vec2 uMouseVelocity;   // Movement delta for momentum effects
uniform float uMouseDown;      // 1.0 when clicked, 0.0 otherwise
```

## Presets System

Presets are saved per-shader to localStorage and persist across sessions.

**GUI Controls (in Presets folder):**
- `Save Preset` - Prompts for name, saves current uniform values
- `1. PresetName` - Click to load that preset
- `Delete Last` - Removes the most recent preset

**Export Controls (in Export folder):**
- `Copy GLSL` - Copies shader code with uniform docs to clipboard
- `Download Shader` - Downloads .glsl file
- `Download Config` - Downloads current values as JSON

**Programmatic Access:**
```typescript
import { usePresets } from './hooks/usePresets'

const { savePreset, applyPreset, presets } = usePresets()
savePreset('My Preset')
applyPreset(presets[0].id)
```

## Key Patterns

### Data Flow
```
User adjusts Leva GUI
  → useDynamicControls.onChange
  → shaderStore.setUniformValue
  → ShaderMesh useEffect detects change
  → Updates material.uniforms
  → Three.js renders next frame
```

### Color Handling
- Config stores colors as hex strings: `'#ff6b6b'`
- ShaderMesh converts to THREE.Color on init
- Use `.set()` to update (preserves reference)

### Time Animation
- `uTime` is auto-animated in ShaderMesh.useFrame()
- Uses `state.clock.elapsedTime` (seconds from start)
- Use `sin(uTime * speed)` for oscillation

## Supported Geometries

- `plane` - 3x3, 256x256 subdivisions
- `sphere` - radius 1.5, 256x256 segments
- `torus` - radius 1, tube 0.4, 128x256 segments
- `box` - 2x2x2, 128x128x128 subdivisions

## Testing Checklist

After adding/modifying a shader:
1. `npm run dev` and verify it loads
2. Test all GUI controls respond correctly
3. Test on each geometry type
4. Check browser console for WebGL errors
5. Verify mouse interaction (if applicable)
