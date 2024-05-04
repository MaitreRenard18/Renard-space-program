shader_type canvas_item;

const vec3 space_color = vec3(0.004, 0.004, 0.027);

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear;

vec2 rotate(vec2 vector, float angle) {
 vec2 rotated_vector = vec2(0, 0);
 vec2 translated_vector = vector - 0.5;
 rotated_vector.x = cos(angle) * translated_vector.x - sin(angle) * translated_vector.y;
 rotated_vector.y = sin(angle) * translated_vector.x + cos(angle) * translated_vector.y;

 return rotated_vector + 0.52;
}

void fragment() {
	vec2 rotated_uv = rotate(UV, 0);

	float sin_x = sin(rotated_uv.x * PI) / 32.0 - .05;
	
	ivec2 screen_size = textureSize(SCREEN_TEXTURE, 0);
	COLOR = texture(SCREEN_TEXTURE, vec2(FRAGCOORD.x / float(screen_size.x), FRAGCOORD.y / float(screen_size.y)));
	
	float transition_factor = smoothstep(sin_x + 0.45, sin_x + 0.55, rotated_uv.y); // Smooth transition
	vec2 uv = UV * 2.0 - vec2(1, 1);
	float dist = distance(uv, vec2(0.0, 0.0));
	
	COLOR.rgb = mix(COLOR.rgb, space_color, transition_factor - 0.01); // Blend towards black
	
}
