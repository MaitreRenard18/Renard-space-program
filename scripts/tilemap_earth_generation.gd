extends TileMap

@export_category("Planet Properties")
@export var radius: int = 10_000
@export var sea_level: float = -16

@export_category("Noise Properties")
@export var noise_type: FastNoiseLite.NoiseType = FastNoiseLite.TYPE_SIMPLEX
@export var seed: int = -1
@export var noise_strenght: float = 300.0 / 300_000.0 * float(radius)
@export var noise_frequency: float = 8000.0 / 300_000.0 * float(radius)

var atmosphere_shader = preload("res://shaders/atmosphere.gdshader")

var global_height_noise = FastNoiseLite.new()
var source_id := 0

func generate_tile(pos: Vector2i) -> void:
	if get_cell_atlas_coords(0, pos) != Vector2i(-1, -1):
		return
	
	var theta := acos(float(pos.x) / float(radius))
	var height := get_height(theta)
	
	if pos.x ** 2 + pos.y ** 2 <= (radius + height) ** 2:
		var distance_to_center := sqrt(pos.x ** 2 + pos.y ** 2)

		if distance_to_center >= (radius + height) - 3:
			set_cells_terrain_connect(0, [pos], 0, 0, false)
		
		else:
			set_cell(0, pos, source_id, Vector2i(1, 1))


func get_height(theta: float) -> float:
	return global_height_noise.get_noise_1d(theta * noise_frequency) * noise_strenght


func _ready():
	position.y = radius * tile_set.tile_size.y
	
	# Set up noise
	if seed == -1:
		seed = randi_range(0, 2 ** 16)
	
	global_height_noise.seed = seed
	
	# Set atmosphere
	var atmosphere = MeshInstance2D.new()
	atmosphere.mesh = QuadMesh.new()
	atmosphere.mesh.size = Vector2(radius, radius) * 2.5 * Vector2(tile_set.tile_size)
	
	atmosphere.material = ShaderMaterial.new()
	atmosphere.material.shader = atmosphere_shader
	atmosphere.z_index = -1
	
	add_child(atmosphere)
	

func _process(delta):
	var camera := get_viewport().get_camera_2d()
	var viewport_rect := camera.get_viewport_rect()
	
	var top_left_map: Vector2i = local_to_map(camera.position.rotated(camera.rotation) - (viewport_rect.size / camera.zoom) / 2 - position.rotated(camera.rotation))
	var bottom_right_map: Vector2i = local_to_map(camera.position.rotated(camera.rotation) + (viewport_rect.size / camera.zoom) / 2 - position.rotated(camera.rotation))
	
	for x in range(top_left_map.x - 1, bottom_right_map.x + 2):
		for y in range(top_left_map.y - 1, bottom_right_map.y + 2):
			generate_tile(Vector2(x, y))
