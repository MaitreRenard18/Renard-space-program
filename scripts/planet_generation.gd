@tool
extends MeshInstance2D

@export var RESOLUTION := 1024;
@export var RADIUS := 2;
@export var NOISE_STRENGHT := .01;
@export var FREQUENCY := 1;

# Called when the node enters the scene tree for the first time.
func _ready():
	var noise = FastNoiseLite.new();
	noise.noise_type = noise.TYPE_PERLIN;
	noise.seed = randi_range(0, 1024);
	
	var surface_tool = SurfaceTool.new();
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES);
	
	surface_tool.add_vertex(Vector3(0, 0, 0));
	for i in range(RESOLUTION + 1):
		var angle := i * (2 * PI / RESOLUTION);
		var noise_var := minf(noise.get_noise_1d((i % RESOLUTION / 2) * FREQUENCY) * NOISE_STRENGHT + 1, 1);
		
		surface_tool.add_vertex(Vector3(cos(angle) * RADIUS * noise_var, 
										sin(angle) * RADIUS * noise_var, 0));

	for i in range(RESOLUTION + 1):
		surface_tool.add_index(i);
		surface_tool.add_index(i + 1);
		surface_tool.add_index(0);
	
	surface_tool.index();
	mesh = surface_tool.commit();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
