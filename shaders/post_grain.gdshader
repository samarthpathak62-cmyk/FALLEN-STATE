shader_type canvas_item;
render_mode blend_add, unshaded;
//
// POST — Film grain (additive)
//
// Halka noise image ko "film" jaisa banata hai. Bahut kam amount rakho
// (0.04-0.06) warna screen gandi lagegi.
//

uniform float amount : hint_range(0.0, 0.2) = 0.045;
uniform float noise_scale : hint_range(0.5, 4.0) = 1.6;
uniform float speed = 18.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 p = floor(UV * vec2(1280.0, 720.0) / noise_scale);
	float t = floor(TIME * speed);
	float n = hash(p + vec2(t, t * 1.37));
	COLOR = vec4(vec3(n * amount), 1.0);
}
