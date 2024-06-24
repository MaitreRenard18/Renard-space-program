extends Camera2D

@export var speed := 10

func _process(_delta):
	# Find nearest planet
	var nearest_planet = BodyHandler.get_celestial_bodies()[0]
	for body: CelestialBody in BodyHandler.get_celestial_bodies():
		if body.global_position.distance_to(get_parent().global_position) < nearest_planet.global_position.distance_to(get_parent().global_position):
			nearest_planet = body

	# Change camera orientation
	var relative_position = global_position - nearest_planet.global_position
	global_rotation = -atan2(relative_position.x, relative_position.y) + PI

	# Change camera zoom
	if Input.is_action_pressed("zoom_up"):
		zoom += Vector2(0.01, 0.01)

	if Input.is_action_pressed("zoom_down"):
		if zoom.x > 0.02 and zoom.y > 0.02:
			zoom -= Vector2(0.01, 0.01)

	# Move camera
	var force: float = 0
	var torque: float = 0
	var parent: MovableBody = get_parent()
	
	if Input.is_action_pressed("up"):
		force -= speed

	if Input.is_action_pressed("down"):
		force += speed

	if Input.is_action_pressed("left"):
		torque -= speed
	
	if Input.is_action_pressed("right"):
		torque += speed
	
	parent.apply_central_force(Vector2(0, force * 100).rotated(parent.global_rotation))
	parent.apply_torque(torque * 100)
