extends TileMap

@export var radius: int = 10;

var source_id := 0;


func _ready():
	var height_noise = FastNoiseLite.new();
	height_noise.noise_type = height_noise.TYPE_SIMPLEX;
	
	for x in range(-radius, radius + 1):
		var theta := acos(x / radius);
		var y := sin(theta) * radius;
		
		print(x, " ", theta, " ", y)
		set_cell(0, Vector2i(x, y), source_id, Vector2i(0, 0));
		set_cell(0, Vector2i(x, -y), source_id, Vector2i(0, 0));


func _process(delta):
	pass
