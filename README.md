# Shader Playground

Hot-swappable GLSL shaders with React Three Fiber + Leva GUI.

## Features

- 🔄 **Hot-swap shaders** without restart
- 🎛️ **Dynamic GUI** per shader (Leva)
- 🖼️ **Texture support** (drag & drop images/SVGs)
- 🎨 **6 starter shaders** including Book of Shaders classics
- 📐 **Multiple geometries** (plane, sphere, torus, box)

## Quick Start

```bash
npm install
npm run dev
```

## Adding New Shaders

1. Create folder in `src/shaders/your-shader/`
2. Add `fragment.glsl` and optionally `vertex.glsl`
3. Create `config.ts`:

```ts
import fragmentShader from './fragment.glsl'
import vertexShader from '../common/vertex.glsl'
import type { ShaderConfig } from '../../stores/shaderStore'

export const yourShaderConfig: ShaderConfig = {
  name: 'Your Shader',
  description: 'Description here',
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0, type: 'float' },
    uColor: { value: '#ff0000', type: 'color', label: 'Color' },
    uScale: { value: 1, min: 0, max: 10, step: 0.1, type: 'float', label: 'Scale' },
    uTexture: { value: null, type: 'texture', label: 'Image' },
  },
}
```

4. Register in `src/shaders/index.ts`

## Uniform Types

| Type | GUI Control |
|------|-------------|
| `float` | Slider (with min/max/step) |
| `color` | Color picker |
| `texture` | Image upload |
| `bool` | Checkbox |
| `vec2` | 2D input |

## Included Shaders

- **Gradient** - Angled two-color gradient
- **Perlin Noise** - FBM noise with octaves
- **BoS: Shapes** - Circle SDF grid (Book of Shaders)
- **BoS: Patterns** - Tiled cross pattern (Book of Shaders)
- **Waves** - Vertex displacement
- **Texture FX** - Distortion + RGB shift effects

## Tech Stack

- React + TypeScript
- @react-three/fiber
- @react-three/drei
- Leva (GUI)
- Zustand (state)
- vite-plugin-glsl

