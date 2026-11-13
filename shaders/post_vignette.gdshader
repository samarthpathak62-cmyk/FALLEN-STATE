shader_type canvas_item;
//
// POST — Vignette + thanda edge tint
//
// Screen ko padhta nahi (hint_screen_texture ki zaroorat nahi), isliye
// GL Compatibility renderer par bhi 100% chalta hai aur cost lagbhag zero hai.
// Yahi "cinematic" look ka sabse sasta hissa hai.
//

uniform float strength : hint_range(0.0, 1.5) = 0.75;
uniform float radius : hint_range(0.1, 1.2) = 0.40;
uniform vec3 edge_tint : source_color = vec3(0.015, 0.025, 0.05);

void fragment() {
	vec2 d = UV - vec2(0.5);
	d.x *= 1.05;
	float dist = length(d) * 1.45;
	float v = smoothstep(radius, 1.05, dist);
	COLOR = vec4(edge_tint, v * strength);
}
