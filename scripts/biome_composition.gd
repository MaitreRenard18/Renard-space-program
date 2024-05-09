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
