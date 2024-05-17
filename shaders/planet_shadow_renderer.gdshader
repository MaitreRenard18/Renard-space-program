shader_type canvas_item;

// Camera properties
global uniform vec2 screen_size;
global uniform vec2 camera_top_left_position;
global uniform vec2 camera_zoom;
global uniform float camera_rotation;

// Shadow settings
global uniform vec3 space_color;
uniform float shadow_intensity = .9;

// Planet properties
uniform float planet_radius;
uniform vec2 planet_position;


// Utils
vec2 rotate(vec2 vector, float angle) {
 vec2 rotated_vector = vec2(0, 0);
 vec2 translated_vector = vector - 0.5;
 rotated_vector.x = cos(angle) * translated_vector.x - sin(angle) * translated_vector.y;
 rotated_vector.y = sin(angle) * translated_vector.x + cos(angle) * translated_vector.y;

 return rotated_vector + 0.52;
}


float map(float value, float sourceStart, float sourceEnd, float targetStart, float targetEnd) {
	float normalizedValue = (value - sourceStart) / (sourceEnd - sourceStart);
	float targetValue = normalizedValue * (targetEnd - targetStart) + targetStart;
	return targetValue;
}


void fragment() {
	vec2 world_position = camera_top_left_position + UV * screen_size / camera_zoom;
	world_position = rotate(vec2(floor(world_position.x), floor(world_position.y)), camera_rotation);
	vec2 relative_position = world_position - planet_position;

	
	float distance_from_center = distance(planet_position, world_position);
	
	COLOR.rgb = space_color;
	COLOR.a = 0.0;
	 if (relative_position.y > -256.0 && relative_position.x > -planet_radius * 2.0 && relative_position.x < planet_radius * 2.0) {
		float transition_factor = map(smoothstep(-256.0, 256.0, relative_position.y), 0.0, 1.0, 0.0, shadow_intensity);
		float x = abs(relative_position.x);
		transition_factor = 1.0 - smoothstep(0.0, 1.0, map(x, planet_radius * .75, planet_radius * 1.5, 0.0, 1.0));
		COLOR.a = transition_factor;
	}
}
