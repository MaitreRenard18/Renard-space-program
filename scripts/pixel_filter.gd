extends Camera2D

var pixel_shader = preload("res://shaders/pixel_filter.gdshader")

var camera_filter: MeshInstance2D

# Called when the node enters the scene tree for the first time.
func _ready():
	camera_filter = MeshInstance2D.new()
	camera_filter.mesh = QuadMesh.new()
	camera_filter.scale = get_viewport().size
	
	camera_filter.material = ShaderMaterial.new()
	camera_filter.material.shader = pixel_shader
	
	camera_filter.z_index = -1
	add_child(camera_filter)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):		
	camera_filter.material.set_shader_parameter("zoom", zoom.x)
	camera_filter.material.set_shader_parameter("position", position)
	camera_filter.material.set_shader_parameter("rotation", rotation)
	
	camera_filter.scale = Vector2(get_viewport().size) / zoom
