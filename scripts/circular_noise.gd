class_name CircularNoise

var interpolation_function: int
var step: float
var points: Array = []

const SMOOTHSTEP: int = 0
const CUBIC: int = 1

func _init(seed: int, frequency: float, function: int = SMOOTHSTEP) -> void:
	interpolation_function = function
	
	var random_number_generator := RandomNumberGenerator.new()
	random_number_generator.seed = seed
	
	step = (2 * PI) / frequency
	
	for i in range(frequency):
		var rand_float = random_number_generator.randf()
		if interpolation_function == CUBIC:
			rand_float **= 3
		
		points.append(rand_float)


func get_noise(theta: float) -> float:
	theta = fmod(theta, 2 * PI)
	var w: float = theta / (PI * 2.0) * len(points)

	var x0 = int(w) % len(points)
	var x1 = (int(w) + 1) % len(points)

	var y0: float = points[x0]
	var y1: float = points[x1]
	return _interpolate(w - x0, y0, y1)


func _smoothstep(w: float) -> float:
	if w < 0.0: return 0.0
	if w > 1.0: return 1.0
	return w * w * (3.0 - 2.0 * w)


func _cubic(w: float) -> float:
	if w < 0.0: return 0.0
	if w > 1.0: return 1.0
	return w ** 3


func _interpolate(w: float, x0: float, x1: float) -> float:
	if interpolation_function == CUBIC:
		return x0 + (x1 - x0) * _cubic(w)
	
	return x0 + (x1 - x0) * _smoothstep(w)
		
		
