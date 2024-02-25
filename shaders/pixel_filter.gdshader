shader_type canvas_item;

// Variables changed by the script of the camera
uniform float zoom;
uniform vec2 position;
uniform float rotation;

// Get screen texture
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear;


// Called for every pixel the material is visible on
void fragment() {
	int scaled_pixel_size = int(zoom);
	ivec2 screen_size = textureSize(SCREEN_TEXTURE, 0);
	
	float x = float(int(FRAGCOORD.x) % scaled_pixel_size);
	float y = float(int(FRAGCOORD.y) % scaled_pixel_size);
	
	x = FRAGCOORD.x + floor(float(scaled_pixel_size) / 2.0) - x;
    y = FRAGCOORD.y + floor(float(scaled_pixel_size) / 2.0) - y;
	
	COLOR = texture(SCREEN_TEXTURE, vec2(x, y) / vec2(screen_size));
}






//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
