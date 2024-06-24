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
uniform float noise_strength;
uniform float planet_radius;
uniform float sea_level;
uniform float planet_rotation;


// Utils
vec2 rotate(vec2 vector, float angle) {
    float cos_angle = cos(angle);
    float sin_angle = sin(angle);
    
    return vec2(
        cos_angle * vector.x - sin_angle * vector.y,
        sin_angle * vector.x + cos_angle * vector.y
    );
}

float map(float value, float sourceStart, float sourceEnd, float targetStart, float targetEnd) {
    return targetStart + (value - sourceStart) * (targetEnd - targetStart) / (sourceEnd - sourceStart);
}

// Main functions
float get_terrain_variation(float angle) {
    vec2 uv = vec2(
        map(cos(angle), -1.0, 1.0, 0.0, 1.0),
        map(sin(angle), -1.0, 1.0, 0.0, 1.0)
    );
	
    return texture(height_map, uv).r; // Between 0 and 1
}

float get_terrain_height(float angle) {
	return get_terrain_variation(angle) + planet_radius;
}

vec4 get_biome_color(vec2 world_position) {
    vec2 relative_position = rotate(world_position - planet_position, -planet_rotation);
    
    float terrain_variation;
    
    float distance_from_center = floor(distance(planet_position, world_position));
    float angle = atan(relative_position.y, relative_position.x);
    
    if (distance_from_center > planet_radius) {
        terrain_variation = get_terrain_variation(angle);
        
        if (distance_from_center > planet_radius + map(terrain_variation, sea_level, 1.0, 0.0, 1.0) * noise_strength){
            return vec4(0.0, 0.0, 0.0, 0.0);
        }
    } else {
        float normalized_distance = distance_from_center / planet_radius;
        
        float x = map(cos(angle) * normalized_distance, -1.0, 1.0, 0.0, 1.0);
        float y = map(sin(angle) * normalized_distance, -1.0, 1.0, 0.0, 1.0);

        terrain_variation = texture(height_map, vec2(x, y)).r;
    }
    
    return texture(biome_ramp, vec2(terrain_variation, 0));
}

void fragment() {
    vec2 pixel_position = rotate(camera_top_left_position + (UV * screen_size / camera_zoom), camera_rotation);
    COLOR = get_biome_color(pixel_position);
}