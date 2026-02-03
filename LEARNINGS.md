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

---

## Gyroid Minimal Surface (Added 2026-01-31)

### What It Does

A gyroid is a **triply periodic minimal surface** — a surface that:
1. Repeats infinitely in all 3 directions (triply periodic)
2. Has zero mean curvature everywhere (minimal surface)
3. Self-intersects never — it divides 3D space into two congruent labyrinthine regions

Discovered by NASA scientist Alan Schoen in 1970, gyroids appear in nature in butterfly wings, certain polymer structures, and cell membranes. They're the math behind some of the most organic-looking structures in existence.

### The Core Technique

```glsl
// THE GYROID FORMULA — Elegant one-liner
float gyroid(vec3 p) {
    return dot(sin(p), cos(p.yzx));
}

// Mathematically equivalent to:
// sin(x)*cos(y) + sin(y)*cos(z) + sin(z)*cos(x)
```

That's it. One line. The `dot(sin(p), cos(p.yzx))` trick computes the sum of three sine-cosine products by:
1. `sin(p)` → `vec3(sin(x), sin(y), sin(z))`
2. `cos(p.yzx)` → `vec3(cos(y), cos(z), cos(x))` (swizzled!)
3. `dot()` → sums the component-wise products

### Why It Looks Cool

The gyroid creates **organic, flowing patterns** because:
1. It's a **continuous field** — smooth transitions everywhere
2. The surface (where value = 0) forms interconnected tunnels
3. Slicing through 3D creates ever-changing 2D cross-sections
4. The pattern has no straight lines — all curves, all organic

Animating the z-coordinate (slicing through the structure over time) creates mesmerizing flowing motion that looks like:
- Living tissue
- Alien architecture  
- Soap film structures
- Neural networks

### Key Math Concepts

1. **Implicit Surfaces**
   - The gyroid is defined by `f(x,y,z) = 0`
   - Points where the function equals zero ARE the surface
   - Positive values = one side, Negative = other side
   
2. **Minimal Surface**
   - A surface that locally minimizes area
   - Soap films naturally form minimal surfaces
   - Zero mean curvature at every point
   
3. **Triply Periodic**
   - Pattern repeats with period 2π in all directions
   - Scale parameter controls how many periods are visible
   - `p * scale` zooms in/out on the repeating structure

4. **Using Gyroid as Noise**
   - Stack multiple gyroids at different scales (FBM style)
   - `fbm_gyroid(p) = Σ gyroid(p * 2^i) / 2^i`
   - Creates complex organic textures

### Visualization Modes

| Mode | Name | What It Shows |
|------|------|---------------|
| 0 | Smooth Gradient | Field value mapped to color gradient |
| 1 | Contour Lines | Topographic map of the field |
| 2 | Binary Surface | The actual gyroid surface (value ≈ 0) |
| 3 | Heat Map | Classic scientific visualization |
| 4 | Cellular | Organic/biological appearance |

### How to Modify

| Change This | Effect |
|-------------|--------|
| Scale | Density of pattern (higher = smaller features) |
| Slice Speed | Animation speed through 3D structure |
| Thickness | Width of the surface band in Mode 2 |
| Octaves | FBM complexity (more = more organic detail) |
| Distortion | Adds rotation wobble for psychedelic effect |

### Why Gyroids Matter

1. **Nature's Architecture**: Gyroids appear in biological structures that need maximum surface area in minimum volume — cell membranes, lung tissue, butterfly wings
2. **Material Science**: Gyroid-structured materials have unique mechanical and optical properties
3. **3D Printing**: Gyroid infill patterns are popular for strength-to-weight optimization
4. **Shader Math Gateway**: The formula is simple enough to understand but produces surprisingly complex results — perfect for learning implicit surfaces

### The Math Behind the Magic

The gyroid equation approximates the **zero-level set** of the first Fourier term of the Schwarz P-surface. In plain English: it's the simplest smooth function that creates this type of interconnected tunnel structure.

The `yzx` swizzle in `cos(p.yzx)` creates the **chiral** (handed) nature of the gyroid — it spirals in a specific direction. Using `zxy` instead creates the mirror-image gyroid.

### References

- **Wikipedia**: https://en.wikipedia.org/wiki/Gyroid
- **Alan Schoen's Original Paper**: "Infinite periodic minimal surfaces without self-intersections" (1970)
- **Shadertoy - Up in Flames**: https://www.shadertoy.com/view/WtGXDD (gyroid raymarching)
- **OneShader - Gyroid Noise**: https://oneshader.net/shader/c355b33db7

---

## Implementation Notes

### Gyroid Shader (gyroid/)

**Uniforms Added:**
- Pattern: `uScale`, `uSliceSpeed`, `uSliceOffset`, `uThickness`, `uDistortion`
- FBM: `uOctaves`, `uLacunarity`, `uPersistence`
- Visualization: `uVisualization` (0-4), `uContourFrequency`, `uGlow`, `uColorMix`
- Colors: `uColor1`, `uColor2`, `uColor3`, `uBackgroundColor`

**The 5 Visualization Modes:**
0. **Smooth Gradient** — Field value as color blend
1. **Contour Lines** — Topographic/elevation style
2. **Binary Surface** — Shows the actual gyroid surface with glow
3. **Heat Map** — Classic blue→cyan→green→yellow→red
4. **Cellular** — Organic, biological appearance

**Performance Notes:**
- Single gyroid: Extremely fast (just sin/cos operations)
- With 6 octaves FBM: Still 60+ FPS (adds 6× the sin/cos)
- The visualization modes add negligible cost

**Adaptations:**
- 2D slice through 3D gyroid (animated Z-axis)
- Optional FBM stacking for complexity
- 5 visualization modes for different aesthetics
- Rotation distortion for psychedelic effects
- Vignette for polish

---

## Thin-Film Interference (Added 2026-02-01)

### What It Does

Thin-film interference creates **iridescent rainbow colors** like soap bubbles, oil slicks, and butterfly wings. When light bounces inside a very thin layer (thickness comparable to light wavelengths), the reflected waves interfere with each other — some colors amplify, others cancel out.

This is real physics you can see every day: blow a soap bubble and watch the colors shift as it thins.

### The Core Technique

```glsl
// Thin-film interference in ~10 lines
float thinFilmReflectance(float wavelength, float thickness, float cosTheta, 
                          float n1, float n2, float n3) {
    // Snell's law: sin(θ1)/sin(θ2) = n2/n1
    float cosTheta2 = snellCosTheta2(n1, n2, cosTheta);
    
    // Optical Path Difference: how much farther does the second ray travel?
    float opd = 2.0 * n2 * thickness * cosTheta2;  // in nanometers
    
    // Phase shifts at interfaces (π shift if entering denser medium)
    float phaseOffset = phaseShift(n1, n2) + phaseShift(n2, n3);
    
    // Interference: constructive when waves align, destructive when opposite
    float phi = (2.0 * PI / wavelength) * opd + phaseOffset;
    return 0.5 * (1.0 + cos(phi));  // 1 = constructive, 0 = destructive
}

// Sample R, G, B wavelengths
vec3 iridescence = vec3(
    thinFilmReflectance(650.0, thickness, cos0, n1, n2, n3),  // Red: 650nm
    thinFilmReflectance(510.0, thickness, cos0, n1, n2, n3),  // Green: 510nm
    thinFilmReflectance(475.0, thickness, cos0, n1, n2, n3)   // Blue: 475nm
);
```

### Why It Looks Cool

1. **View-dependent colors**: The color changes as you move your head (cosTheta changes)
2. **Thickness-dependent colors**: Thinner films = different colors (why bubbles look different as they drain)
3. **Rainbow spectrum**: All visible wavelengths compete, creating smooth gradients
4. **Real physics**: You can predict exactly what color a 300nm soap film will show at 45°

### Key Math Concepts

1. **Optical Path Difference (OPD)**
   
   When light hits a thin film, some reflects immediately (Ray 1), some enters the film, reflects off the back, and exits (Ray 2). Ray 2 travels farther:
   ```
   OPD = 2 * n₂ * d * cos(θ₂)
   ```
   Where:
   - `n₂` = refractive index of film (soap ≈ 1.33, oil ≈ 1.5)
   - `d` = film thickness in nanometers
   - `θ₂` = angle inside the film (from Snell's law)

2. **Snell's Law (Refraction)**
   ```
   n₁ * sin(θ₁) = n₂ * sin(θ₂)
   ```
   Light bends when entering a different medium. Higher refractive index = slower light = more bending toward normal.

3. **Phase Shift on Reflection**
   
   When light reflects off a denser medium (n₁ < n₂), the wave flips by half a wavelength (π radians). This is why we check:
   ```glsl
   float shift = (n1 < n2) ? 0.5 : 0.0;  // Half wavelength shift
   ```

4. **Interference Condition**
   
   Constructive interference (bright) when OPD is an integer multiple of wavelength:
   ```
   OPD = m * λ    (m = 1, 2, 3, ...)
   ```
   Destructive interference (dark) when OPD is a half-integer multiple:
   ```
   OPD = (m + 0.5) * λ
   ```

5. **Wavelength ↔ Color**
   
   Visible light: 380nm (violet) → 780nm (red)
   - Blue: ~475nm
   - Green: ~510nm
   - Yellow: ~580nm
   - Red: ~650nm
   
   Sample at least R, G, B wavelengths. For better accuracy, sample 16+ wavelengths across the spectrum.

### The Refractive Index Table

| Material | Refractive Index (n) |
|----------|---------------------|
| Air | 1.00 |
| Water/Soap | 1.33 |
| Oil | 1.45-1.50 |
| Glass | 1.50 |
| Diamond | 2.42 |

**Why it matters**: The n values determine:
1. How much light bends (Snell's law)
2. Whether phase shift occurs at each interface
3. The OPD calculation

### Visualization Modes

| Mode | Name | What It Simulates |
|------|------|-------------------|
| 0 | Soap Bubble | Gravity causes thinner top, thicker bottom + flowing swirls |
| 1 | Oil Slick | Pooling toward center with concentric rings |
| 2 | Abstract | Animated flowing patterns, pure eye candy |

### How to Modify

| Change This | Effect |
|-------------|--------|
| Thickness range | Different color bands (thicker = more cycles through spectrum) |
| N2 (film index) | Oil (1.5) vs water (1.33) changes the color pattern |
| Animation speed | Faster/slower flowing |
| Fresnel strength | More/less color at edges |
| Thickness variation | More/less organic texture |

### Real-World Examples

1. **Soap Bubbles**: n₂ ≈ 1.33, thickness 100-1000nm, constantly thinning
2. **Oil on Water**: n₂ ≈ 1.5, forms interference patterns as it spreads
3. **Butterfly Wings**: Microscopic structures with precise thicknesses create specific colors
4. **CD/DVD**: Diffraction grating (related but different — periodic structure vs thin film)
5. **Car Paint**: Engineered thin-film layers for iridescent "flip" colors

### The Fresnel Effect

The amount of light reflected vs transmitted depends on the viewing angle:
- **Head-on (cosθ ≈ 1)**: Most light passes through, little reflection
- **Grazing angle (cosθ ≈ 0)**: Most light reflects

This is why soap bubbles have stronger colors at the edges. We approximate with:
```glsl
float fresnel = pow(1.0 - cosTheta, 2.0);  // Schlick approximation
```

### References

- **Alan Zucconi's Series**: https://www.alanzucconi.com/2017/07/25/the-mathematics-of-thin-film-interference/
- **Shadertoy - Physically-Based Soap Bubble**: https://www.shadertoy.com/view/XtKyRK
- **Wikipedia**: https://en.wikipedia.org/wiki/Thin-film_interference
- **Physics Origin**: Thomas Young's double-slit experiment (1801)

---

## Implementation Notes

### Thin-Film Interference Shader (thin-film/)

**Uniforms Added:**
- Film: `uThicknessMin`, `uThicknessMax` (nm), `uThicknessVariation`
- Optics: `uN1`, `uN2`, `uN3` (refractive indices)
- Animation: `uAnimSpeed`, `uSwirl`, `uNoiseScale`
- Appearance: `uVisualization` (0-2), `uColorIntensity`, `uFresnelStrength`, `uBaseColor`

**The 3 Visualization Modes:**
0. **Soap Bubble** — Gravity drainage + swirling flow (thick bottom, thin top)
1. **Oil Slick** — Radial pooling with interference rings
2. **Abstract** — Rotating domain-warped patterns

**Performance Notes:**
- Fast version: 3 wavelength samples (R, G, B) — 60+ FPS easily
- Full version: 16 wavelength samples — still 60+ FPS
- Main cost is the spectral loop; everything else is basic math

**Adaptations:**
- View angle simulated from UV distance-from-center (works on flat plane)
- FBM noise for organic thickness variation
- Three visualization modes for different aesthetics
- Wavelength-to-RGB conversion for proper spectral colors
- Fresnel blending for realistic edge intensity

---

## Underwater Caustics (Added 2026-02-02)

### What It Does

Caustics are the dancing patterns of light you see on the bottom of a swimming pool. They occur when sunlight passes through a wavy water surface and gets **refracted** (bent) — the curved surface acts like thousands of tiny lenses, focusing and defocusing light to create bright lines and dark shadows.

This is one of the most beautiful phenomena in nature, and simulating it teaches you about wave physics, optics, and computational geometry all at once.

### The Core Technique

Caustics require three main components:

```glsl
// 1. WAVE SIMULATION - Gerstner waves for realistic water
vec3 gerstnerWave(vec2 position, vec2 direction, float frequency, float amplitude, float steepness) {
    float phase = sqrt(9.81 * frequency);  // Deep water dispersion
    float theta = dot(direction, position) * frequency + time * phase;
    
    // Gerstner: particles move in circles, not just up/down
    // This creates sharp crests and flat troughs (realistic!)
    float Q = steepness / (frequency * amplitude);
    return vec3(
        Q * amplitude * direction.x * cos(theta),  // x displacement
        Q * amplitude * direction.y * cos(theta),  // y displacement  
        amplitude * sin(theta)                      // height
    );
}

// 2. SURFACE NORMALS - from the height field
vec3 computeNormal(vec2 p) {
    float epsilon = 0.01;
    float h0 = getWaveHeight(p);
    float hx = getWaveHeight(p + vec2(epsilon, 0.0));
    float hy = getWaveHeight(p + vec2(0.0, epsilon));
    
    // Gradient gives us the surface slope
    return normalize(vec3(
        -(hx - h0) / epsilon,
        -(hy - h0) / epsilon,
        1.0
    ));
}

// 3. REFRACTION - Snell's Law
vec3 refractRay(vec3 incident, vec3 normal, float eta) {
    // eta = n1/n2 (air/water ≈ 1/1.33 ≈ 0.75)
    float cosI = -dot(normal, incident);
    float sinT2 = eta * eta * (1.0 - cosI * cosI);
    
    if (sinT2 > 1.0) return reflect(incident, normal);  // Total internal reflection
    
    float cosT = sqrt(1.0 - sinT2);
    return eta * incident + (eta * cosI - cosT) * normal;
}
```

### Why It Looks Cool

Caustics create **emergent complexity** from simple physics:

1. **Light concentration**: When wave curves focus rays together → bright lines
2. **Light spreading**: When curves spread rays apart → dark regions
3. **Interference**: Overlapping bright regions from different waves create intricate patterns
4. **Animation**: The constantly moving surface creates hypnotic, organic motion

The resulting pattern has **infinite detail** — no matter how close you zoom, there's more structure. This is because the wave surface has continuous curvature that's never perfectly flat.

### Key Math Concepts

1. **Gerstner Waves (Trochoid Waves)**
   
   Unlike simple sine waves where water moves only up/down, Gerstner waves model the actual circular motion of water particles:
   
   ```
   Real water: particles orbit in circles
   Surface:    steep crests, flat troughs
   Result:     much more realistic appearance
   ```
   
   The `steepness` parameter (0-1) controls how "peaked" the waves are. At steepness=1, crests become infinitely sharp (breaking waves).

2. **Snell's Law of Refraction**
   
   When light crosses between materials with different refractive indices:
   
   ```
   n₁ · sin(θ₁) = n₂ · sin(θ₂)
   ```
   
   | Material | Refractive Index (n) |
   |----------|---------------------|
   | Air | 1.00 |
   | Water | 1.33 |
   | Glass | 1.50 |
   | Diamond | 2.42 |
   
   Higher n = light travels slower = bends toward normal when entering

3. **Normal Calculation via Finite Differences**
   
   For a height field z = f(x, y), the normal is:
   ```glsl
   normal = normalize(vec3(-∂f/∂x, -∂f/∂y, 1.0))
   ```
   
   We approximate partial derivatives:
   ```glsl
   ∂f/∂x ≈ (f(x + ε) - f(x)) / ε
   ```
   
   This is **numerical differentiation** — a fundamental technique you'll use constantly.

4. **Ray Tracing for Caustics**
   
   For each point on the pool floor, we ask: "How much light arrives here?"
   
   The trick: sample the surface above, refract rays downward, and count how many land near our point. More rays = brighter caustic.
   
   ```
   Light concentration = 1 / (area rays spread to)
   ```

5. **Deep Water Dispersion**
   
   Wave speed depends on wavelength in deep water:
   ```
   phase_velocity = √(g · λ / 2π) = √(g / k)
   ```
   Where g = 9.81 m/s² (gravity), k = wave number
   
   This is why tsunamis travel so fast (very long wavelength).

### Visualization Modes

| Mode | Name | Description |
|------|------|-------------|
| 0 | Full Simulation | Raytraced caustics with Gerstner waves |
| 1 | Fast Fake | Interference patterns (cheaper, stylized) |
| 2 | Wave Height | Shows the water surface itself |
| 3 | Normals | Surface normals as RGB (for debugging) |

### The Fake Caustics Trick

Full caustic raytracing is expensive (sampling many surface points per floor pixel). A common shortcut:

```glsl
// Stack multiple sine waves at different angles
float caustic = 0.0;
for (int i = 0; i < 5; i++) {
    float angle = random(i) * TWO_PI;
    float freq = 2.0 + i * 1.5;
    vec2 dir = vec2(cos(angle), sin(angle));
    
    float wave = sin(dot(uv, dir) * freq + time);
    caustic += pow(max(wave, 0.0), 2.0);  // Squared for sharp bright lines
}
```

This creates convincing caustic-like patterns at a fraction of the cost. Many games use this approach.

### How to Modify

| Change This | Effect |
|-------------|--------|
| Wave Count | More waves = more complex patterns (also slower) |
| Wave Amplitude | Higher = more dramatic light focusing |
| Wave Steepness | Higher = sharper crests, more intense caustics |
| Water Depth | Deeper = softer caustics (rays spread more) |
| Refractive Index | Higher = more bending = more intense focusing |
| Animation Speed | Affects the "mood" — slow = serene, fast = chaotic |

### Real-World Examples

1. **Swimming Pool**: Classic caustics — sunlight through rippling surface
2. **Ocean Floor**: Dappled light dancing on sand/coral
3. **Wine Glass**: Caustics from curved glass surface
4. **Disco Ball**: Thousands of tiny caustics from reflective facets
5. **Bathroom Light**: Diffused caustics through frosted shower glass

### The Math Behind Light Focusing

When parallel rays hit a curved surface, they converge/diverge:

```
Convex surface → rays converge → bright spot (focus)
Concave surface → rays diverge → dim region
Inflection point → rays parallel → caustic line (cusp)
```

The caustic pattern is the **envelope** of all refracted rays — the curve that's tangent to every ray. This is pure differential geometry!

### Performance Considerations

- **Full raytracing**: 16-32 samples per pixel, ~45-60 FPS
- **Fake caustics**: Single-pass, ~60+ FPS easily
- **Hybrid**: Use fake for overview, raytrace for hero shots
- **Wave count**: Each wave adds sin/cos calls; 5-6 is usually enough

### References

- **Evan Wallace's WebGL Water**: https://madebyevan.com/webgl-water/ (the OG)
- **Medium Article on Realtime Caustics**: https://medium.com/@evanwallace/rendering-realtime-caustics-in-webgl-2a99a29a0b2c
- **GPU Gems 1, Chapter 2**: "Rendering Water Caustics"
- **Wikipedia - Caustic (optics)**: https://en.wikipedia.org/wiki/Caustic_(optics)
- **Gerstner Waves**: https://en.wikipedia.org/wiki/Trochoidal_wave

---

## Implementation Notes

### Caustics Shader (caustics/)

**Uniforms Added:**
- Waves: `uScale`, `uAnimSpeed`, `uWaveCount`, `uWaveAmplitude`, `uWaveSteepness`
- Physics: `uRefractiveIndex`, `uWaterDepth`
- Appearance: `uCausticIntensity`, `uCausticSharpness`
- Visualization: `uVisualization` (0-3), `uShowWaves`, `uColorMix`
- Colors: `uColor1`, `uColor2`, `uColor3`, `uBackgroundColor`

**The 4 Visualization Modes:**
0. **Full Simulation** — Raytraced caustics with surface sampling
1. **Fast Fake** — Interference patterns, very performant
2. **Wave Height** — Shows the Gerstner wave surface
3. **Normals** — Surface normal vectors as RGB

**Performance Notes:**
- Mode 0: 16 samples per pixel, ~50-60 FPS
- Mode 1: Single pass, 60+ FPS
- Mode 2/3: Nearly free (wave evaluation only)

**Adaptations:**
- Multiple Gerstner waves with pseudo-random directions
- Finite-difference normals for surface gradients
- Snell's law refraction with total internal reflection handling
- Golden angle spiral sampling for better coverage
- Hybrid approach: full simulation + fake detail overlay

---

## Kaleidoscope / Mirror Symmetry (Added 2026-02-03)

### What It Does

A kaleidoscope shader creates **n-fold mirror symmetry** — the same pattern reflected and rotated around a central point, like the view through a real kaleidoscope. By combining polar coordinates with modular arithmetic and reflection, you can transform any image or pattern into a hypnotic mandala.

This is one of the most visually rewarding effects you can build with relatively simple math.

### The Core Technique

```glsl
// THE KALEIDOSCOPE TRANSFORM
vec2 kaleidoscope(vec2 uv, float segments) {
    // Convert to polar coordinates
    float angle = atan(uv.y, uv.x);
    float radius = length(uv);
    
    // Segment angle (360° / n segments)
    float segmentAngle = TAU / segments;  // TAU = 2π
    
    // Fold angle into first segment using modulo
    angle = mod(angle, segmentAngle);
    
    // Mirror every other segment (THIS IS KEY!)
    // Without this, you get rotational symmetry only
    // With this, you get TRUE mirror symmetry
    if (mod(floor(atan(uv.y, uv.x) / segmentAngle), 2.0) >= 1.0) {
        angle = segmentAngle - angle;
    }
    
    // Convert back to cartesian
    return vec2(cos(angle), sin(angle)) * radius;
}
```

### Why It Looks Cool

The kaleidoscope transform creates **infinite complexity from simple inputs**:

1. A single blob of noise becomes a symmetric flower
2. A random texture becomes a sacred geometry mandala
3. Animated patterns become hypnotic, meditation-worthy visuals

The human brain is wired to find symmetry beautiful and calming — kaleidoscopes exploit this directly.

### Key Math Concepts

1. **Polar Coordinates**
   
   Instead of (x, y), we use (angle θ, radius r):
   ```glsl
   // Cartesian → Polar
   float angle = atan(y, x);   // -π to π
   float radius = length(uv);  // Distance from center
   
   // Polar → Cartesian
   float x = cos(angle) * radius;
   float y = sin(angle) * radius;
   ```
   
   Why? Because symmetry operations are TRIVIAL in polar:
   - Rotation = add to angle
   - Mirror = negate or reflect angle
   - Radial repetition = modulo on angle

2. **Modular Arithmetic for Repetition**
   
   `mod(angle, segmentAngle)` wraps any angle back to the first segment:
   ```
   Segments = 6  →  segmentAngle = 60°
   
   Input angle 0°   → Output 0°
   Input angle 45°  → Output 45°
   Input angle 90°  → Output 30° (90 - 60)
   Input angle 180° → Output 0°  (180 - 3*60)
   ```
   
   This creates **rotational symmetry** — the same pattern repeated N times.

3. **Mirror Reflection**
   
   To get **true kaleidoscope** symmetry (not just rotation), we mirror every other segment:
   ```glsl
   // Check if we're in an odd segment (1, 3, 5, ...)
   float segmentIndex = floor(originalAngle / segmentAngle);
   bool isOddSegment = mod(segmentIndex, 2.0) >= 1.0;
   
   // If odd, flip the angle within the segment
   if (isOddSegment) {
       angle = segmentAngle - angle;
   }
   ```
   
   This creates the characteristic "mirrored triangles" of a real kaleidoscope.

4. **Segment Count Effects**
   
   | Segments | Name | Result |
   |----------|------|--------|
   | 2 | Bilateral | Mirror image (like a butterfly) |
   | 3 | Trilateral | Triangular symmetry |
   | 4 | Quadrilateral | Square symmetry |
   | 5 | Pentagonal | Star-like patterns |
   | 6 | Hexagonal | Honeycomb, snowflake patterns |
   | 8 | Octagonal | Ornate Islamic geometry vibes |
   | 12+ | Mandala | Complex circular patterns |

### Pattern Ideas to Feed the Kaleidoscope

The kaleidoscope transform works on ANY pattern. Some great inputs:

1. **FBM Noise** — Creates organic, flowing mandalas
   ```glsl
   float pattern = fbm(kaleidoscopeUv * scale + time);
   ```

2. **Voronoi Cells** — Creates crystalline, stained-glass effects
   ```glsl
   float pattern = voronoi(kaleidoscopeUv * scale);
   ```

3. **Concentric Waves** — Creates pulsing, hypnotic circles
   ```glsl
   float pattern = sin(length(kaleidoscopeUv) * 10.0 - time);
   ```

4. **Spirals** — Creates rotating, psychedelic patterns
   ```glsl
   float angle = atan(uv.y, uv.x);
   float pattern = sin(angle * 5.0 + log(length(uv)) * 10.0);
   ```

5. **Geometric Shapes** — Creates precise, architectural mandalas
   ```glsl
   vec2 grid = fract(kaleidoscopeUv * 4.0);
   float pattern = step(0.5, max(grid.x, grid.y));
   ```

### Animation Techniques

1. **Rotation** — Spin the whole kaleidoscope:
   ```glsl
   uv = mat2(cos(t), -sin(t), sin(t), cos(t)) * uv;
   ```

2. **Flow** — Move the pattern through the transform:
   ```glsl
   float pattern = noise(kaleidoscopeUv + vec2(time, 0.0));
   ```

3. **Pulsing Zoom** — Breathe in and out:
   ```glsl
   uv /= 1.0 + 0.2 * sin(time * 2.0);
   ```

4. **Segment Morphing** — Smoothly change segment count (advanced):
   ```glsl
   float segments = 6.0 + 2.0 * sin(time * 0.3);
   ```

### Color Strategies

1. **Radial Gradient** — Color based on distance from center
   ```glsl
   color = mix(innerColor, outerColor, length(uv));
   ```

2. **Pattern-based** — Color based on the noise/pattern value
   ```glsl
   color = mix(color1, color2, pattern);
   ```

3. **Rainbow Cycling** — HSV with hue tied to pattern or angle
   ```glsl
   vec3 color = hsv2rgb(vec3(pattern * 0.5 + time * 0.1, 1.0, 1.0));
   ```

4. **Angle-based** — Different colors in different segments
   ```glsl
   float hue = angle / TAU;  // Before folding!
   ```

### How to Modify

| Change This | Effect |
|-------------|--------|
| Segments | Symmetry type (6 = hexagonal, 8 = octagonal) |
| Zoom | How much of the pattern is visible |
| Pattern Scale | Density of detail |
| Rotation Speed | Mesmerizing spin effect |
| Distortion | Domain warping for organic feel |
| Color Cycles | More bands of color |

### Real-World Applications

1. **Music Visualizers** — Audio-reactive kaleidoscopes are classic
2. **VJ Software** — Real-time visual performance
3. **Meditation Apps** — Calming, symmetric patterns
4. **Generative Art** — Unique NFTs, prints
5. **Game Effects** — Portals, magic, psychic powers

### Historical Context

Real kaleidoscopes were invented by Sir David Brewster in 1816. They use physical mirrors (typically 2-3) to create reflections. Our shader simulates this mathematically, but can create symmetry configurations impossible with physical mirrors (like 7 or 13 segments).

### References

- **Shadertoy - Kaleidoscope Collection**: https://www.shadertoy.com/results?query=kaleidoscope
- **The Book of Shaders, Chapter 7 (Shapes)**: https://thebookofshaders.com/07/
- **Polar Coordinates Visualization**: https://www.desmos.com/calculator/polar
- **Wikipedia - Kaleidoscope**: https://en.wikipedia.org/wiki/Kaleidoscope

---

## Implementation Notes

### Kaleidoscope Shader (kaleidoscope/)

**Uniforms Added:**
- Symmetry: `uSegments`, `uRotation`, `uRotationSpeed`, `uZoom`
- Pattern: `uPatternStyle` (0-4), `uPatternScale`, `uDistortion`, `uComplexity`
- Animation: `uPulse`, `uFlowSpeed`
- Colors: `uColor1`, `uColor2`, `uColor3`, `uColorCycles`, `uSaturation`, `uBrightness`
- Effects: `uCenterGlow`, `uEdgeFade`, `uChromatic`

**The 5 Pattern Styles:**
0. **Noise** — FBM flowing organic patterns
1. **Voronoi** — Animated crystalline cells
2. **Waves** — Interfering circular waves
3. **Spirals** — Logarithmic spiral patterns
4. **Geometric** — Circles, diamonds, and radial lines

**Performance Notes:**
- Very lightweight base transform (just atan + mod + sin/cos)
- Pattern generation is the main cost (FBM: ~5 octaves, Voronoi: 9 cells)
- Chromatic aberration triples pattern calculations when enabled
- Easily 60+ FPS for all patterns except chromatic + voronoi combo

**Adaptations:**
- True mirror symmetry (not just rotational)
- Optional domain warping for organic distortion
- Five built-in pattern generators
- Rainbow color cycling with HSV
- Center glow and edge vignette for polish
- Chromatic aberration for extra visual interest
