extends TileMap

@export var radius := 64;

var source_id := 0;

func get_height():
	return 0;

func _ready():
	position.y = radius * tile_set.tile_size.y * scale.y;
	
	for x in range(-radius, radius + 1):
		var y_limit = sqrt(radius ** 2 - x ** 2);
		
		for y in range(-y_limit, y_limit + 1):
			var distance_from_center = int(sqrt(x ** 2 + y ** 2));

			set_cells_terrain_connect(0, [Vector2i(x, y)], 0, 0);


func _process(delta):
	pass
