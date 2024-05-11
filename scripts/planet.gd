class_name Planet
extends StaticBody2D


@export_category("Generation Settings")
@export var world_seed: int = -1
@export var planet_radius: float
@export var collision_resolution: int
var collision_shape: CollisionPolygon2D

@export_category("Height Map Settings")
var height_map: NoiseTexture2D
var height_map_image: Image
@export var texture_size: int
@export var frequency: float
@export var noise_strenght: float

@export_category("Environnement Settings")
@export var biomes: BiomeCollection
@export var sea_level: float
@export var has_atmosphere: bool


# Shaders
const ATMOSPHERE_SHADER: Shader = preload("res://shaders/atmosphere.gdshader")
const PLANET_RENDERER_SHADER: Shader = preload("res://shaders/planet_renderer.gdshader")

# Variables
@onready var current_camera: Camera2D = get_viewport().get_camera_2d()
var planet_renderer: ColorRect


# Utils
func map(value: float, in_min: float, in_max: float, out_min: float, out_max: float) -> float:
	return (value - in_min) / (in_max - in_min) * (out_max - out_min) + out_min


# Generation
func get_noise_value(theta: float) -> float:
	var x: int = int(map(cos(theta), -1, 1, 0, texture_size - 1))
	var y: int = int(map(sin(theta), -1, 1, 0, texture_size - 1))

	return height_map_image.get_pixel(x, y).r


func get_terrain_height(theta: float) -> float:
	if get_noise_value(theta) < sea_level:
		return planet_radius

	return map(get_noise_value(theta), .45, 1, 0, 1) * noise_strenght + planet_radius


func get_biome(theta: float) -> Biome:
	var noise_value: float = get_noise_value(theta)
	return biomes.get_biome(noise_value)


func get_terrain_angle(theta: float) -> float:
	var pos0 = Vector2(cos(theta), sin(theta)) * get_terrain_height(theta)
	var pos1 = Vector2(cos(theta + 0.01), sin(theta + 0.01)) * get_terrain_height(theta + 0.01)
	
	return (pos1 - pos0).angle()


func place_sprite(texture: Texture, theta: float) -> void:
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = texture
	sprite.position = Vector2(cos(theta), sin(theta)) * (get_terrain_height(theta))
	sprite.rotation = get_terrain_angle(theta)
	sprite.z_index = -1
	add_child(sprite)


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

	# Generate colision
	# TODO: Remove collision with water
	collision_resolution = max(collision_resolution, 3)
	collision_shape = CollisionPolygon2D.new()
	var collision_points: PackedVector2Array = []

	for i in range(collision_resolution):
		var theta = i * 2 * PI / collision_resolution

		var height = get_terrain_height(theta)
		var x: int = int(cos(theta) * height)
		var y: int = int(sin(theta) * height)
		
		collision_points.append(Vector2(x, y))

		var biome = get_biome(theta)
		var elements = biome.get_biome_composition().get_random_elements()
		for element in elements:
			place_sprite(element, theta)

	collision_shape.set_polygon(collision_points)
	collision_shape.z_index = 10
	add_child(collision_shape)

	# Set up atmosphere
	if has_atmosphere:
		var atmosphere: ColorRect = ColorRect.new()
		atmosphere.size = Vector2(2.75 * planet_radius, 2.75 * planet_radius)
		atmosphere.position = -atmosphere.size / 2
		atmosphere.material = ShaderMaterial.new()
		atmosphere.material.shader = ATMOSPHERE_SHADER
		atmosphere.z_index = -2
		atmosphere.rotation = 0
		add_child(atmosphere)

	# Set up renderer
	planet_renderer = ColorRect.new()
	planet_renderer.set_anchors_preset(Control.PRESET_FULL_RECT)
	planet_renderer.material = ShaderMaterial.new()
	planet_renderer.material.shader = PLANET_RENDERER_SHADER

	planet_renderer.material.set_shader_parameter("height_map", height_map)
	planet_renderer.material.set_shader_parameter("planet_position", position)
	planet_renderer.material.set_shader_parameter("planet_radius", planet_radius)
	planet_renderer.material.set_shader_parameter("noise_strenght", noise_strenght)
	planet_renderer.material.set_shader_parameter("biome_ramp", biomes.get_color_gradient(64))
	planet_renderer.material.set_shader_parameter("sea_level", sea_level)

	current_camera.get_node("PlanetRendering").add_child(planet_renderer)
