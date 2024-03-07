shader_type canvas_item;

uniform vec2 sun_position = vec2(0.0, 1.0);
const vec3 space_color = vec3(0.004, 0.004, 0.027);

vec2 rotate(vec2 vector, float angle) {
 vec2 rotated_vector = vec2(0, 0);
 vec2 translated_vector = vector - 0.5;
 rotated_vector.x = cos(angle) * translated_vector.x - sin(angle) * translated_vector.y;
 rotated_vector.y = sin(angle) * translated_vector.x + cos(angle) * translated_vector.y;

 return rotated_vector + 0.5;
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// North pole and ocean
	float pole_radius = 0.5;
	vec2 offsetted_uv = UV - vec2(0.5, 0.5);
	
	// "Eclipse" effect
	float angle = atan(sun_position.x, sun_position.y);
	vec2 rotated_uv = rotate(UV, angle);

	float sin_x = sin(rotated_uv.x * PI) / 32.0;

	if (sin_x + 0.55 < rotated_uv.y) { // Pitch black
		COLOR.rgb = space_color;
	} else if (sin_x + 0.45 < rotated_uv.y) { // Transition from original color to black
		float transition_factor = smoothstep(sin_x + 0.45, sin_x + 0.55, rotated_uv.y); // Smooth transition
        COLOR.rgb = mix(COLOR.rgb, space_color, transition_factor); // Blend towards black
	}
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
