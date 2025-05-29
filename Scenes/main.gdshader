shader_type canvas_item;

uniform float star_density = 40.0;
uniform float twinkle_speed = 2.0;
uniform float star_brightness = 1.0;
uniform vec2 drift_speed = vec2(0.01, 0.0); // Add horizontal drift by default

void fragment() {
    // Add drift to UVs
    vec2 uv = UV + TIME * drift_speed;

    // Generate pseudo-random hash per star
    float noise = fract(sin(dot(floor(uv * star_density), vec2(12.9898, 78.233))) * 43758.5453);

    // Twinkle with random phase offset per star
    float twinkle = sin(TIME * twinkle_speed + noise * 10.0) * 0.5 + 0.5;

    // Filter for sparse, sharp stars
    float star = smoothstep(0.95, 1.0, noise) * twinkle;

    // Final color
    COLOR = vec4(vec3(star * star_brightness), 1.0);
}