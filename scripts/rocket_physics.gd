extends CharacterBody2D

@export var speed = 400
@export var rotation_speed = 1.5
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var rotation_direction = 0
var mass  = 10

func get_input():
	rotation_direction = Input.get_axis("left", "right")
	velocity = transform.x * Input.get_axis("down", "up") * speed

func _physics_process(delta):
	get_input()
	rotation += rotation_direction * rotation_speed * delta
	velocity.y += ((gravity * delta)*mass + (gravity / 60)) / 2  #gravité axe y
	move_and_slide()
	
