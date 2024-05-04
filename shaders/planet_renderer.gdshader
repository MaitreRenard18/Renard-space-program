shader_type canvas_item;

uniform sampler2D noise_map;

uniform vec2 camera_top_left_position;
uniform vec2 camera_zoom;
uniform float camera_rotation;

uniform vec2 planet_position;
uniform float noise_strenght;
uniform float planet_radius = 500;
uniform float sea_level;


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

vec4 get_biome_color(vec2 world_position) {
	world_position = vec2(floor(world_position.x), floor(world_position.y));
	vec2 relative_world_position = world_position - planet_position;
	
	float noise_value;
	
	vec2 relative_position = world_position - planet_position;
	float distance_from_center = sqrt(relative_world_position.x * relative_world_position.x + relative_world_position.y * relative_world_position.y);
	
	if (distance_from_center > planet_radius) {
		float angle = atan(relative_world_position.y, relative_world_position.x);
		float projected_x = ((planet_radius * cos(angle)) / planet_radius + 1.0) / 2.0;
		float projected_y = ((planet_radius * sin(angle)) / planet_radius + 1.0) / 2.0;

		noise_value = texture(noise_map, vec2(projected_x, projected_y)).r;
		if ((noise_value <= .45 && distance_from_center > planet_radius + .45 * noise_strenght) || (noise_value > .45 && distance_from_center > planet_radius + noise_value * noise_strenght)) {
            return vec4(0.0, 0.0, 0.0, 0.0);
        }

	} else {
		vec2 uv = vec2(map(relative_world_position.x, -planet_radius, planet_radius, 0, 1), map(relative_world_position.y, -planet_radius, planet_radius, 0, 1));
        noise_value = texture(noise_map, uv).r;
    }
	
	if (noise_value > 0.5) {
        return vec4(120.0 / 255.0, 175.0 / 255.0, 82.0 / 255.0, 1.0);
    } else if (noise_value > 0.45) {
        return vec4(255.0 / 255.0, 220.0 / 255.0, 142.0 / 255.0, 1.0);
    } else {
        return vec4(0.0, 134.0 / 255.0, 244.0 / 255.0, 1.0);
    }
}

void fragment() {
    vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE; // Causes lags ?
    vec2 world_position = rotate((camera_top_left_position) + UV * screen_size / camera_zoom, camera_rotation);

    COLOR = get_biome_color(world_position);
}
