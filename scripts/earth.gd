class_name Earth
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

# Shaders
const ATMOSPHERE_SHADER: Shader = preload("res://shaders/atmosphere.gdshader")
const PLANET_SHADOW_SHADER: Shader = preload("res://shaders/planet_shadow.gdshader")
const PLANET_RENDEER_SHADER: Shader = preload("res://shaders/planet_renderer.gdshader")

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

		var height = get_terrain_height(theta) - .1
		var x = cos(theta) * height
		var y = sin(theta) * height
		
		collision_points.append(Vector2(x, y))

	collision_shape.set_polygon(collision_points)
	add_child(collision_shape)

	# Set up atmosphere
	var atmosphere: ColorRect = ColorRect.new()
	atmosphere.size = Vector2(2.75 * planet_radius, 2.75 * planet_radius)
	atmosphere.position = -atmosphere.size / 2
	atmosphere.material = ShaderMaterial.new()
	atmosphere.material.shader = ATMOSPHERE_SHADER
	atmosphere.z_index = -2
	atmosphere.rotation = 0
	add_child(atmosphere)

	# Set up shadow
	var shadow: ColorRect = ColorRect.new()
	shadow.size = Vector2(2.75 * planet_radius, 2.75 * planet_radius)
	shadow.position = -shadow.size / 2
	shadow.material = ShaderMaterial.new()
	shadow.material.shader = PLANET_SHADOW_SHADER
	shadow.z_index = 1
	shadow.rotation = 0
	add_child(shadow)

	# Set up renderer
	planet_renderer = ColorRect.new()
	planet_renderer.material = ShaderMaterial.new()
	planet_renderer.material.shader = PLANET_RENDEER_SHADER

	planet_renderer.material.set_shader_parameter("height_map", height_map)
	planet_renderer.material.set_shader_parameter("planet_position", position)
	planet_renderer.material.set_shader_parameter("planet_radius", planet_radius)
	planet_renderer.material.set_shader_parameter("noise_strenght", noise_strenght)
	planet_renderer.material.set_shader_parameter("biome_ramp", biomes.get_color_gradient(64))
	planet_renderer.material.set_shader_parameter("sea_level", sea_level)

	current_camera.add_child(planet_renderer)


func _process(_delta: float) -> void:
	current_camera = get_viewport().get_camera_2d()

	planet_renderer.scale = Vector2(1 / current_camera.zoom.x, 1 / current_camera.zoom.y)
	planet_renderer.size = get_viewport_rect().size
	planet_renderer.get_material().set_shader_parameter("camera_zoom", current_camera.zoom)
	
	planet_renderer.position = -planet_renderer.size * planet_renderer.scale / 2.0
	planet_renderer.get_material().set_shader_parameter("camera_top_left_position", planet_renderer.global_position.rotated(-current_camera.global_rotation))
	planet_renderer.get_material().set_shader_parameter("camera_rotation", current_camera.global_rotation)
