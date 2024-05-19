extends CharacterBody2D

@export var speed := 10
@export var planet: Node2D;

@onready var camera: Camera2D = $Camera2D


func _process(_delta):
	if planet:
		var relative_position = position - planet.position
		rotation = -atan2(relative_position.x, relative_position.y) + PI
	
	# Camera movement
	var direction = Vector2(0, 0)

	if Input.is_action_pressed("down"):
		direction.y = 1

	elif Input.is_action_pressed("up"):
		direction.y = -1

	if Input.is_action_pressed("right"):
		direction.x = 1

	elif Input.is_action_pressed("left"):
		direction.x = -1

	position += direction.normalized().rotated(rotation) * speed / camera.zoom

	if Input.is_action_pressed("zoom_up"):
		camera.zoom += Vector2(0.01, 0.01)

	if Input.is_action_pressed("zoom_down"):
		if camera.zoom.x > 0.02 and camera.zoom.y > 0.02:
			camera.zoom -= Vector2(0.01, 0.01)
