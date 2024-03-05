extends CharacterBody2D

@export var speed := 10


func _process(_delta):
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

	position += direction.normalized() * speed

	if Input.is_action_pressed("zoom_up"):
		$Camera2D.zoom += Vector2(0.05, 0.05) 

	if Input.is_action_pressed("zoom_down"):
		$Camera2D.zoom -= Vector2(0.05, 0.05)
