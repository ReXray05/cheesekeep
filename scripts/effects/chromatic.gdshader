shader_type canvas_item;
render_mode unshaded;
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform float amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 offset = SCREEN_PIXEL_SIZE * vec2(2.0 * clamp(amount, 0.0, 1.0), 0.0);
	vec4 center = texture(screen_texture, SCREEN_UV);
	float red = texture(screen_texture, clamp(SCREEN_UV + offset, vec2(0.0), vec2(1.0))).r;
	float blue = texture(screen_texture, clamp(SCREEN_UV - offset, vec2(0.0), vec2(1.0))).b;
	COLOR = vec4(red, center.g, blue, center.a);
}
