varying vec2 vUv;

uniform float uTime;
uniform float uShapeType;
uniform float uBooleanOp;
uniform float uSmoothness;
uniform float uMouseLook;
uniform float uAOStrength;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uBackgroundColor;
uniform float uAnimSpeed;

// Mouse uniforms (auto-injected)
uniform vec2 uMouse;
uniform vec2 uMouseVelocity;
uniform float uMouseDown;

#define MAX_STEPS 100
#define MAX_DIST 100.0
#define SURF_DIST 0.001
#define PI 3.14159265

// ============================================
// SDF Primitives
// ============================================

float sdSphere(vec3 p, float r) {
    return length(p) - r;
}

float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float sdTorus(vec3 p, vec2 t) {
    vec2 q = vec2(length(p.xz) - t.x, p.y);
    return length(q) - t.y;
}

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

// ============================================
// Boolean Operations
// ============================================

float opUnion(float d1, float d2) {
    return min(d1, d2);
}

float opSubtract(float d1, float d2) {
    return max(d1, -d2);
}

float opIntersect(float d1, float d2) {
    return max(d1, d2);
}

float opSmoothUnion(float d1, float d2, float k) {
    float h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
    return mix(d2, d1, h) - k * h * (1.0 - h);
}

float opSmoothSubtract(float d1, float d2, float k) {
    float h = clamp(0.5 - 0.5 * (d2 + d1) / k, 0.0, 1.0);
    return mix(d1, -d2, h) + k * h * (1.0 - h);
}

float opSmoothIntersect(float d1, float d2, float k) {
    float h = clamp(0.5 - 0.5 * (d2 - d1) / k, 0.0, 1.0);
    return mix(d2, d1, h) + k * h * (1.0 - h);
}

// ============================================
// Transformations
// ============================================

vec3 rotateX(vec3 p, float a) {
    float c = cos(a), s = sin(a);
    return vec3(p.x, c * p.y - s * p.z, s * p.y + c * p.z);
}

vec3 rotateY(vec3 p, float a) {
    float c = cos(a), s = sin(a);
    return vec3(c * p.x + s * p.z, p.y, -s * p.x + c * p.z);
}

vec3 rotateZ(vec3 p, float a) {
    float c = cos(a), s = sin(a);
    return vec3(c * p.x - s * p.y, s * p.x + c * p.y, p.z);
}

// ============================================
// Scene Definition
// ============================================

float getShape(vec3 p, float shapeType) {
    float time = uTime * uAnimSpeed;

    // Animate position slightly
    vec3 animP = p;
    animP.y += sin(time * 0.5) * 0.1;

    if (shapeType < 0.5) {
        // Sphere
        return sdSphere(animP, 0.8);
    } else if (shapeType < 1.5) {
        // Box
        vec3 boxP = rotateY(rotateX(animP, time * 0.3), time * 0.5);
        return sdBox(boxP, vec3(0.6));
    } else if (shapeType < 2.5) {
        // Torus
        vec3 torusP = rotateX(animP, PI * 0.5 + sin(time * 0.4) * 0.3);
        return sdTorus(torusP, vec2(0.6, 0.25));
    } else {
        // Octahedron
        vec3 octP = rotateY(rotateZ(animP, time * 0.4), time * 0.3);
        return sdOctahedron(octP, 0.9);
    }
}

float map(vec3 p) {
    float time = uTime * uAnimSpeed;

    // Get primary shape
    float d1 = getShape(p, uShapeType);

    // Secondary shape for boolean operations
    vec3 p2 = p - vec3(sin(time * 0.5) * 0.3, cos(time * 0.7) * 0.2, sin(time * 0.3) * 0.3);
    float d2 = sdSphere(p2, 0.5);

    // Apply boolean operation
    float k = uSmoothness;
    float d;

    if (uBooleanOp < 0.5) {
        // Union
        d = k > 0.01 ? opSmoothUnion(d1, d2, k) : opUnion(d1, d2);
    } else if (uBooleanOp < 1.5) {
        // Subtract
        d = k > 0.01 ? opSmoothSubtract(d1, d2, k) : opSubtract(d1, d2);
    } else {
        // Intersect
        d = k > 0.01 ? opSmoothIntersect(d1, d2, k) : opIntersect(d1, d2);
    }

    // Floor plane
    float floorDist = p.y + 1.2;
    d = min(d, floorDist);

    return d;
}

// ============================================
// Ray Marching
// ============================================

float rayMarch(vec3 ro, vec3 rd) {
    float d = 0.0;

    for (int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + rd * d;
        float ds = map(p);
        d += ds;
        if (d > MAX_DIST || ds < SURF_DIST) break;
    }

    return d;
}

vec3 getNormal(vec3 p) {
    float d = map(p);
    vec2 e = vec2(0.001, 0.0);
    vec3 n = d - vec3(
        map(p - e.xyy),
        map(p - e.yxy),
        map(p - e.yyx)
    );
    return normalize(n);
}

float calcAO(vec3 p, vec3 n) {
    float occ = 0.0;
    float sca = 1.0;
    for (int i = 0; i < 5; i++) {
        float h = 0.01 + 0.12 * float(i) / 4.0;
        float d = map(p + h * n);
        occ += (h - d) * sca;
        sca *= 0.95;
    }
    return clamp(1.0 - 3.0 * occ * uAOStrength, 0.0, 1.0);
}

float softShadow(vec3 ro, vec3 rd, float mint, float maxt, float k) {
    float res = 1.0;
    float t = mint;
    for (int i = 0; i < 32; i++) {
        float h = map(ro + rd * t);
        res = min(res, k * h / t);
        t += clamp(h, 0.02, 0.1);
        if (h < 0.001 || t > maxt) break;
    }
    return clamp(res, 0.0, 1.0);
}

// ============================================
// Lighting
// ============================================

vec3 getLight(vec3 p, vec3 rd) {
    // Light position
    vec3 lightPos = vec3(2.0, 4.0, 3.0);
    vec3 lightDir = normalize(lightPos - p);
    vec3 normal = getNormal(p);

    // Basic diffuse
    float diff = clamp(dot(normal, lightDir), 0.0, 1.0);

    // Specular
    vec3 viewDir = -rd;
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(clamp(dot(viewDir, reflectDir), 0.0, 1.0), 32.0);

    // Ambient occlusion
    float ao = calcAO(p, normal);

    // Soft shadows
    float shadow = softShadow(p + normal * 0.02, lightDir, 0.02, 5.0, 16.0);

    // Fresnel
    float fresnel = pow(1.0 - clamp(dot(viewDir, normal), 0.0, 1.0), 3.0);

    // Mix colors based on normal
    vec3 baseColor = mix(uColor1, uColor2, normal.y * 0.5 + 0.5);

    // Combine lighting
    vec3 ambient = baseColor * 0.15;
    vec3 diffuseColor = baseColor * diff * shadow;
    vec3 specularColor = vec3(1.0) * spec * shadow * 0.5;
    vec3 fresnelColor = mix(uColor1, uColor2, 0.5) * fresnel * 0.3;

    return (ambient + diffuseColor + specularColor + fresnelColor) * ao;
}

// ============================================
// Main
// ============================================

void main() {
    vec2 uv = vUv - 0.5;
    uv.x *= 1.5; // Aspect ratio adjustment

    // Camera setup
    vec3 ro = vec3(0.0, 0.5, 3.5);

    // Mouse look rotation
    if (uMouseLook > 0.5) {
        vec2 mouseOffset = (uMouse - 0.5) * 2.0;
        ro = rotateY(ro, mouseOffset.x * PI * 0.5);
        ro.y += mouseOffset.y * 1.5;
    }

    vec3 lookAt = vec3(0.0, 0.0, 0.0);
    vec3 forward = normalize(lookAt - ro);
    vec3 right = normalize(cross(vec3(0.0, 1.0, 0.0), forward));
    vec3 up = cross(forward, right);

    vec3 rd = normalize(forward + uv.x * right + uv.y * up);

    // Ray march
    float d = rayMarch(ro, rd);

    vec3 col;

    if (d < MAX_DIST) {
        vec3 p = ro + rd * d;
        col = getLight(p, rd);

        // Check if we hit the floor
        if (p.y < -1.15) {
            // Floor with checkerboard pattern
            vec2 floorUv = p.xz;
            float checker = mod(floor(floorUv.x * 2.0) + floor(floorUv.y * 2.0), 2.0);
            col = mix(uBackgroundColor * 0.3, uBackgroundColor * 0.5, checker);

            // Add reflection hint
            float ao = calcAO(p, vec3(0.0, 1.0, 0.0));
            col *= ao;
        }

        // Fog
        float fog = exp(-d * 0.1);
        col = mix(uBackgroundColor, col, fog);
    } else {
        // Background gradient
        col = mix(uBackgroundColor, uBackgroundColor * 1.2, uv.y + 0.5);
    }

    // Tone mapping
    col = col / (col + vec3(1.0));

    // Gamma correction
    col = pow(col, vec3(0.4545));

    gl_FragColor = vec4(col, 1.0);
}
