extends Camera2D

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

	position += direction.normalized() / zoom * speed

	if Input.is_action_pressed("zoom_up"):
		zoom += Vector2(0.2, 0.2) 

	if Input.is_action_pressed("zoom_down"):
		zoom -= Vector2(0.2, 0.2)
