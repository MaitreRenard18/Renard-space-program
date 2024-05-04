class_name WaterSpring
extends Node2D

@export var planet_center: Vector2
@onready var relative_position: Vector2 = global_position - planet_center
@onready var angle: float = atan2(relative_position.x, relative_position.y)

@onready var height: float = get_height()
@onready var target_height: float = height

var velocity: float = 0
var force: float = 0


func get_height() -> float:
	return planet_center.distance_to(global_position)


func water_update(spring_constant: float, dampening: float) -> void:
	height = get_height()
	
	var x = height - target_height
	var loss = -dampening * velocity
	
	force = -spring_constant * x + loss
	velocity += force
	
	global_position += Vector2(0, velocity).rotated(-angle)


func set_planet_center(coordinates: Vector2) -> void:
	planet_center = coordinates


func _physics_process(_delta: float):
	velocity += randf() / 10
