extends Resource
class_name BiomeCollection

@export var offsets: PackedFloat32Array
@export var biomes: Array[Biome]

func _sort() -> void:
	for i: int in range(1, offsets.size()):
		var j: int = i
		
		while j > 0 and offsets[j] < offsets[j - 1]:
			var temp_offset: float = offsets[j]
			var temp_biome: Biome = biomes[j]
			
			offsets[j] = offsets[j - 1]
			biomes[j] = biomes[j - 1]
			
			offsets[j - 1] = temp_offset
			biomes[j - 1] = temp_biome
			
			j -= 1


func get_biomes() -> Array[Biome]:
	return biomes


func get_offsets() -> PackedFloat32Array:
	return offsets


func set_offsets(value: PackedFloat32Array) -> void:
	offsets = value
	emit_changed()


func set_biomes(value: Array[Biome]) -> void:
	biomes = value
	emit_changed()


func add_biome(offset: float, biome: Biome) -> void:
	offsets.append(offset)
	biomes.append(biome)
	emit_changed()


func get_biome(offset: float) -> Biome:
	if offsets.size() == 0:
		return null

	for i: int in range(offsets.size()):
		if offsets[i] > offset:
			return biomes[i - 1]
	
	return biomes[-1]


func get_color_gradient(width: int = 512) -> GradientTexture1D:
	var gradient: Gradient = Gradient.new()
	gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
	
	gradient.offsets = []
	gradient.colors = []

	for i in range(biomes.size()):
		gradient.add_point(offsets[i], biomes[i].biome_color)

	var texture: GradientTexture1D = GradientTexture1D.new()
	texture.width = width
	texture.gradient = gradient
	
	return texture


func get_biome_by_name(name: String) -> Biome:
	for biome in biomes:
		if biome.name == name:
			return biome
	
	return null


func changed() -> void:
	_sort()
