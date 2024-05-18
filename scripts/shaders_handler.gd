extends Node


func _process(_delta):
	var screen_size: Vector2 = get_tree().root.size
	var current_camera: Camera2D = get_viewport().get_camera_2d()
	
	var camera_position: Vector2 = current_camera.global_position.rotated(-current_camera.global_rotation) - screen_size / 2 / current_camera.zoom
	
	RenderingServer.global_shader_parameter_set("screen_size", screen_size)
	RenderingServer.global_shader_parameter_set("camera_zoom", current_camera.zoom)
	RenderingServer.global_shader_parameter_set("camera_top_left_position", camera_position)
	RenderingServer.global_shader_parameter_set("camera_rotation", current_camera.global_rotation)

