extends Resource
class_name BiomeComposition 

@export var probabilities: PackedFloat32Array
@export var elements: Array[Resource]


func get_probabilities() -> PackedFloat32Array:
	return probabilities


func get_elements() -> Array[Resource]:
	return elements


func set_probabilities(new_probabilities: PackedFloat32Array) -> void:
	probabilities = new_probabilities


func set_elements(new_elements: Array[Resource]) -> void:
	elements = new_elements


func set_seed(world_seed: int) -> void:
	seed(world_seed)


func get_random_elements() -> Array[Resource]:
	var random_elements: Array[Resource] = []
	for i in range(probabilities.size()):
		if randf() < probabilities[i]:
			random_elements.append(elements[i])

	return random_elements
