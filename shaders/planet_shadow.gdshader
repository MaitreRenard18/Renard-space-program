shader_type canvas_item;

uniform vec2 sun_position = vec2(0.0, 1.0);
const vec3 space_color = vec3(0.004, 0.004, 0.027);

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear;

vec2 rotate(vec2 vector, float angle) {
 vec2 rotated_vector = vec2(0, 0);
 vec2 translated_vector = vector - 0.5;
 rotated_vector.x = cos(angle) * translated_vector.x - sin(angle) * translated_vector.y;
 rotated_vector.y = sin(angle) * translated_vector.x + cos(angle) * translated_vector.y;

 return rotated_vector + 0.52;
}

void vertex() {
	// Called for every vertex the material is visible on.
}

float get_atmosphere_alpha(vec2 fragment_uv) {
	vec2 uv = fragment_uv * 2.0 - vec2(1, 1);
	float dist = distance(uv, vec2(0.0, 0.0));
	float a = smoothstep(0.0, 0.25, 1.0 - dist);
	
	float angle = atan(sun_position.x, sun_position.y);
	vec2 rotated_uv = rotate(fragment_uv, angle);
	
	float sin_x = sin(rotated_uv.x * PI) / 4.0;
	rotated_uv.y += 0.05;
	if (sin_x + 0.45 > rotated_uv.y) {
		a = 0.0;
	} else if (sin_x + 0.55 > rotated_uv.y) {
		float transition_factor = smoothstep(sin_x + 0.45, sin_x + 0.55, rotated_uv.y); 
        a *= transition_factor;
	}
	
	return a;
}

void fragment() {
	// "Eclipse" effect
	float angle = atan(sun_position.x, sun_position.y);
	vec2 rotated_uv = rotate(UV, angle + PI);

	float sin_x = sin(rotated_uv.x * PI) / 32.0 - .05;
	
	ivec2 screen_size = textureSize(SCREEN_TEXTURE, 0);
	COLOR = texture(SCREEN_TEXTURE, vec2(FRAGCOORD.x / float(screen_size.x), FRAGCOORD.y / float(screen_size.y)));
	
	float transition_factor = smoothstep(sin_x + 0.45, sin_x + 0.55, rotated_uv.y); // Smooth transition
	vec2 uv = UV * 2.0 - vec2(1, 1);
	float dist = distance(uv, vec2(0.0, 0.0));
	
	COLOR.rgb = mix(COLOR.rgb, space_color, transition_factor - 0.01); // Blend towards black
	
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
