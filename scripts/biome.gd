extends Resource
class_name Biome

@export var biome_name: String
@export var biome_color: Color
@export var biome_composition: BiomeComposition


func get_biome_name() -> String:
	return biome_name


func get_biome_color() -> Color:
	return biome_color


func get_biome_composition() -> BiomeComposition:
	return biome_composition


func set_biome_name(name: String) -> void:
	biome_name = name


func set_biome_color(color: Color) -> void:
	biome_color = color


func set_biome_composition(composition: BiomeComposition) -> void:
	biome_composition = composition
