shader_type canvas_item;

uniform vec4 sky_color = vec4(0.133, 0.592, 0.835, 1.0);
uniform vec4 sunset_color = vec4(1.0, 0.55, 0.30, 1.0);
uniform vec2 sun_position = vec2(0.0, 1.0);
varying vec2 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

vec2 rotate(vec2 vector, float angle) {
 vec2 rotated_vector = vec2(0, 0);
 vec2 translated_vector = vector - 0.5;
 rotated_vector.x = cos(angle) * translated_vector.x - sin(angle) * translated_vector.y;
 rotated_vector.y = sin(angle) * translated_vector.x + cos(angle) * translated_vector.y;

 return rotated_vector + 0.5;
}

void fragment() {
	COLOR = sky_color;
	
	// Change alpha depending on distance from center
	vec2 uv = UV * 2.0 - vec2(1, 1);
	float dist = distance(uv, vec2(0.0, 0.0));
	COLOR.a = smoothstep(0.0, 0.25, 1.0 - dist);
	
	// Change color depending on sun direction
	float angle = atan(sun_position.x, sun_position.y);
	vec2 rotated_uv = rotate(UV, angle);
	
	// Adjust colors based on sun direction
	if (rotated_uv.y > 0.8) {
		COLOR.rgb = sky_color.rgb;
	} else {
		float transition_factor = smoothstep(0.8, 0.5, rotated_uv.y);
		COLOR.rgb = mix(sky_color.rgb, sunset_color.rgb, transition_factor);
	}
	float sin_x = -sin(rotated_uv.x * PI) / 8.0;

	if (sin_x + 0.45 > rotated_uv.y) { // Pitch black
		COLOR.a = 0.0;
	} else if (sin_x + 0.55 > rotated_uv.y) { // Transition from original color to black
		float transition_factor = smoothstep(sin_x + 0.45, sin_x + 0.55, rotated_uv.y); // Smooth transition
        COLOR.a *= transition_factor;
	}
}