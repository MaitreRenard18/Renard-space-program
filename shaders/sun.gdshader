shader_type canvas_item;

uniform float glow_intensity = 0.5;
uniform float animation_speed = .05;
uniform sampler2D sun_texture: filter_nearest;

float map(float value, float sourceStart, float sourceEnd, float targetStart, float targetEnd) {
	float normalizedValue = (value - sourceStart) / (sourceEnd - sourceStart);
	float targetValue = normalizedValue * (targetEnd - targetStart) + targetStart;
	return targetValue;
}

void fragment() {
	vec2 offset = vec2(mod(UV.x + TIME * animation_speed, 1.0), mod(UV.y + TIME * animation_speed, 1.0));
	COLOR.rgb = texture(sun_texture, offset).rgb;
	
	float dist = distance(vec2(.5, .5), UV) + map(sin(TIME), -1.0, 1.0, 0.0, .02);
	COLOR.a = 1.0 - smoothstep(glow_intensity / 2.0, .5, dist);
}
