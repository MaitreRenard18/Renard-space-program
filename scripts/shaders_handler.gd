extends Node

func _process(_delta):
	var current_camera: Camera2D = get_viewport().get_camera_2d()
	var camera_position: Vector2 = current_camera.global_position.rotated(-current_camera.global_rotation) - get_viewport().get_visible_rect().size / 2 / current_camera.zoom

	RenderingServer.global_shader_parameter_set("screen_size", get_viewport().get_visible_rect().size)
	RenderingServer.global_shader_parameter_set("camera_zoom", current_camera.zoom)
	RenderingServer.global_shader_parameter_set("camera_top_left_position", camera_position)
	RenderingServer.global_shader_parameter_set("camera_rotation", current_camera.global_rotation)

