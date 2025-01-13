extends Camera2D

@export var speed := 10

func _process(_delta):
	# Move camera
	var direction: float = 0
	
	if Input.is_action_pressed("down"):
		direction = 1

	elif Input.is_action_pressed("up"):
		direction = -1
	
	position.y += direction * speed / zoom.y
