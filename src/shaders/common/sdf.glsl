// ============================================
// Shared SDF Functions for Shader Playground
// ============================================

// --------------------------------------------
// 2D SDF Primitives
// --------------------------------------------

// Circle
float sdCircle(vec2 p, float r) {
    return length(p) - r;
}

// Box
float sdBox2D(vec2 p, vec2 b) {
    vec2 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

// Rounded Box
float sdRoundedBox2D(vec2 p, vec2 b, float r) {
    vec2 d = abs(p) - b + r;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0) - r;
}

// Segment / Line
float sdSegment2D(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}

// Triangle
float sdTriangle2D(vec2 p, vec2 p0, vec2 p1, vec2 p2) {
    vec2 e0 = p1 - p0, e1 = p2 - p1, e2 = p0 - p2;
    vec2 v0 = p - p0, v1 = p - p1, v2 = p - p2;
    vec2 pq0 = v0 - e0 * clamp(dot(v0, e0) / dot(e0, e0), 0.0, 1.0);
    vec2 pq1 = v1 - e1 * clamp(dot(v1, e1) / dot(e1, e1), 0.0, 1.0);
    vec2 pq2 = v2 - e2 * clamp(dot(v2, e2) / dot(e2, e2), 0.0, 1.0);
    float s = sign(e0.x * e2.y - e0.y * e2.x);
    vec2 d = min(min(vec2(dot(pq0, pq0), s * (v0.x * e0.y - v0.y * e0.x)),
                     vec2(dot(pq1, pq1), s * (v1.x * e1.y - v1.y * e1.x))),
                 vec2(dot(pq2, pq2), s * (v2.x * e2.y - v2.y * e2.x)));
    return -sqrt(d.x) * sign(d.y);
}

// Equilateral Triangle
float sdEquilateralTriangle(vec2 p, float r) {
    const float k = sqrt(3.0);
    p.x = abs(p.x) - r;
    p.y = p.y + r / k;
    if (p.x + k * p.y > 0.0) p = vec2(p.x - k * p.y, -k * p.x - p.y) / 2.0;
    p.x -= clamp(p.x, -2.0 * r, 0.0);
    return -length(p) * sign(p.y);
}

// Ring
float sdRing(vec2 p, float r, float thickness) {
    return abs(length(p) - r) - thickness;
}

// Arc
float sdArc(vec2 p, vec2 sc, float ra, float rb) {
    p.x = abs(p.x);
    return ((sc.y * p.x > sc.x * p.y) ? length(p - sc * ra) : abs(length(p) - ra)) - rb;
}

// Hexagon
float sdHexagon(vec2 p, float r) {
    const vec3 k = vec3(-0.866025404, 0.5, 0.577350269);
    p = abs(p);
    p -= 2.0 * min(dot(k.xy, p), 0.0) * k.xy;
    p -= vec2(clamp(p.x, -k.z * r, k.z * r), r);
    return length(p) * sign(p.y);
}

// Star (5-pointed)
float sdStar5(vec2 p, float r, float rf) {
    const vec2 k1 = vec2(0.809016994, -0.587785252);
    const vec2 k2 = vec2(-k1.x, k1.y);
    p.x = abs(p.x);
    p -= 2.0 * max(dot(k1, p), 0.0) * k1;
    p -= 2.0 * max(dot(k2, p), 0.0) * k2;
    p.x = abs(p.x);
    p.y -= r;
    vec2 ba = rf * vec2(-k1.y, k1.x) - vec2(0, 1);
    float h = clamp(dot(p, ba) / dot(ba, ba), 0.0, r);
    return length(p - ba * h) * sign(p.y * ba.x - p.x * ba.y);
}

// N-pointed Star
float sdStar(vec2 p, float r, int n, float m) {
    float an = 3.141593 / float(n);
    float en = 3.141593 / m;
    vec2 acs = vec2(cos(an), sin(an));
    vec2 ecs = vec2(cos(en), sin(en));

    float bn = mod(atan(p.x, p.y), 2.0 * an) - an;
    p = length(p) * vec2(cos(bn), abs(sin(bn)));
    p -= r * acs;
    p += ecs * clamp(-dot(p, ecs), 0.0, r * acs.y / ecs.y);
    return length(p) * sign(p.x);
}

// Heart
float sdHeart(vec2 p) {
    p.x = abs(p.x);
    if (p.y + p.x > 1.0)
        return sqrt(dot(p - vec2(0.25, 0.75), p - vec2(0.25, 0.75))) - sqrt(2.0) / 4.0;
    return sqrt(min(dot(p - vec2(0.00, 1.00), p - vec2(0.00, 1.00)),
                    dot(p - 0.5 * max(p.x + p.y, 0.0), p - 0.5 * max(p.x + p.y, 0.0)))) * sign(p.x - p.y);
}

// Cross
float sdCross2D(vec2 p, vec2 b, float r) {
    p = abs(p);
    p = (p.y > p.x) ? p.yx : p.xy;
    vec2 q = p - b;
    float k = max(q.y, q.x);
    vec2 w = (k > 0.0) ? q : vec2(b.y - p.x, -k);
    return sign(k) * length(max(w, 0.0)) + r;
}

// --------------------------------------------
// 3D SDF Primitives
// --------------------------------------------

// Sphere
float sdSphere(vec3 p, float r) {
    return length(p) - r;
}

// Box
float sdBox(vec3 p, vec3 b) {
    vec3 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0);
}

// Rounded Box
float sdRoundBox(vec3 p, vec3 b, float r) {
    vec3 q = abs(p) - b + r;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - r;
}

// Torus
float sdTorus(vec3 p, vec2 t) {
    vec2 q = vec2(length(p.xz) - t.x, p.y);
    return length(q) - t.y;
}

// Capped Torus
float sdCappedTorus(vec3 p, vec2 sc, float ra, float rb) {
    p.x = abs(p.x);
    float k = (sc.y * p.x > sc.x * p.y) ? dot(p.xy, sc) : length(p.xy);
    return sqrt(dot(p, p) + ra * ra - 2.0 * ra * k) - rb;
}

// Cylinder
float sdCylinder(vec3 p, float h, float r) {
    vec2 d = abs(vec2(length(p.xz), p.y)) - vec2(r, h);
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

// Capsule / Line Segment
float sdCapsule(vec3 p, vec3 a, vec3 b, float r) {
    vec3 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h) - r;
}

// Cone
float sdCone(vec3 p, vec2 c, float h) {
    vec2 q = h * vec2(c.x / c.y, -1.0);
    vec2 w = vec2(length(p.xz), p.y);
    vec2 a = w - q * clamp(dot(w, q) / dot(q, q), 0.0, 1.0);
    vec2 b = w - q * vec2(clamp(w.x / q.x, 0.0, 1.0), 1.0);
    float k = sign(q.y);
    float d = min(dot(a, a), dot(b, b));
    float s = max(k * (w.x * q.y - w.y * q.x), k * (w.y - q.y));
    return sqrt(d) * sign(s);
}

// Plane
float sdPlane(vec3 p, vec3 n, float h) {
    return dot(p, n) + h;
}

// Octahedron
float sdOctahedron(vec3 p, float s) {
    p = abs(p);
    float m = p.x + p.y + p.z - s;
    vec3 q;
    if (3.0 * p.x < m) q = p.xyz;
    else if (3.0 * p.y < m) q = p.yzx;
    else if (3.0 * p.z < m) q = p.zxy;
    else return m * 0.57735027;
    float k = clamp(0.5 * (q.z - q.y + s), 0.0, s);
    return length(vec3(q.x, q.y - s + k, q.z - k));
}

// Pyramid
float sdPyramid(vec3 p, float h) {
    float m2 = h * h + 0.25;

    p.xz = abs(p.xz);
    p.xz = (p.z > p.x) ? p.zx : p.xz;
    p.xz -= 0.5;

    vec3 q = vec3(p.z, h * p.y - 0.5 * p.x, h * p.x + 0.5 * p.y);

    float s = max(-q.x, 0.0);
    float t = clamp((q.y - 0.5 * p.z) / (m2 + 0.25), 0.0, 1.0);

    float a = m2 * (q.x + s) * (q.x + s) + q.y * q.y;
    float b = m2 * (q.x + 0.5 * t) * (q.x + 0.5 * t) + (q.y - m2 * t) * (q.y - m2 * t);

    float d2 = min(q.y, -q.x * m2 - q.y * 0.5) > 0.0 ? 0.0 : min(a, b);

    return sqrt((d2 + q.z * q.z) / m2) * sign(max(q.z, -p.y));
}

// --------------------------------------------
// Boolean Operations
// --------------------------------------------

// Union (min of two distances)
float opUnion(float d1, float d2) {
    return min(d1, d2);
}

// Subtraction (cut d2 from d1)
float opSubtract(float d1, float d2) {
    return max(d1, -d2);
}

// Intersection
float opIntersect(float d1, float d2) {
    return max(d1, d2);
}

// Smooth Union
float opSmoothUnion(float d1, float d2, float k) {
    float h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
    return mix(d2, d1, h) - k * h * (1.0 - h);
}

// Smooth Subtraction
float opSmoothSubtract(float d1, float d2, float k) {
    float h = clamp(0.5 - 0.5 * (d2 + d1) / k, 0.0, 1.0);
    return mix(d1, -d2, h) + k * h * (1.0 - h);
}

// Smooth Intersection
float opSmoothIntersect(float d1, float d2, float k) {
    float h = clamp(0.5 - 0.5 * (d2 - d1) / k, 0.0, 1.0);
    return mix(d2, d1, h) + k * h * (1.0 - h);
}

// --------------------------------------------
// Transformations
// --------------------------------------------

// Translate (shift point before SDF evaluation)
vec3 opTranslate(vec3 p, vec3 offset) {
    return p - offset;
}

vec2 opTranslate2D(vec2 p, vec2 offset) {
    return p - offset;
}

// Rotate around X axis
vec3 opRotateX(vec3 p, float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return vec3(p.x, c * p.y - s * p.z, s * p.y + c * p.z);
}

// Rotate around Y axis
vec3 opRotateY(vec3 p, float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return vec3(c * p.x + s * p.z, p.y, -s * p.x + c * p.z);
}

// Rotate around Z axis
vec3 opRotateZ(vec3 p, float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return vec3(c * p.x - s * p.y, s * p.x + c * p.y, p.z);
}

// Rotate 2D
vec2 opRotate2D(vec2 p, float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return vec2(c * p.x - s * p.y, s * p.x + c * p.y);
}

// Scale (uniform)
vec3 opScale(vec3 p, float s) {
    return p / s;
}

// Scale (non-uniform)
vec3 opScaleNonUniform(vec3 p, vec3 s) {
    return p / s;
}

// --------------------------------------------
// Repetition
// --------------------------------------------

// Infinite repetition
vec3 opRepeat(vec3 p, vec3 c) {
    return mod(p + 0.5 * c, c) - 0.5 * c;
}

vec2 opRepeat2D(vec2 p, vec2 c) {
    return mod(p + 0.5 * c, c) - 0.5 * c;
}

// Limited repetition
vec3 opRepeatLimited(vec3 p, float c, vec3 l) {
    return p - c * clamp(floor(p / c + 0.5), -l, l);
}

vec2 opRepeatLimited2D(vec2 p, float c, vec2 l) {
    return p - c * clamp(floor(p / c + 0.5), -l, l);
}

// Polar repetition (for 2D, rotates around origin)
vec2 opRepeatPolar(vec2 p, float repetitions) {
    float angle = 2.0 * 3.14159265 / repetitions;
    float a = atan(p.y, p.x) + angle / 2.0;
    float r = length(p);
    a = mod(a, angle) - angle / 2.0;
    return vec2(cos(a), sin(a)) * r;
}

// --------------------------------------------
// Distortion / Modification
// --------------------------------------------

// Round edges
float opRound(float d, float r) {
    return d - r;
}

// Make shell (hollow)
float opOnion(float d, float thickness) {
    return abs(d) - thickness;
}

// Twist (for 3D shapes)
vec3 opTwist(vec3 p, float k) {
    float c = cos(k * p.y);
    float s = sin(k * p.y);
    mat2 m = mat2(c, -s, s, c);
    return vec3(m * p.xz, p.y);
}

// Bend (for 3D shapes)
vec3 opBend(vec3 p, float k) {
    float c = cos(k * p.x);
    float s = sin(k * p.x);
    mat2 m = mat2(c, -s, s, c);
    return vec3(p.x, m * p.yz);
}

// --------------------------------------------
// Utility Functions
// --------------------------------------------

// Get normal from SDF using central differences
// Note: Call your SDF function 'map(p)' and use this:
// vec3 normal = calcNormal(p);

// Example usage (uncomment when you have a 'map' function defined):
// vec3 calcNormal(vec3 p) {
//     const float h = 0.0001;
//     const vec2 k = vec2(1, -1);
//     return normalize(k.xyy * map(p + k.xyy * h) +
//                      k.yyx * map(p + k.yyx * h) +
//                      k.yxy * map(p + k.yxy * h) +
//                      k.xxx * map(p + k.xxx * h));
// }

// Soft shadow (for ray marching)
// ro = ray origin, rd = ray direction, mint = min t, maxt = max t, k = softness
// Example usage (uncomment when you have a 'map' function defined):
// float softShadow(vec3 ro, vec3 rd, float mint, float maxt, float k) {
//     float res = 1.0;
//     float t = mint;
//     for (int i = 0; i < 64; i++) {
//         float h = map(ro + rd * t);
//         res = min(res, k * h / t);
//         t += clamp(h, 0.02, 0.10);
//         if (h < 0.001 || t > maxt) break;
//     }
//     return clamp(res, 0.0, 1.0);
// }

// Ambient occlusion (for ray marching)
// p = position, n = normal
// Example usage (uncomment when you have a 'map' function defined):
// float calcAO(vec3 p, vec3 n) {
//     float occ = 0.0;
//     float sca = 1.0;
//     for (int i = 0; i < 5; i++) {
//         float h = 0.01 + 0.12 * float(i) / 4.0;
//         float d = map(p + h * n);
//         occ += (h - d) * sca;
//         sca *= 0.95;
//     }
//     return clamp(1.0 - 3.0 * occ, 0.0, 1.0);
// }
