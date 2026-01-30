varying vec2 vUv;

uniform float uTime;
uniform float uScale;
uniform float uLineWidth;
uniform float uAnimSpeed;
uniform float uColorSpeed;
uniform float uTileStyle;
uniform float uAntiAlias;
uniform float uAnimateTiles;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uColor3;
uniform vec3 uBackgroundColor;

#define PI 3.14159265359
#define TAU 6.28318530718

// ============================================
// Hash Functions
// ============================================

// 2D -> 1D hash (deterministic random per cell)
float hash21(vec2 p) {
    p = fract(p * vec2(234.34, 435.345));
    p += dot(p, p + 34.23);
    return fract(p.x * p.y);
}

// 2D -> 2D hash
vec2 hash22(vec2 p) {
    vec3 a = fract(p.xyx * vec3(234.34, 435.345, 654.165));
    a += dot(a, a + 34.23);
    return fract(vec2(a.x * a.y, a.y * a.z));
}

// ============================================
// SDF Functions
// ============================================

// Distance to a circle centered at 'c' with radius 'r'
float sdCircle(vec2 p, vec2 c, float r) {
    return length(p - c) - r;
}

// Distance to an arc (ring segment)
float sdRing(vec2 p, vec2 c, float r, float w) {
    return abs(length(p - c) - r) - w;
}

// Distance to a line segment
float sdLine(vec2 p, vec2 a, vec2 b, float w) {
    vec2 pa = p - a;
    vec2 ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h) - w;
}

// ============================================
// Truchet Tile Patterns
// ============================================

// Style 0: Quarter-circle arcs (the classic "Smith" pattern)
// Creates woven tube-like patterns
float truchetArcs(vec2 p, float flip, float w) {
    // Two quarter-circle arcs in opposite corners
    // When flipped, the connection points change creating continuous paths
    
    vec2 corner1 = flip > 0.5 ? vec2(0.0, 0.0) : vec2(1.0, 0.0);
    vec2 corner2 = flip > 0.5 ? vec2(1.0, 1.0) : vec2(0.0, 1.0);
    
    float d1 = sdRing(p, corner1, 0.5, w);
    float d2 = sdRing(p, corner2, 0.5, w);
    
    return min(d1, d2);
}

// Style 1: Diagonal lines
// Creates maze-like patterns
float truchetDiagonals(vec2 p, float flip, float w) {
    vec2 a = flip > 0.5 ? vec2(0.0, 0.0) : vec2(1.0, 0.0);
    vec2 b = flip > 0.5 ? vec2(1.0, 1.0) : vec2(0.0, 1.0);
    
    return sdLine(p, a, b, w);
}

// Style 2: Quarter-circles (filled arcs, not rings)
// Creates organic blob-like patterns
float truchetQuarterCircles(vec2 p, float flip, float w) {
    vec2 corner1 = flip > 0.5 ? vec2(0.0, 0.0) : vec2(1.0, 0.0);
    vec2 corner2 = flip > 0.5 ? vec2(1.0, 1.0) : vec2(0.0, 1.0);
    
    float d1 = sdCircle(p, corner1, 0.5);
    float d2 = sdCircle(p, corner2, 0.5);
    
    // Combine for interesting overlap
    return min(d1, d2);
}

// Style 3: Double arcs (nested rings for richer pattern)
float truchetDoubleArcs(vec2 p, float flip, float w) {
    vec2 corner1 = flip > 0.5 ? vec2(0.0, 0.0) : vec2(1.0, 0.0);
    vec2 corner2 = flip > 0.5 ? vec2(1.0, 1.0) : vec2(0.0, 1.0);
    
    // Outer arcs
    float d1 = sdRing(p, corner1, 0.5, w);
    float d2 = sdRing(p, corner2, 0.5, w);
    
    // Inner arcs (smaller radius)
    float d3 = sdRing(p, corner1, 0.25, w * 0.7);
    float d4 = sdRing(p, corner2, 0.25, w * 0.7);
    
    return min(min(d1, d2), min(d3, d4));
}

// Style 4: Weave pattern (arcs with over/under illusion)
float truchetWeave(vec2 p, float flip, float w, out float depth) {
    vec2 corner1 = flip > 0.5 ? vec2(0.0, 0.0) : vec2(1.0, 0.0);
    vec2 corner2 = flip > 0.5 ? vec2(1.0, 1.0) : vec2(0.0, 1.0);
    
    float d1 = sdRing(p, corner1, 0.5, w);
    float d2 = sdRing(p, corner2, 0.5, w);
    
    // Determine which arc is "on top" based on position
    // This creates the weave illusion
    float distFromCenter = length(p - vec2(0.5));
    depth = flip > 0.5 ? 
        (distFromCenter < 0.35 ? 1.0 : 0.0) : 
        (distFromCenter < 0.35 ? 0.0 : 1.0);
    
    return min(d1, d2);
}

// ============================================
// Color Functions
// ============================================

vec3 palette(float t) {
    t = fract(t);
    
    if (t < 0.33) {
        return mix(uColor1, uColor2, t * 3.0);
    } else if (t < 0.66) {
        return mix(uColor2, uColor3, (t - 0.33) * 3.0);
    } else {
        return mix(uColor3, uColor1, (t - 0.66) * 3.0);
    }
}

// ============================================
// Main
// ============================================

void main() {
    vec2 uv = vUv;
    
    // Scale the grid
    vec2 p = uv * uScale;
    
    // Get the cell ID and local position within cell
    vec2 cellId = floor(p);
    vec2 cellUv = fract(p);
    
    // Time for animation
    float time = uTime * uAnimSpeed;
    
    // Determine tile flip state using hash
    // This is the core of Truchet: random rotation per tile
    float hash = hash21(cellId);
    
    // Optionally animate the flip state over time
    float flip = hash;
    if (uAnimateTiles > 0.5) {
        // Periodically flip tiles based on their hash + time
        float flipPeriod = 4.0 + hash * 4.0; // Each tile has different period
        float flipPhase = floor(time / flipPeriod);
        flip = fract(hash + flipPhase * 0.5);
    }
    flip = step(0.5, flip);
    
    // Line width (responsive to scale)
    float w = uLineWidth / uScale;
    
    // Calculate distance based on tile style
    float d;
    float depth = 0.0;
    
    if (uTileStyle < 0.5) {
        d = truchetArcs(cellUv, flip, w);
    } else if (uTileStyle < 1.5) {
        d = truchetDiagonals(cellUv, flip, w);
    } else if (uTileStyle < 2.5) {
        d = truchetQuarterCircles(cellUv, flip, w);
    } else if (uTileStyle < 3.5) {
        d = truchetDoubleArcs(cellUv, flip, w);
    } else {
        d = truchetWeave(cellUv, flip, w, depth);
    }
    
    // Anti-aliasing: smooth the edge
    float aa = uAntiAlias / uScale;
    float mask = 1.0 - smoothstep(-aa, aa, d);
    
    // Color based on multiple factors
    // 1. Position along the continuous path
    float pathColor = length(uv) + time * uColorSpeed;
    
    // 2. Cell-based color variation
    float cellColor = hash21(cellId + vec2(127.1, 311.7));
    
    // 3. Distance from arc center for gradient effect
    vec2 nearestCorner = flip > 0.5 ? 
        (length(cellUv) < length(cellUv - vec2(1.0, 1.0)) ? vec2(0.0) : vec2(1.0)) :
        (length(cellUv - vec2(1.0, 0.0)) < length(cellUv - vec2(0.0, 1.0)) ? vec2(1.0, 0.0) : vec2(0.0, 1.0));
    float arcProgress = atan(cellUv.y - nearestCorner.y, cellUv.x - nearestCorner.x) / PI;
    
    // Combine color sources
    float colorIndex = pathColor * 0.3 + cellColor * 0.3 + arcProgress * 0.4;
    vec3 lineColor = palette(colorIndex);
    
    // Apply depth shading for weave style
    if (uTileStyle > 3.5) {
        lineColor *= 0.7 + 0.3 * depth;
    }
    
    // Add subtle highlight on the line edges
    float edgeHighlight = smoothstep(w * 0.8, w * 0.3, abs(d));
    lineColor += vec3(0.15) * edgeHighlight;
    
    // Final color composition
    vec3 color = mix(uBackgroundColor, lineColor, mask);
    
    // Subtle vignette
    float vignette = 1.0 - 0.3 * length(uv - 0.5);
    color *= vignette;
    
    gl_FragColor = vec4(color, 1.0);
}
