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
