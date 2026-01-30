# Shader Playground Learnings

This file documents shader concepts and techniques for learning purposes.

---

## Domain Warping (Added 2026-01-28)

### What It Does

Domain warping creates organic, flowing patterns by recursively distorting the input coordinates of a noise function. Instead of just evaluating `noise(position)`, we evaluate `noise(position + noise(position))` — and can stack multiple layers.

### The Core Technique

```glsl
// Level 1: Simple noise
float pattern = fbm(p);

// Level 2: First warp layer - feed noise into itself
vec2 q = vec2(fbm(p + offset1), fbm(p + offset2));
float pattern = fbm(p + warpStrength * q);

// Level 3: Double warp - now it gets interesting
vec2 q = vec2(fbm(p + offset1), fbm(p + offset2));
vec2 r = vec2(fbm(p + warp1 * q + offset3), fbm(p + warp1 * q + offset4));
float pattern = fbm(p + warp2 * r);
```

### Why It Looks Cool

The recursive distortion creates **self-similar turbulence** — patterns that look like:
- Marble veins
- Smoke/cloud formations
- Fluid dynamics
- Alien organic textures

Each warp layer introduces new frequency components while maintaining coherent large-scale structure.

### Key Math Concepts

1. **Fractal Brownian Motion (FBM)**
   - Sum of noise at multiple frequencies (octaves)
   - Each octave: `amplitude *= gain`, `frequency *= lacunarity`
   - Creates natural-looking detail at multiple scales
   
2. **Lacunarity** (typically 2.0)
   - How much frequency increases per octave
   - Higher = more fine detail, lower = smoother
   
3. **Gain/Persistence** (typically 0.5)
   - How much amplitude decreases per octave
   - Higher = rougher, lower = smoother

4. **Offset Vectors**
   - Prevent symmetry and self-correlation
   - Give each noise component unique character
   - Example: `fbm(p + vec2(5.2, 1.3))` vs `fbm(p + vec2(8.3, 2.8))`

### Color Mapping Trick

The intermediate values `q` and `r` carry information about the distortion at each level. Use them for coloring:

```glsl
vec3 color = mix(color1, color2, pattern);          // Base gradient
color = mix(color, color3, length(q) * variation);  // Warp intensity
color = mix(color, color4, r.y * variation);        // Directional component
```

This creates the flowing color bands characteristic of IQ's work.

### How to Modify

| Change This | Effect |
|-------------|--------|
| Scale | Pattern density (lower = bigger features) |
| Warp Intensity | More distortion = more turbulent, less = smoother |
| Octaves | Detail level (more = finer details, costs performance) |
| Lacunarity | 2.0 is natural, try 2.5+ for crushed/aggressive look |
| Animation offsets | Different speeds per layer creates complex motion |

### Reference

- **Original Article**: https://iquilezles.org/articles/warp/
- **Shadertoy Example**: https://www.shadertoy.com/view/lsl3RH
- **Inventor**: Inigo Quilez (2002, refined 2012)

---

## Implementation Notes

### Domain Warping Shader (domain-warp/)

**Uniforms Added:**
- `uScale` - Overall pattern scale
- `uWarpIntensity1` - First warp layer strength (q)
- `uWarpIntensity2` - Second warp layer strength (r)
- `uAnimSpeed` - Animation speed multiplier
- `uOctaves` - FBM octave count (1-8)
- `uLacunarity` - Frequency multiplier
- `uGain` - Amplitude multiplier (persistence)
- `uColorVariation` - How much q/r affect coloring
- 4 color controls + background

**Performance Notes:**
- 5 octaves is the sweet spot (good detail, stable 60+ FPS)
- 8 octaves looks better but may dip on mobile
- The nested fbm calls are the performance cost — 3 calls × 5 octaves = 15 noise evaluations per pixel

**Adaptations:**
- Used quintic interpolation for smoother gradients
- Exposed intermediate q/r for color mapping (IQ technique)
- Added edge vignette for polish
- Time offsets vary per layer for complex animation

---

## Julia Set Fractals (Added 2026-01-29)

### What It Does

Julia sets visualize the boundary between "escaping" and "bounded" points under iteration of the complex function f(z) = z² + c. They're the OG shader flex — mathematically elegant, visually infinite, and a perfect intro to complex number arithmetic in GLSL.

### The Core Technique

```glsl
// Complex number squared: z² = (a + bi)² = (a² - b²) + 2abi
vec2 complexSquare(vec2 z) {
    return vec2(
        z.x * z.x - z.y * z.y,  // real: a² - b²
        2.0 * z.x * z.y         // imaginary: 2ab
    );
}

// Escape time algorithm
int iterations = 0;
for (int i = 0; i < maxIterations; i++) {
    if (length(z) > 2.0) break;  // Escaped!
    z = complexSquare(z) + c;     // The magic formula
    iterations++;
}
```

### Why It Looks Cool

**Self-similarity at infinite scales.** Zoom in forever and you keep finding similar structures. This is the mathematical definition of a fractal.

The boundary between "escapes to infinity" and "stays bounded" is infinitely complex — no matter how close you look, there's always more detail.

### Key Math Concepts

1. **Complex Numbers as vec2**
   - Real part → x component
   - Imaginary part → y component
   - Complex plane = 2D coordinate system
   
2. **Complex Multiplication**
   ```
   (a + bi)(c + di) = (ac - bd) + (ad + bc)i
   ```
   In GLSL: `vec2(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x)`

3. **Escape Radius**
   - If |z| > 2, it's guaranteed to escape to infinity
   - We check |z|² > 4 (faster than sqrt)
   
4. **Julia vs Mandelbrot**
   - **Mandelbrot:** c varies per pixel, z₀ = 0
   - **Julia:** c is constant, z₀ varies per pixel
   - Each point in Mandelbrot corresponds to a unique Julia set!

5. **Smooth Coloring (Anti-aliasing)**
   ```glsl
   // Instead of integer iteration count, get fractional:
   float log_zn = log(dot(z, z)) / 2.0;  // log|z|
   float nu = log(log_zn / log(2.0)) / log(2.0);
   float smoothIter = float(iterations) + 1.0 - nu;
   ```
   This removes the harsh banding you see with integer iteration counts.

### The c Parameter: Julia Set Topology

The constant c determines the Julia set's shape:

| c value | Result |
|---------|--------|
| c inside Mandelbrot | Connected Julia set ("filled") |
| c outside Mandelbrot | Disconnected ("Cantor dust") |
| c on Mandelbrot boundary | Infinitely complex boundary |

**Famous Julia sets:**
- c = -0.4 + 0.6i — Classic dendrite/lightning
- c = -0.8 + 0.156i — Spirals
- c = -0.7269 + 0.1889i — Douady's rabbit
- c = 0 + i — Dendrite
- c = -1 + 0i — The "basilica"

### Animation Trick

Orbiting c around a circle creates smooth morphing between Julia set topologies:

```glsl
float t = uTime * speed;
float r = 0.7885;  // Radius that passes through interesting c values
vec2 c = vec2(r * cos(t), r * sin(t));
```

The radius 0.7885 traces along the Mandelbrot boundary, giving maximum variety.

### How to Modify

| Change This | Effect |
|-------------|--------|
| Max iterations | More detail at edges, but costs performance |
| c value | Completely different fractal shape |
| Zoom | Deeper exploration (increase iterations to match) |
| Color cycles | More/fewer bands in the coloring |
| Animation radius | Different paths through Julia set space |

### Performance Considerations

- **100 iterations:** Good for overview, 60+ FPS everywhere
- **200-300:** Better edge detail, starts to stress mobile
- **500+:** Beautiful but expensive, desktop only
- The loop is the entire cost — minimize iterations for speed

### Why Julia Sets Matter

Beyond looking sick, Julia sets demonstrate:
1. **Sensitive dependence on initial conditions** (chaos theory)
2. **Self-similarity** (fractal geometry)
3. **Complex dynamics** (how iteration creates structure)

Every graphics programmer should understand them — they're a gateway to procedural generation, noise functions, and thinking about iteration.

### References

- **Wikipedia:** https://en.wikipedia.org/wiki/Julia_set
- **Interactive Explorer:** https://www.shadertoy.com/view/MdX3Rr
- **The Math:** "The Beauty of Fractals" by Peitgen & Richter

---

## Implementation Notes

### Julia Set Shader (julia-set/)

**Uniforms Added:**
- Navigation: `uZoom`, `uCenter` (vec2)
- Julia constant: `uC` (vec2), `uAnimateC` (bool), `uAnimSpeed`
- Quality: `uMaxIterations` (10-500)
- Colors: `uColorCycles`, `uColor1/2/3`, `uSaturation`, `uInteriorStyle`

**Performance Notes:**
- 100 iterations is the default (75 FPS on M1)
- Smooth coloring eliminates banding without extra cost
- The loop early-exits on escape, so empty areas are fast

**Adaptations:**
- Animated c orbits at r=0.7885 for maximum visual variety
- Smooth iteration count for anti-aliased coloring
- Three-color gradient with configurable cycles
- Optional colored interior (based on final z position)

---

## Truchet Tiles (Added 2026-01-30)

### What It Does

Truchet tiles create **emergent complexity from simple rules**. You divide space into a grid, randomly rotate each tile, and because the tile elements connect at edges, you get continuous woven paths, mazes, and organic patterns.

Named after Sébastien Truchet (1704), who studied how a single square tile with a diagonal line could create infinite variety through random rotation.

### The Core Technique

```glsl
// 1. Divide space into grid cells
vec2 cellId = floor(position * scale);
vec2 cellUv = fract(position * scale);

// 2. Deterministic random per cell (the magic)
float hash = hash21(cellId);
float flip = step(0.5, hash);  // 50% chance of rotation

// 3. Draw tile elements based on flip state
// For quarter-circle arcs: corners swap based on flip
vec2 corner1 = flip > 0.5 ? vec2(0.0, 0.0) : vec2(1.0, 0.0);
vec2 corner2 = flip > 0.5 ? vec2(1.0, 1.0) : vec2(0.0, 1.0);

// 4. Render arcs from corners with radius 0.5
float d1 = abs(length(cellUv - corner1) - 0.5) - lineWidth;
float d2 = abs(length(cellUv - corner2) - 0.5) - lineWidth;
float d = min(d1, d2);
```

### Why It Looks Cool

The simple rotation rule creates **emergent behavior**:
- Quarter-circle arcs form continuous "tubes" that weave across the entire grid
- Diagonal lines create maze-like patterns
- The randomness is local, but the patterns are global

This is a beautiful example of how **local rules create global structure** — a fundamental principle in generative art, cellular automata, and nature itself.

### Key Math Concepts

1. **Grid Subdivision with floor() and fract()**
   ```glsl
   vec2 id = floor(uv * scale);   // Which cell (integer)
   vec2 st = fract(uv * scale);   // Position within cell (0-1)
   ```
   This is THE most important pattern in procedural textures. Master this.

2. **Deterministic Randomness (Hash Functions)**
   ```glsl
   float hash21(vec2 p) {
       p = fract(p * vec2(234.34, 435.345));
       p += dot(p, p + 34.23);
       return fract(p.x * p.y);
   }
   ```
   Same input → same output, every frame. Pure functions are GPU-friendly.

3. **SDF for Arcs/Rings**
   ```glsl
   // Distance to a ring (circle outline)
   float sdRing(vec2 p, vec2 center, float radius, float width) {
       return abs(length(p - center) - radius) - width;
   }
   ```
   The `abs()` turns a circle SDF into a ring by making both sides of the circle boundary positive.

4. **Why Radius 0.5?**
   - Cell is 1×1 in local coordinates
   - Arc from corner needs to reach the midpoint of adjacent edges
   - `0.5` radius from corner (0,0) reaches (0.5, 0) and (0, 0.5) exactly
   - When neighbor tile flips, its arc meets yours perfectly

### Tile Style Variations

| Style | Element | Visual Result |
|-------|---------|---------------|
| 0 - Arcs | Quarter-circle rings | Woven tubes, knitting patterns |
| 1 - Diagonals | Line segments | Maze, 10 PRINT pattern |
| 2 - Circles | Filled quarter-circles | Organic blobs, cellular |
| 3 - Double | Nested arcs | Richer texture, more depth |
| 4 - Weave | Arcs with depth shading | Over/under illusion |

### The 10 PRINT Connection

The famous one-liner:
```basic
10 PRINT CHR$(205.5+RND(1)); : GOTO 10
```
This Commodore 64 program (1982) is essentially Truchet tiles with diagonal lines. It prints either `/` or `\` randomly, creating maze patterns. Same principle, different medium.

**Book:** "10 PRINT CHR$(205.5+RND(1)); : GOTO 10" (MIT Press, 2013) — entire book analyzing this one-liner.

### Animation Tricks

1. **Color Flow**: Use position along the path for gradient:
   ```glsl
   float pathColor = length(uv) + time * speed;
   ```

2. **Tile Flipping**: Periodically change flip states:
   ```glsl
   float period = 4.0 + hash * 4.0;  // Vary per tile
   float flipPhase = floor(time / period);
   flip = fract(hash + flipPhase * 0.5);
   ```

3. **Arc Progress Coloring**: Use angle around arc center:
   ```glsl
   float arcProgress = atan(cellUv.y - corner.y, cellUv.x - corner.x) / PI;
   ```

### How to Modify

| Change This | Effect |
|-------------|--------|
| Scale | More/fewer tiles (higher = denser pattern) |
| Line Width | Thicker = bolder graphic, thinner = delicate |
| Tile Style | Completely different visual language |
| Hash Seed | Different random arrangement, same statistics |
| Animation | Flow, flip, or pulse for motion |

### Why Truchet Matters

1. **Grid + Random = Order**: Demonstrates how constraints (grid, connection rules) channel randomness into structure
2. **Emergent Complexity**: Local rules, global patterns — same principle as Conway's Game of Life
3. **Foundation for More**: Once you understand Truchet, you can build:
   - Wang tiles (more edge types)
   - Marching squares (terrain generation)
   - Wave Function Collapse (constraint-based generation)

### References

- **The Book of Shaders, Chapter 9**: https://thebookofshaders.com/09/
- **Wikipedia**: https://en.wikipedia.org/wiki/Truchet_tiles
- **Original Paper**: Sébastien Truchet, "Mémoire sur les combinaisons" (1704)
- **10 PRINT Book**: http://10print.org/

---

## Implementation Notes

### Truchet Tiles Shader (truchet-tiles/)

**Uniforms Added:**
- Pattern: `uScale` (grid density), `uLineWidth`, `uTileStyle` (0-4), `uAntiAlias`
- Animation: `uAnimSpeed`, `uColorSpeed`, `uAnimateTiles` (flip animation toggle)
- Colors: `uColor1`, `uColor2`, `uColor3`, `uBackgroundColor`

**The 5 Tile Styles:**
0. **Arcs** — Classic Smith pattern, woven tubes
1. **Diagonals** — 10 PRINT maze effect
2. **Quarter Circles** — Filled arcs, organic blobs
3. **Double Arcs** — Nested rings, richer texture
4. **Weave** — Arcs with over/under depth shading

**Performance Notes:**
- Very lightweight — just 2 SDF evaluations per pixel
- Easily 60+ FPS at any scale
- Anti-aliasing via `smoothstep()` is the only "expensive" part

**Adaptations:**
- Multi-style support via uniform toggle
- Color mapped to path progress, cell ID, and arc position
- Optional tile flip animation with per-tile timing
- Edge highlighting for extra polish
