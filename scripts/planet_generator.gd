extends Node2D

@export_category("Noise Settings")
@export var noise_strenght: float
@export var noise_frequency: float
@export var seed: int = -1

@export_category("Generation Settings")
@export var vertex_count: int
@export var radius: float
 
@export_category("Physics")
@export var mass: float


func get_noise(theta: float) -> float:
	return 1.0


func _ready():
	vertex_count = max(vertex_count, 3)
	
	if seed == -1:
		seed = randi_range(0, 2 ** 16)
		
	var circular_noise = CircularNoise.new(seed, noise_frequency)
	
	print(circular_noise.get_noise(0.0))
	print(circular_noise.get_noise(2 * PI))
	
	var step: float = (2 * PI) / vertex_count
	var polygon: PackedVector2Array = []
	for i in range(vertex_count + 1):
		var theta: float = i * step
		var x: float = cos(theta) * radius
		var y: float = sin(theta) * radius
		
		var height: float = circular_noise.get_noise(theta) * noise_strenght + 1
		polygon.append(Vector2(x * height, y * height))
	
	$Polygon2D.set_polygon(polygon)
	$AnimatableBody2D/CollisionPolygon2D.set_polygon(polygon)


func _process(delta):
	pass
