class_name Earth
extends StaticBody2D

# Settings
@export_category("Generation Settings")
@export var world_seed: int = -1
@export var planet_radius: float
@export var collision_resolution: int = 64
var collision_shape: CollisionPolygon2D

@export_category("Height Map Settings")
var height_map: NoiseTexture2D
var height_map_image: Image
@export var texture_size: int
@export var frequency: float
@export var noise_strenght: float

@export_category("Foliage Settings")
@export var tree_density: float
@export var grass_density: float

# Shaders
var atmosphere_shader: Shader = preload("res://shaders/atmosphere.gdshader")
var planet_shadow_shader: Shader = preload("res://shaders/planet_shadow.gdshader")

# Variables
@onready var current_camera: CustomCamera2D = get_viewport().get_camera_2d()

# Functions
func map(value: float, in_min: float, in_max: float, out_min: float, out_max: float) -> float:
	return (value - in_min) / (in_max - in_min) * (out_max - out_min) + out_min


func get_noise_value(theta: float) -> float:
	var x: int = int(map(cos(theta), -1, 1, 0, texture_size - 1))
	var y: int = int(map(sin(theta), -1, 1, 0, texture_size - 1))

	return height_map_image.get_pixel(x, y).r


func get_terrain_height(theta: float) -> float:
	if get_biome(theta) == "water":
		return planet_radius

	return map(get_noise_value(theta), .45, 1, 0, 1) * noise_strenght + planet_radius


func get_biome(theta: float) -> String:
	var noise_value: float = get_noise_value(theta)

	if noise_value > 0.5:
		return "grass"
	elif noise_value > 0.45:
		return "sand"
	else:
		return "water"


func get_terrain_angle(theta: float) -> float:
	var pos0 = Vector2(cos(theta), sin(theta)) * get_terrain_height(theta)
	var pos1 = Vector2(cos(theta + 0.01), sin(theta + 0.01)) * get_terrain_height(theta + 0.01)
	
	return (pos1 - pos0).angle()


# TODO: Replace folliage generation with more generic system
var tree_sprites = [preload("res://assets/environnement/tree.png")]
func place_tree(theta: float) -> void:
	var tree: Sprite2D = Sprite2D.new()
	tree.texture = tree_sprites[randi() % tree_sprites.size()]
	tree.position = Vector2(cos(theta), sin(theta)) * get_terrain_height(theta)
	tree.rotation = get_terrain_angle(theta)
	tree.z_index = -1
	add_child(tree)


var grass_sprites = [preload("res://assets/environnement/grass_01.png"), 
					 preload("res://assets/environnement/grass_02.png"),
					 preload("res://assets/environnement/flower_01.png"),
					 preload("res://assets/environnement/rock_01.png")
					]
func place_grass(theta: float) -> void:
	var grass: Sprite2D = Sprite2D.new()
	grass.texture = grass_sprites[randi() % grass_sprites.size()]
	grass.position = Vector2(cos(theta), sin(theta)) * get_terrain_height(theta)
	grass.rotation = get_terrain_angle(theta)
	grass.z_index = -1
	add_child(grass)


var palmtree_sprites = [preload("res://assets/environnement/palmtree.png")]
func place_palmtree(theta: float) -> void:
	var palmtree: Sprite2D = Sprite2D.new()
	palmtree.texture = palmtree_sprites[randi() % palmtree_sprites.size()]
	palmtree.position = Vector2(cos(theta), sin(theta)) * get_terrain_height(theta)
	palmtree.rotation = get_terrain_angle(theta)
	palmtree.z_index = -1
	add_child(palmtree)


func _ready():
	# Change the seed if it is not set
	if world_seed == -1:
		world_seed = randi()

	# Create the height map
	height_map = NoiseTexture2D.new()
	height_map.height = texture_size
	height_map.width = texture_size
	height_map.noise = FastNoiseLite.new()
	height_map.noise.seed = world_seed
	height_map.noise.frequency = frequency
	height_map.noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	height_map.generate_mipmaps = false
	
	await height_map.changed
	height_map_image = height_map.get_image()

	# Set up rendering
	current_camera.add_body(self)

	# Generate colision
	# TODO: Remove collision with water
	collision_resolution = max(collision_resolution, 3)
	collision_shape = CollisionPolygon2D.new()
	var collision_points: PackedVector2Array = []

	for i in range(collision_resolution):
		var theta = i * 2 * PI / collision_resolution

		var height = get_terrain_height(theta)
		var x = cos(theta) * height
		var y = sin(theta) * height
		
		collision_points.append(Vector2(x, y))

		# Place trees and grass
		if get_biome(theta) == "grass":
			if randf() < tree_density:
				place_tree(theta)

			elif randf() < grass_density:
				place_grass(theta)

		# Place cactus
		elif get_biome(theta) == "sand":
			if randf() < tree_density:
				place_palmtree(theta)

			if randf() < grass_density / 3:
				place_grass(theta)

	collision_shape.set_polygon(collision_points)
	add_child(collision_shape)

	# Set up atmosphere
	var atmosphere: ColorRect = ColorRect.new()
	atmosphere.size = Vector2(2.75 * planet_radius, 2.75 * planet_radius)
	atmosphere.position = -atmosphere.size / 2
	atmosphere.material = ShaderMaterial.new()
	atmosphere.material.shader = atmosphere_shader
	atmosphere.z_index = -2
	atmosphere.rotation = 0
	add_child(atmosphere)

	# Set up shadow
	var shadow: ColorRect = ColorRect.new()
	shadow.size = Vector2(2.75 * planet_radius, 2.75 * planet_radius)
	shadow.position = -shadow.size / 2
	shadow.material = ShaderMaterial.new()
	shadow.material.shader = planet_shadow_shader
	shadow.z_index = 1
	shadow.rotation = 0
	add_child(shadow)
