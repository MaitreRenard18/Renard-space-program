extends AnimatableBody2D
class_name CelestialBody

@export_category("Physics Settings")
@export var gravity: float
@export var revolution_speed: float = .5
@export var rotation_speed: float = .5

var satellites: Array[Planet]

func _ready():
	BodyHandler.register_celestial_body(self)

	for node in get_children():
		if node is CelestialBody:
			satellites.append(node)


func _physics_process(_delta):
	for node in satellites:
		node.position = node.position.rotated(deg_to_rad(node.revolution_speed - rotation_speed))
		node.rotation += deg_to_rad(node.rotation_speed)
