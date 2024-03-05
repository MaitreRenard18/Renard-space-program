extends Node2D

# Settings
@export_category("Noise Settings")
@export var noise_strenght: float
@export var noise_frequency: float
@export var noise_seed: int

@export_category("Generation Settings")
@export var vertex_count: int
@export var radius: float

@export_category("Folliage Settings")
@export_range(0, 1) var grass_density: float
@export_range(0, 1) var tree_density: float

@export_category("Physics")
@export var mass: float

# Folliage
var grass_textures: Array = [
	preload("res://assets/environnement/dark_grass_01.png"),
	preload("res://assets/environnement/dark_grass_02.png"),
	preload("res://assets/environnement/grass_01.png"),
	preload("res://assets/environnement/grass_02.png"),
	preload("res://assets/environnement/flower_01.png")
]

var small_grass_textures: Array = [
	preload("res://assets/environnement/small_variations/dark_grass_01.png"),
	preload("res://assets/environnement/small_variations/dark_grass_02.png"),
	preload("res://assets/environnement/small_variations/dark_flower_01.png"),
	preload("res://assets/environnement/small_variations/rock_01.png")
]

# Attributes
var atmosphere_shader: Resource = preload("res://shaders/atmosphere.gdshader")

var circular_noise_0: CircularNoise
var circular_noise_1: CircularNoise
var montain_noise: CircularNoise

# Functions
func get_terrain_height(theta: float) -> float:
	var height: float = circular_noise_0.get_noise(theta) * noise_strenght * 4 + 1
	height += circular_noise_1.get_noise(theta) * noise_strenght / 2
	height *= radius
	
	return height


func get_vertex_coordinates(theta: float) -> Vector2:
	var height: float = get_terrain_height(theta)
	
	var x: float = cos(theta) * height
	var y: float = -sin(theta) * height
	
	return Vector2(x, y)


func _ready():
	# Get vertex count
	vertex_count = max(vertex_count, 3)
	
	# Set random seed
	if noise_seed == -1:
		noise_seed = randi_range(0, 2 ** 16)
	
	# Create noises
	circular_noise_0 = CircularNoise.new(noise_seed, noise_frequency / 4)	
	circular_noise_1 = CircularNoise.new(noise_seed, noise_frequency * 2)

	# Generate planet geometry
	var step: float = (2 * PI) / vertex_count
	var polygon: PackedVector2Array = []
	var uv: PackedVector2Array = []

	for i in range(vertex_count + 1 / 2):
		# Get angle
		var theta: float = i * step
		
		# Get vertex and uv position
		var vertex_position = get_vertex_coordinates(theta)
		var uv_position = Vector2(vertex_position.x / (get_terrain_height(0) + get_terrain_height(PI)), vertex_position.y / (get_terrain_height(PI / 2) + get_terrain_height(3 * PI / 2)))
		uv_position /= 2
		uv_position += Vector2(.25, .25)
		
		polygon.append(vertex_position)
		uv.append(uv_position)
		
		# Add grass
		if randf() < grass_density:
			var grass = Sprite2D.new()
			grass.texture = grass_textures[randi_range(0, grass_textures.size() - 1)]
			grass.rotation = (vertex_position - polygon[i - 1]).angle() + PI
			grass.position = vertex_position
			grass.z_index = -1
			add_child(grass)
		
		# Add background grass
		if randf() < grass_density:
			var grass = Sprite2D.new()
			grass.texture = small_grass_textures[randi_range(0, small_grass_textures.size() - 1)]
			grass.rotation = -theta - 3 * PI / 2

			var depth: float = (1 - randf() / 10)
			grass.position = vertex_position * (depth / 2 + 0.5)

			grass.scale = Vector2(depth, depth)
			grass.z_index = 1
			add_child(grass)

		# Add trees
		if randf() < tree_density:
			var tree = Sprite2D.new()
			tree.texture = load("res://assets/environnement/tree.png")
			tree.rotation = (vertex_position - polygon[i - 1]).angle() + PI
			tree.position = vertex_position
			tree.z_index = -1
			add_child(tree)
	
	$Polygon2D.set_polygon(polygon)
	$Polygon2D.set_uv(uv)
	$AnimatableBody2D/CollisionPolygon2D.set_polygon(polygon)
	
	# Set up atmosphere
	var atmosphere = MeshInstance2D.new()
	atmosphere.mesh = QuadMesh.new()
	atmosphere.mesh.size = Vector2(radius, radius) * 2.5
	
	atmosphere.material = ShaderMaterial.new()
	atmosphere.material.shader = atmosphere_shader
	atmosphere.z_index = -2
	
	add_child(atmosphere)
	
	# Move planet
	position = Vector2(0, get_terrain_height(PI / 2))


func _process(_delta):
	pass
