extends Node

var screen_size: Vector2
var half_screen_size: Vector2
@onready var current_camera: Camera2D = get_viewport().get_camera_2d()


func _ready():
	process_priority = 10
	get_tree().root.size_changed.connect(update_screen_size)
	update_screen_size()


func _process(_delta):
	if not current_camera:
		return
	
	RenderingServer.global_shader_parameter_set("camera_zoom", current_camera.zoom)
	RenderingServer.global_shader_parameter_set("camera_rotation", current_camera.global_rotation)
	
	var camera_position: Vector2 = current_camera.get_screen_center_position().rotated(-current_camera.global_rotation) - half_screen_size / current_camera.zoom
	RenderingServer.global_shader_parameter_set("camera_top_left_position", camera_position)


func update_screen_size():
	screen_size = get_tree().root.size
	half_screen_size = screen_size / 2
	RenderingServer.global_shader_parameter_set("screen_size", screen_size)

