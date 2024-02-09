shader_type canvas_item;
const float pixel_size =  16.0;


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
    // Called for every pixel the material is visible on.
    float x = floor(UV.x * pixel_size) / pixel_size;
    float y = floor(UV.y * pixel_size) / pixel_size;
    
    COLOR = texture(TEXTURE, vec2(x, y));
}


//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
