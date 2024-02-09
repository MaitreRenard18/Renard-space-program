shader_type canvas_item;
const float pixel_size = 16.0;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ivec2 screen_size = textureSize(SCREEN_TEXTURE, 0);
	
	float pixel_size_x = float(screen_size.x) / pixel_size;
	float pixel_size_y =  float(screen_size.y) / pixel_size;
	float x = floor(SCREEN_UV.x * pixel_size_x) / pixel_size_x;
    float y = floor(SCREEN_UV.y * pixel_size_y) / pixel_size_y;
	
	COLOR = texture(SCREEN_TEXTURE, vec2(x, y));
}


//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
