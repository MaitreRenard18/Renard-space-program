class_name EarthGeneration
extends Node2D


@export var noise_seed: int = -1
@export var planet_radius: float = 1000
@export var noise_strenght: float = 0.01
@export var noise_frequency: float = 0.01


@onready var max_planet_radius: float = planet_radius + noise_strenght
var noise: FastNoiseLite


func get_biome(x: float, y: float) -> int:
	x = int(x - global_position.x)
	y = int(y - global_position.y)

	var noise_value: float

	var distance: float = sqrt(x ** 2 + y ** 2)
	if distance > planet_radius:
		x *= planet_radius / distance
		y *= planet_radius / distance

		noise_value = noise.get_noise(x * noise_frequency, y * noise_frequency)
		if noise_value * noise_strenght + planet_radius < distance:
			return -1

		return int(noise_value > 0)

	noise_value = noise.get_noise(x * noise_frequency, y * noise_frequency)
	return int(noise_value > 0)


func get_biome_color(x: float, y: float) -> Color:
	var biome: int = get_biome(x, y)
	if biome == -1:
		return Color(0, 0, 0)

	return Color(biome, 0, 1 - biome)


func _ready():
	if noise_seed == -1:
		noise_seed = randi()

	noise = FastNoiseLite.new()
	noise.set_seed(noise_seed)
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
