extends TileMap

@export var radius := 32;

var source_id := 0;


func _ready():
	var height_noise = FastNoiseLite.new();
	height_noise.noise_type = height_noise.TYPE_SIMPLEX;
	
	for x in range(-radius, 1):
		var theta := acos(float(x) / float(radius));
		var y := int(round(sin(theta) * radius));
		
		var next_theta = acos(float(x + 1) / float(radius));
		var next_y := int(round(sin(next_theta) * radius));
		
		for i in range(max(abs(next_y - y), 1)):
			if next_y < y:
				i *= -1
			
			set_cell(0, Vector2i(x, y + i), source_id, Vector2i(0, 0));
			set_cell(0, Vector2i(x, -y - i), source_id, Vector2i(0, 0));
			set_cell(0, Vector2i(-x, y + i), source_id, Vector2i(0, 0));
			set_cell(0, Vector2i(-x, -y - i), source_id, Vector2i(0, 0));

func _process(delta):
	pass
