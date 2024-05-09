@tool
class_name CustomCamera2D
extends Camera2D

@onready var bodies: Array = []
@onready var displays: Array = []

var planet_renderer_shader = preload("res://shaders/planet_renderer.gdshader")


func _process(_delta):
	for display in displays:
		display.scale = Vector2(1 / zoom.x, 1 / zoom.y)
		display.size = get_viewport_rect().size
		display.get_material().set_shader_parameter("camera_zoom", zoom)
		
		display.position = -display.size * display.scale / 2.0
		display.get_material().set_shader_parameter("camera_top_left_position", display.global_position.rotated(-global_rotation))
		display.get_material().set_shader_parameter("camera_rotation", global_rotation)


# TODO: Replace earth with a generic body class
func add_body(body: Earth):
	bodies.append(body)
	
	var display: ColorRect = ColorRect.new()
	display.material = ShaderMaterial.new()
	display.material.shader = planet_renderer_shader

	display.material.set_shader_parameter("height_map", body.height_map)
	display.material.set_shader_parameter("planet_position", body.position)
	display.material.set_shader_parameter("planet_radius", body.planet_radius)
	display.material.set_shader_parameter("noise_strenght", body.noise_strenght)
	display.material.set_shader_parameter("biome_ramp", body.biomes.get_color_gradient(16))
	display.material.set_shader_parameter("sea_level", body.sea_level)
	displays.append(display)
	add_child(display)
