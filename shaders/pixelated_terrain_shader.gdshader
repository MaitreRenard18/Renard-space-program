shader_type canvas_item;

float abs(float x) {
	if (x < 0.0) {
		return -x;
	}
	
	return x;
}

void vertex() {
	VERTEX = VERTEX + (vec2(0, abs(sin(TIME))) * 32.0 * float(-1 * (VERTEX_ID % 2)));
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
