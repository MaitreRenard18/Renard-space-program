shader_type canvas_item;

global uniform vec2 sun_position;
uniform vec2 planet_position;

uniform vec4 sky_color = vec4(0.133, 0.592, 0.835, 1.0);
uniform vec4 sunset_color = vec4(1.0, 0.55, 0.30, 1.0);

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
	float sun_angle = atan(sun_position.y - planet_position.y, sun_position.x - planet_position.x) + PI / 2.0;
	vec2 rotated_uv = rotate(UV, PI - sun_angle);
	
	// Adjust colors based on sun direction
	if (rotated_uv.y > 0.8) {
		COLOR.rgb = sky_color.rgb;
	} else {
		float transition_factor = smoothstep(0.8, 0.5, rotated_uv.y);
		COLOR.rgb = mix(sky_color.rgb, sunset_color.rgb, transition_factor);
	}
	
	// Hide half of the atmosphere
	float sin_x = sin(rotated_uv.x * PI) / 8.0;
	rotated_uv.y += 0.05;
	if (sin_x + 0.45 > rotated_uv.y) {
		COLOR.a = 0.0;
	} else if (sin_x + 0.55 > rotated_uv.y) {
		float transition_factor = smoothstep(sin_x + 0.45, sin_x + 0.55, rotated_uv.y); 
        COLOR.a *= transition_factor;
	}
}