extends Camera2D

@export var speed := 10
@export var planet: Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if planet:
		var relative_position = (planet.position - position).normalized()
		var theta = rad_to_deg(asin(relative_position.y)) - 90
		
		rotation_degrees  = theta
		
		if relative_position.x < 0 :
			rotation_degrees *= -1
	
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
		
	direction = direction.normalized()
	position += (direction / zoom * speed).rotated(rotation)
	
	if Input.is_action_pressed("zoom_up"):
		zoom += Vector2(0.2, 0.2) 
		
	if Input.is_action_pressed("zoom_down"):
		zoom -= Vector2(0.2, 0.2)
