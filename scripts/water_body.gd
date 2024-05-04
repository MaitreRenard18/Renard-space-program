class_name WaterBody
extends Node2D

@export var color: Color = Color("#0086f4")

@export var planet_center: Vector2 = Vector2(0, 0)
@onready var relative_position: Vector2 = planet_center - position
@onready var angle: float = atan2(relative_position.x, relative_position.y)
@onready var planet_radius: float = position.rotated(angle).y

@export var k: float = 0.015
@export var d: float = 0.03
@export var spread: float = 0.0003

@export var passes: int = 8

@export var body_lenght: float = 180
@export var spring_number: int = 6 
@onready var distance_between_springs: float = body_lenght / spring_number

var water_polygon: Polygon2D
var water_line: Line2D
var springs: Array[WaterSpring] = []


func create_water_spring(spring_position: Vector2) -> WaterSpring:
	var spring: WaterSpring = WaterSpring.new()
	spring.set_planet_center(planet_center)
	spring.position = spring_position
	
	springs.append(spring)
	add_child(spring)
	
	return spring


func _ready() -> void:
	water_polygon = Polygon2D.new()
	water_polygon.color = color
	add_child(water_polygon)
	
	water_line = Line2D.new()
	water_line.default_color = Color(0.7, 0.8, 1)
	water_line.width = 1
	add_child(water_line)
	
	var polygon: PackedVector2Array = [planet_center - position]
	
	var delta_theta: float = distance_between_springs / planet_radius
	for i in range(spring_number):
		var theta: float = -angle - i * delta_theta + PI / 2
		
		var x: float = relative_position.x + planet_radius * cos(theta)
		var y: float = relative_position.y + planet_radius * sin(theta)
		var spring_position: Vector2 = Vector2(x, y)

		create_water_spring(spring_position)

	splash(10, 20)


func _physics_process(_delta: float) -> void:
	# Update the water springs
	for spring in springs:
		spring.water_update(k, d)
	
	return
	# Wave propagation
	var left_deltas: Array[float] = []
	var right_deltas: Array[float] = []
	
	for i in range(springs.size()):
		left_deltas.append(0)
		right_deltas.append(0)
	
	for _pass in range(passes):
		for i in range(springs.size()):	
			if i > 0:
				left_deltas[i] = spread * (springs[i].get_height() - springs[i-1].get_height())
				springs[i-1].velocity += left_deltas[i]
				
			if i < springs.size() - 1:
				right_deltas[i] = spread * (springs[i].get_height() - springs[i+1].get_height())
				springs[i+1].velocity += right_deltas[i]


func _process(_delta):
	var polygon: PackedVector2Array = [planet_center - position]
	var line: PackedVector2Array = []
	
	for i in range(1, springs.size()):
		polygon.append(springs[i].position)
		line.append(springs[i].position)
		
	water_polygon.set_polygon(polygon)
	water_line.set_points(line)


func splash(index: int, speed: float) -> void:
	if 0 <= index and index < springs.size():
		springs[index].velocity += speed
