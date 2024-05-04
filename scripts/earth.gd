class_name Earth
extends StaticBody2D

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

@onready var current_camera: CustomCamera2D = get_viewport().get_camera_2d()

var atmosphere_shader: Shader = preload("res://shaders/atmosphere.gdshader")
var planet_shadow_shader: Shader = preload("res://shaders/planet_shadow.gdshader")


func map(value: float, in_min: float, in_max: float, out_min: float, out_max: float) -> float:
	return (value - in_min) / (in_max - in_min) * (out_max - out_min) + out_min


func get_noise_value(theta: float) -> float:
	var x: int = int(map(cos(theta), -1, 1, 0, texture_size - 1))
	var y: int = int(map(sin(theta), -1, 1, 0, texture_size - 1))

	return height_map_image.get_pixel(x, y).r


# TODO: fix random holes in the terrain
func get_terrain_height(theta: float) -> float:
	if get_biome(theta) == "water":
		return planet_radius + noise_strenght * .45

	return get_noise_value(theta) * noise_strenght + planet_radius


func get_biome(theta: float) -> String:
	var noise_value: float = get_noise_value(theta)

	if noise_value > 0.5:
		return "grass"
	elif noise_value > 0.45:
		return "sand"
	else:
		return "water"


func _ready():
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
	
	collision_shape.set_polygon(collision_points)
	add_child(collision_shape)

	# Set up atmosphere
	var atmosphere: ColorRect = ColorRect.new()
	atmosphere.size = Vector2(2.75 * planet_radius, 2.75 * planet_radius)
	atmosphere.position = -atmosphere.size / 2
	atmosphere.material = ShaderMaterial.new()
	atmosphere.material.shader = atmosphere_shader
	atmosphere.z_index = -1
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
