shader_type canvas_item;

uniform vec4 color = vec4(0.1, 0.4, 0.75, 1.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = color;
	vec2 uv = UV * 2.0 - vec2(1, 1);
	float dist = sqrt(uv.x * uv.x + uv.y * uv.y);
	COLOR.a = -dist * 4.0 + 4.0;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
