// ============================================
// Shared Noise Functions for Shader Playground
// ============================================

// --------------------------------------------
// Hash functions for pseudo-random numbers
// --------------------------------------------

float hash21(vec2 p) {
    p = fract(p * vec2(234.34, 435.345));
    p += dot(p, p + 34.23);
    return fract(p.x * p.y);
}

vec2 hash22(vec2 p) {
    vec3 a = fract(p.xyx * vec3(234.34, 435.345, 654.165));
    a += dot(a, a + 34.23);
    return fract(vec2(a.x * a.y, a.y * a.z));
}

vec3 hash33(vec3 p) {
    p = fract(p * vec3(443.897, 441.423, 437.195));
    p += dot(p, p.yzx + 19.19);
    return fract(vec3(p.x * p.y, p.y * p.z, p.z * p.x));
}

// --------------------------------------------
// Perlin Noise (2D)
// --------------------------------------------

vec2 fade2(vec2 t) {
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

float perlinNoise2D(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    float a = hash21(i);
    float b = hash21(i + vec2(1.0, 0.0));
    float c = hash21(i + vec2(0.0, 1.0));
    float d = hash21(i + vec2(1.0, 1.0));

    vec2 u = fade2(f);

    return mix(
        mix(a, b, u.x),
        mix(c, d, u.x),
        u.y
    );
}

// --------------------------------------------
// Perlin Noise (3D)
// --------------------------------------------

vec3 fade3(vec3 t) {
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

float perlinNoise3D(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);

    float n000 = hash21(i.xy + i.z * 43.0);
    float n100 = hash21(i.xy + vec2(1.0, 0.0) + i.z * 43.0);
    float n010 = hash21(i.xy + vec2(0.0, 1.0) + i.z * 43.0);
    float n110 = hash21(i.xy + vec2(1.0, 1.0) + i.z * 43.0);
    float n001 = hash21(i.xy + (i.z + 1.0) * 43.0);
    float n101 = hash21(i.xy + vec2(1.0, 0.0) + (i.z + 1.0) * 43.0);
    float n011 = hash21(i.xy + vec2(0.0, 1.0) + (i.z + 1.0) * 43.0);
    float n111 = hash21(i.xy + vec2(1.0, 1.0) + (i.z + 1.0) * 43.0);

    vec3 u = fade3(f);

    return mix(
        mix(mix(n000, n100, u.x), mix(n010, n110, u.x), u.y),
        mix(mix(n001, n101, u.x), mix(n011, n111, u.x), u.y),
        u.z
    );
}

// --------------------------------------------
// Simplex Noise (2D)
// --------------------------------------------

vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec2 mod289_2(vec2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec3 permute(vec3 x) { return mod289(((x * 34.0) + 1.0) * x); }

float simplexNoise2D(vec2 v) {
    const vec4 C = vec4(0.211324865405187, 0.366025403784439,
                        -0.577350269189626, 0.024390243902439);

    vec2 i = floor(v + dot(v, C.yy));
    vec2 x0 = v - i + dot(i, C.xx);

    vec2 i1;
    i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;

    i = mod289_2(i);
    vec3 p = permute(permute(i.y + vec3(0.0, i1.y, 1.0))
                   + i.x + vec3(0.0, i1.x, 1.0));

    vec3 m = max(0.5 - vec3(dot(x0, x0), dot(x12.xy, x12.xy),
                            dot(x12.zw, x12.zw)), 0.0);
    m = m * m;
    m = m * m;

    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;

    m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);

    vec3 g;
    g.x = a0.x * x0.x + h.x * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}

// --------------------------------------------
// Simplex Noise (3D)
// --------------------------------------------

vec4 mod289_4(vec4 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec4 permute4(vec4 x) { return mod289_4(((x * 34.0) + 1.0) * x); }
vec4 taylorInvSqrt(vec4 r) { return 1.79284291400159 - 0.85373472095314 * r; }

float simplexNoise3D(vec3 v) {
    const vec2 C = vec2(1.0 / 6.0, 1.0 / 3.0);
    const vec4 D = vec4(0.0, 0.5, 1.0, 2.0);

    vec3 i = floor(v + dot(v, C.yyy));
    vec3 x0 = v - i + dot(i, C.xxx);

    vec3 g = step(x0.yzx, x0.xyz);
    vec3 l = 1.0 - g;
    vec3 i1 = min(g.xyz, l.zxy);
    vec3 i2 = max(g.xyz, l.zxy);

    vec3 x1 = x0 - i1 + C.xxx;
    vec3 x2 = x0 - i2 + C.yyy;
    vec3 x3 = x0 - D.yyy;

    i = mod289(i);
    vec4 p = permute4(permute4(permute4(
        i.z + vec4(0.0, i1.z, i2.z, 1.0))
      + i.y + vec4(0.0, i1.y, i2.y, 1.0))
      + i.x + vec4(0.0, i1.x, i2.x, 1.0));

    float n_ = 0.142857142857;
    vec3 ns = n_ * D.wyz - D.xzx;

    vec4 j = p - 49.0 * floor(p * ns.z * ns.z);

    vec4 x_ = floor(j * ns.z);
    vec4 y_ = floor(j - 7.0 * x_);

    vec4 x = x_ * ns.x + ns.yyyy;
    vec4 y = y_ * ns.x + ns.yyyy;
    vec4 h = 1.0 - abs(x) - abs(y);

    vec4 b0 = vec4(x.xy, y.xy);
    vec4 b1 = vec4(x.zw, y.zw);

    vec4 s0 = floor(b0) * 2.0 + 1.0;
    vec4 s1 = floor(b1) * 2.0 + 1.0;
    vec4 sh = -step(h, vec4(0.0));

    vec4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
    vec4 a1 = b1.xzyw + s1.xzyw * sh.zzww;

    vec3 p0 = vec3(a0.xy, h.x);
    vec3 p1 = vec3(a0.zw, h.y);
    vec3 p2 = vec3(a1.xy, h.z);
    vec3 p3 = vec3(a1.zw, h.w);

    vec4 norm = taylorInvSqrt(vec4(dot(p0, p0), dot(p1, p1), dot(p2, p2), dot(p3, p3)));
    p0 *= norm.x;
    p1 *= norm.y;
    p2 *= norm.z;
    p3 *= norm.w;

    vec4 m = max(0.6 - vec4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
    m = m * m;
    return 42.0 * dot(m * m, vec4(dot(p0, x0), dot(p1, x1), dot(p2, x2), dot(p3, x3)));
}

// --------------------------------------------
// Fractal Brownian Motion (FBM)
// --------------------------------------------

float fbm2D(vec2 p, int octaves, float lacunarity, float gain) {
    float sum = 0.0;
    float amplitude = 1.0;
    float frequency = 1.0;
    float maxValue = 0.0;

    for (int i = 0; i < 8; i++) {
        if (i >= octaves) break;
        sum += amplitude * perlinNoise2D(p * frequency);
        maxValue += amplitude;
        amplitude *= gain;
        frequency *= lacunarity;
    }

    return sum / maxValue;
}

float fbm3D(vec3 p, int octaves, float lacunarity, float gain) {
    float sum = 0.0;
    float amplitude = 1.0;
    float frequency = 1.0;
    float maxValue = 0.0;

    for (int i = 0; i < 8; i++) {
        if (i >= octaves) break;
        sum += amplitude * perlinNoise3D(p * frequency);
        maxValue += amplitude;
        amplitude *= gain;
        frequency *= lacunarity;
    }

    return sum / maxValue;
}

// Simplex-based FBM for smoother results
float fbmSimplex2D(vec2 p, int octaves, float lacunarity, float gain) {
    float sum = 0.0;
    float amplitude = 1.0;
    float frequency = 1.0;
    float maxValue = 0.0;

    for (int i = 0; i < 8; i++) {
        if (i >= octaves) break;
        sum += amplitude * simplexNoise2D(p * frequency);
        maxValue += amplitude;
        amplitude *= gain;
        frequency *= lacunarity;
    }

    return sum / maxValue;
}

// --------------------------------------------
// Curl Noise (2D) - for flow fields
// --------------------------------------------

vec2 curlNoise2D(vec2 p, float epsilon) {
    float n1 = simplexNoise2D(p + vec2(0.0, epsilon));
    float n2 = simplexNoise2D(p - vec2(0.0, epsilon));
    float n3 = simplexNoise2D(p + vec2(epsilon, 0.0));
    float n4 = simplexNoise2D(p - vec2(epsilon, 0.0));

    float dndx = (n3 - n4) / (2.0 * epsilon);
    float dndy = (n1 - n2) / (2.0 * epsilon);

    // Return perpendicular gradient (curl in 2D)
    return vec2(dndy, -dndx);
}

// --------------------------------------------
// Curl Noise (3D) - for 3D flow fields
// --------------------------------------------

vec3 curlNoise3D(vec3 p, float epsilon) {
    float n1 = simplexNoise3D(p + vec3(epsilon, 0.0, 0.0));
    float n2 = simplexNoise3D(p - vec3(epsilon, 0.0, 0.0));
    float n3 = simplexNoise3D(p + vec3(0.0, epsilon, 0.0));
    float n4 = simplexNoise3D(p - vec3(0.0, epsilon, 0.0));
    float n5 = simplexNoise3D(p + vec3(0.0, 0.0, epsilon));
    float n6 = simplexNoise3D(p - vec3(0.0, 0.0, epsilon));

    float dndx = (n1 - n2) / (2.0 * epsilon);
    float dndy = (n3 - n4) / (2.0 * epsilon);
    float dndz = (n5 - n6) / (2.0 * epsilon);

    // curl = nabla x F
    return vec3(dndy - dndz, dndz - dndx, dndx - dndy);
}

// --------------------------------------------
// Voronoi / Worley Noise
// --------------------------------------------

float voronoiNoise(vec2 p) {
    vec2 n = floor(p);
    vec2 f = fract(p);

    float minDist = 1.0;

    for (int j = -1; j <= 1; j++) {
        for (int i = -1; i <= 1; i++) {
            vec2 neighbor = vec2(float(i), float(j));
            vec2 point = hash22(n + neighbor);
            vec2 diff = neighbor + point - f;
            float dist = length(diff);
            minDist = min(minDist, dist);
        }
    }

    return minDist;
}

// Voronoi with edge detection
vec2 voronoiNoise2(vec2 p) {
    vec2 n = floor(p);
    vec2 f = fract(p);

    float minDist = 1.0;
    float secondMin = 1.0;

    for (int j = -1; j <= 1; j++) {
        for (int i = -1; i <= 1; i++) {
            vec2 neighbor = vec2(float(i), float(j));
            vec2 point = hash22(n + neighbor);
            vec2 diff = neighbor + point - f;
            float dist = length(diff);

            if (dist < minDist) {
                secondMin = minDist;
                minDist = dist;
            } else if (dist < secondMin) {
                secondMin = dist;
            }
        }
    }

    // x = distance to nearest, y = edge (difference between nearest and second nearest)
    return vec2(minDist, secondMin - minDist);
}

// --------------------------------------------
// Domain Warping
// --------------------------------------------

vec2 domainWarp2D(vec2 p, float warpStrength, float warpScale) {
    vec2 warp = vec2(
        simplexNoise2D(p * warpScale),
        simplexNoise2D(p * warpScale + vec2(5.2, 1.3))
    );
    return p + warp * warpStrength;
}

vec3 domainWarp3D(vec3 p, float warpStrength, float warpScale) {
    vec3 warp = vec3(
        simplexNoise3D(p * warpScale),
        simplexNoise3D(p * warpScale + vec3(5.2, 1.3, 9.7)),
        simplexNoise3D(p * warpScale + vec3(2.8, 7.1, 4.2))
    );
    return p + warp * warpStrength;
}
