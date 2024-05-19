shader_type canvas_item;


// Camera properties
global uniform vec2 screen_size;
global uniform vec2 camera_top_left_position;
global uniform vec2 camera_zoom;
global uniform float camera_rotation;

// Planet properties
uniform sampler2D height_map;
uniform sampler2D biome_ramp: filter_nearest;

uniform vec2 planet_position;
uniform float noise_strenght;
uniform float planet_radius;
uniform float sea_level;
uniform float planet_rotation;


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


// Main functions
float get_terrain_variation(float angle) {
	float projected_x = map(cos(angle), -1.0, 1.0, 0.0, 1.0);
	float projected_y = map(sin(angle), -1.0, 1.0, 0.0, 1.0);

	return texture(height_map, vec2(projected_x, projected_y)).r; // Between 0 and 1
}


float get_terrain_height(float angle) {
	return get_terrain_variation(angle) + planet_radius;
}


vec4 get_biome_color(vec2 world_position) {
	vec2 relative_position = world_position - planet_position;

	float terrain_variation;
	
	float distance_from_center = distance(planet_position, world_position);
	
	if (distance_from_center > planet_radius) {
		float angle = atan(relative_position.y, relative_position.x);
		terrain_variation = get_terrain_variation(angle);
		
		if (distance_from_center > planet_radius + map(terrain_variation, sea_level, 1.0, 0.0, 1.0) * noise_strenght){
            return vec4(0.0, 0.0, 0.0, 0.0);
        }

	} else {
		vec2 uv = vec2(map(relative_position.x, -planet_radius, planet_radius, 0, 1), map(relative_position.y, -planet_radius, planet_radius, 0, 1));
        terrain_variation = texture(height_map, uv).r;
    }
	
	return texture(biome_ramp, vec2(terrain_variation, 0));
}


void fragment() {
    vec2 world_position = camera_top_left_position + UV * screen_size / camera_zoom;
	world_position = rotate(vec2(floor(world_position.x), floor(world_position.y)), camera_rotation - planet_rotation);
	
	// Render planet
	COLOR = get_biome_color(world_position);
}
