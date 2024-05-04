@tool
class_name CustomCamera2D
extends Camera2D

func _process(_delta):
	var display = $ColorRect
	
	display.scale = Vector2(1 / zoom.x, 1 / zoom.y)
	display.size = get_viewport_rect().size
	display.get_material().set_shader_parameter("camera_zoom", zoom)
	
	display.position = -display.size * display.scale / 2.0
	display.get_material().set_shader_parameter("camera_top_left_position", display.global_position)
	display.get_material().set_shader_parameter("camera_rotation", global_rotation)
