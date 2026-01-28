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
