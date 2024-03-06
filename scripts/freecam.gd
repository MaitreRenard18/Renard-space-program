extends CharacterBody2D

@export var speed := 10
@export var planet: Node2D;

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

	position += direction.normalized().rotated(rotation) * speed

	if Input.is_action_pressed("zoom_up"):
		$Camera2D.zoom += Vector2(0.01, 0.01) 

	if Input.is_action_pressed("zoom_down"):
		if $Camera2D.zoom.x > 0.02 and $Camera2D.zoom.y > 0.02:
			$Camera2D.zoom -= Vector2(0.01, 0.01)
