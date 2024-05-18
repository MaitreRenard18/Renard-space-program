extends Node

var screen_size: Vector2
@onready var current_camera: Camera2D = get_viewport().get_camera_2d()


func _ready():
	get_tree().root.size_changed.connect(update_screen_size)
	update_screen_size()


func _process(_delta):
	var camera_position: Vector2 = current_camera.global_position.rotated(-current_camera.global_rotation) - screen_size / 2 / current_camera.zoom
	
	RenderingServer.global_shader_parameter_set("camera_zoom", current_camera.zoom)
	RenderingServer.global_shader_parameter_set("camera_top_left_position", camera_position)
	RenderingServer.global_shader_parameter_set("camera_rotation", current_camera.global_rotation)


func update_screen_size():
	screen_size = get_tree().root.size
	RenderingServer.global_shader_parameter_set("screen_size", screen_size)

