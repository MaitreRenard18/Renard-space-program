extends Node2D
class_name Grass

@export var random_textures: Array[Texture2D]


func _ready():
	$Grass.texture = random_textures[randi_range(0, random_textures.size() - 1)]


func _process(delta):
	pass


func destroy():
	pass
