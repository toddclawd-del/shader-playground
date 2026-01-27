varying vec2 vUv;

uniform float uTime;
uniform float uBlobCount;
uniform float uBlobSize;
uniform float uSmoothness;
uniform float uMouseInfluence;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform float uAnimSpeed;
uniform float uDistortion;
uniform float uMetallic;

// Mouse uniforms (auto-injected)
uniform vec2 uMouse;
uniform vec2 uMouseVelocity;
uniform float uMouseDown;

// Smooth minimum for metaball blending
float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

// Simple hash for pseudo-random
float hash(float n) {
    return fract(sin(n) * 43758.5453);
}

// Circle SDF
float sdCircle(vec2 p, float r) {
    return length(p) - r;
}

void main() {
    vec2 uv = vUv;
    vec2 centeredUv = uv - 0.5;

    // Blob positions with animation
    float time = uTime * uAnimSpeed;
    int blobCount = int(uBlobCount);

    // Start with a large distance
    float d = 1000.0;

    // Mouse attraction point
    vec2 mousePos = uMouse - 0.5;

    // Add blobs
    for (int i = 0; i < 8; i++) {
        if (i >= blobCount) break;

        // Create unique movement for each blob
        float fi = float(i);
        float angle = fi * 2.39996 + time * 0.3; // Golden angle offset + rotation
        float radius = 0.15 + 0.1 * sin(time * 0.5 + fi);

        // Base position
        vec2 blobPos = vec2(
            cos(angle + fi * 0.5) * radius,
            sin(angle * 0.7 + fi) * radius
        );

        // Add organic wobble
        blobPos.x += 0.05 * sin(time * 0.8 + fi * 2.1);
        blobPos.y += 0.05 * cos(time * 0.9 + fi * 1.7);

        // Mouse attraction
        vec2 toMouse = mousePos - blobPos;
        float mouseDist = length(toMouse);
        float attraction = uMouseInfluence * (1.0 - smoothstep(0.0, 0.5, mouseDist));

        // Stronger attraction when mouse is down
        if (uMouseDown > 0.5) {
            attraction *= 1.5;
        }

        // Add velocity influence
        blobPos += uMouseVelocity * 0.02 * uMouseInfluence;

        // Apply attraction
        blobPos = mix(blobPos, mousePos, attraction * 0.5);

        // Individual blob size variation
        float blobR = uBlobSize * (0.8 + 0.4 * hash(fi));

        // Distance to this blob
        float blobDist = sdCircle(centeredUv - blobPos, blobR);

        // Smooth union with metaball effect
        d = smin(d, blobDist, uSmoothness);
    }

    // Add distortion based on noise
    float distortNoise = sin(centeredUv.x * 20.0 + time) * cos(centeredUv.y * 20.0 + time * 0.8);
    d += distortNoise * uDistortion * 0.01;

    // Create color based on distance
    float inside = 1.0 - smoothstep(0.0, 0.02, d);

    // Gradient based on distance from center of mass
    float gradient = smoothstep(-0.2, 0.2, d);

    // Edge highlight for metallic effect
    float edge = 1.0 - smoothstep(0.0, 0.05, abs(d));
    edge *= uMetallic;

    // Mix colors
    vec3 liquidColor = mix(uColor1, uColor2, gradient);

    // Add edge highlight
    liquidColor += vec3(edge * 0.5);

    // Internal shading - darker in the middle
    float innerShade = smoothstep(-0.15, 0.0, d);
    liquidColor *= 0.7 + 0.3 * innerShade;

    // Specular highlight
    vec2 lightDir = normalize(vec2(1.0, 1.0));
    float specular = pow(max(0.0, dot(normalize(centeredUv - mousePos), lightDir)), 8.0);
    specular *= inside * uMetallic * 0.5;
    liquidColor += vec3(specular);

    // Background color (slight gradient)
    vec3 bgColor = mix(uColor2 * 0.1, uColor1 * 0.05, uv.y);

    // Final color
    vec3 finalColor = mix(bgColor, liquidColor, inside);

    // Add subtle glow around blobs
    float glow = smoothstep(0.1, 0.0, d) * (1.0 - inside);
    finalColor += mix(uColor1, uColor2, 0.5) * glow * 0.3;

    gl_FragColor = vec4(finalColor, 1.0);
}
