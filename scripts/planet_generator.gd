extends Node2D

# Settings
@export_category("Noise Settings")
@export var noise_seed: int
@export var number_of_layers: int
@export var noise_strenght: float
@export var roughness: float
@export_range(0, 1) var persistence: float

@export_category("Generation Settings")
@export var vertex_count: int
@export var radius: float

@export_category("Atmosphere Settings")
@export var temperature_frequency: float

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

var small_desert_textures: Array = [
	preload("res://assets/environnement/small_variations/dead_bush.png"),
	preload("res://assets/environnement/small_variations/rock_01.png")
]

# Biomes
var biomes: Dictionary = {
	"grass": {
		"color": Color(0.471, 0.635, 0.322, 1),
	},
	"desert": {
		"color": Color(1, 0.86, 0.56, 1)
	}
}

# Attributes
var blank_texture = preload("res://assets/white_pixel.png")

var atmosphere_shader: Resource = preload("res://shaders/atmosphere.gdshader")
var planet_shadow_shader: Resource = preload("res://shaders/planet_shadow.gdshader")

var noise: FastNoiseLite
var temperature_noise: CircularNoise


# Functions
func get_terrain_height(theta: float) -> float:
	var x: float = cos(theta)
	var y: float = -sin(theta)
	
	var height: float = 0
	var frequency: float = roughness
	var amplitude: float = 1

	for i in range(number_of_layers):
		height += noise.get_noise_2d(x * frequency, y * frequency) * amplitude
		frequency *= roughness
		amplitude *= persistence

	height = height * noise_strenght + radius
	return height


func get_vertex_coordinates(theta: float) -> Vector2:
	var height: float = get_terrain_height(theta)
	
	var x: float = cos(theta) * height 
	var y: float = -sin(theta) * height
	
	return Vector2(x, y)


func create_polygon2d(color: Color) -> Polygon2D:
	var polygon: Polygon2D = Polygon2D.new()

	polygon.color = color
	polygon.texture = blank_texture 
	
	polygon.set_polygon([Vector2(0, 0)])
	polygon.set_uv([Vector2(0.5, 0.5)])
	polygon.material = ShaderMaterial.new()
	polygon.material.shader = planet_shadow_shader

	add_child(polygon)
	return polygon


func place_sprite(texture: Texture, theta: float) -> void:
	var sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.rotation = (get_vertex_coordinates(theta) - get_vertex_coordinates(theta - (2 * PI) / vertex_count)).angle() + PI
	sprite.position = get_vertex_coordinates(theta)
	sprite.z_index = -1
	
	add_child(sprite)


func place_background_sprite(texture: Texture, theta: float) -> void:
	var sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.rotation = -theta - 3 * PI / 2

	var depth: float = (1 - randf() / 10)
	sprite.position = get_vertex_coordinates(theta) * (depth / 2 + 0.5)

	sprite.scale = Vector2(depth, depth)
	sprite.z_index = 1
	add_child(sprite)


func get_biome(theta: float) -> String:
	var temperature: float = temperature_noise.get_noise(theta)

	if temperature > 0.5:
		return "grass"
	else:
		return "desert"


func _ready():
	# Get vertex count
	vertex_count = max(vertex_count, 3)
	
	# Set random seed
	if noise_seed == -1:
		noise_seed = randi_range(0, 2 ** 16)
	
	# Create noises
	noise = FastNoiseLite.new()
	noise.set_seed(noise_seed)
	noise.set_noise_type(FastNoiseLite.TYPE_SIMPLEX)

	temperature_noise = CircularNoise.new(noise_seed + 1, temperature_frequency)

	# Generate planet geometry
	var step: float = (2 * PI) / vertex_count

	var current_biome: String = get_biome(0)
	var current_polygon: Polygon2D = create_polygon2d(biomes[current_biome]["color"])
	
	var global_polygon: PackedVector2Array = []
	var polygon: PackedVector2Array = current_polygon.get_polygon()
	var uv: PackedVector2Array = current_polygon.get_uv()
	
	for i in range(vertex_count + 1 / 2 + 1):
		# Get angle
		var theta: float = i * step

		# Get vertex and uv position
		var vertex_position = get_vertex_coordinates(theta)
		var uv_position = Vector2(vertex_position.x, vertex_position.y) / radius / 2 + Vector2(0.5, 0.5)
		
		global_polygon.append(vertex_position)
		polygon.append(vertex_position)
		uv.append(uv_position)
		
		# Add folliage
		if randf() < tree_density:
			if current_biome == "grass":
				place_sprite(load("res://assets/environnement/tree.png"), theta)
			else:
				place_sprite(load("res://assets/environnement/cactus.png"), theta)

		if randf() < grass_density and current_biome == "grass":
			place_sprite(grass_textures[randi_range(0, grass_textures.size() - 1)], theta)
		
		elif randf() < grass_density / 10 and current_biome == "desert":
			place_sprite(load("res://assets/environnement/dead_bush.png"), theta)

		# Add background folliage
		if randf() < grass_density and current_biome == "grass":
			place_background_sprite(small_grass_textures[randi_range(0, small_grass_textures.size() - 1)], theta)

		elif randf() < grass_density / 10 and current_biome == "desert":
			place_background_sprite(small_desert_textures[randi_range(0, small_desert_textures.size() - 1)], theta)
		
		# Get next biome
		var biome: String = get_biome(theta + step)
		if biome != current_biome:
			current_polygon.set_polygon(polygon)
			current_polygon.set_uv(uv)

			current_biome = biome
			current_polygon = create_polygon2d(biomes[current_biome]["color"])

			polygon = current_polygon.get_polygon()
			uv = current_polygon.get_uv()

			polygon.append(vertex_position)
			uv.append(uv_position)
	
	current_polygon.set_polygon(polygon)
	current_polygon.set_uv(uv)

	# Set up collision
	$AnimatableBody2D/CollisionPolygon2D.set_polygon(global_polygon)
	
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
