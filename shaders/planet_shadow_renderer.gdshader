shader_type canvas_item;

// Camera properties
global uniform vec2 screen_size;
global uniform vec2 camera_top_left_position;
global uniform vec2 camera_zoom;
global uniform float camera_rotation;

// Shadow settings
global uniform vec3 space_color;
uniform float shadow_width_factor = 1.75;
uniform float shadow_radius_factor = .2;
uniform float shadow_y_offset_factor = 0.5;
uniform float shadow_softness = .2;

// Planet properties
uniform float planet_radius;
uniform vec2 planet_position;


// Utils
vec2 rotate(vec2 vector, float angle) {
    vec2 rotated_vector;
    rotated_vector.x = cos(angle) * vector.x - sin(angle) * vector.y;
    rotated_vector.y = sin(angle) * vector.x + cos(angle) * vector.y;

    return rotated_vector;
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
	
	float shadow_radius = planet_radius * shadow_width_factor;
	float sin_y = sin(map(relative_position.x, -shadow_radius, shadow_radius, 0, PI)) * planet_radius * shadow_radius_factor - planet_radius * shadow_y_offset_factor;
	
	 if (relative_position.y > sin_y && relative_position.x > -shadow_radius && relative_position.x < shadow_radius) {
	    float x_factor = map(min(abs(relative_position.x), shadow_radius), shadow_radius * (1.0 - shadow_softness), shadow_radius, 0.0, 1.0);
	    float y_factor = map(relative_position.y, sin_y, sin_y + shadow_radius * (shadow_softness), 0.0, 1.0);
		
	    // Incorporate shadow_softness into the smoothstep function to control the transition
	    float smooth_factor = smoothstep(0.0, 1.0, y_factor) * smoothstep(1.0, 0.0, x_factor);
	    COLOR.a = smooth_factor;
	}
}
