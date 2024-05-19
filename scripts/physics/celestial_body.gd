extends StaticBody2D
class_name CelestialBody

@export_category("Physics Settings")
@export var mass: float
@export var revolution_speed: float = .5
@export var rotation_speed: float = .5

var satellites: Array[Planet]


func _ready():
	for node in get_children():
		if node is CelestialBody:
			satellites.append(node)


func _physics_process(delta):
	for node in satellites:
		node.position = node.position.rotated(deg_to_rad(node.revolution_speed))
