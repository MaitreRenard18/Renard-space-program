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

var atmosphere_shader = preload("res://shaders/atmosphere.gdshader")

func get_noise(theta: float) -> float:
	return 1.0


func _ready():
	# Generate planet geometry
	vertex_count = max(vertex_count, 3)
	
	if seed == -1:
		seed = randi_range(0, 2 ** 16)
	
	var circular_noise_0 = CircularNoise.new(seed, noise_frequency / 4)	
	var circular_noise_1 = CircularNoise.new(seed, noise_frequency * 2)
	
	var step: float = (2 * PI) / vertex_count
	var polygon: PackedVector2Array = []
	for i in range(vertex_count + 1):
		var theta: float = i * step
		var x: float = cos(theta) * radius
		var y: float = sin(theta) * radius
		
		var height: float = circular_noise_0.get_noise(theta) * noise_strenght * 4 + 1
		height += circular_noise_1.get_noise(theta) * noise_strenght / 2
		polygon.append(Vector2(x * height, y * height))
	
	$Polygon2D.set_polygon(polygon)
	$AnimatableBody2D/CollisionPolygon2D.set_polygon(polygon)
	
	# Set up atmosphere
	var atmosphere = MeshInstance2D.new()
	atmosphere.mesh = QuadMesh.new()
	atmosphere.mesh.size = Vector2(radius, radius) * 3.0
	
	atmosphere.material = ShaderMaterial.new()
	atmosphere.material.shader = atmosphere_shader
	atmosphere.z_index = -1
	
	add_child(atmosphere)
	
	# Move planet
	position = Vector2(0, radius + circular_noise_0.get_noise(PI / 2) * noise_strenght + 1)


func _process(delta):
	pass
