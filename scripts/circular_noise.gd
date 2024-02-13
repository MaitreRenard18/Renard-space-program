class_name CircularNoise

var step: float
var points: Array = []


func _init(seed: int, frequency: float) -> void:
	var random_number_generator := RandomNumberGenerator.new()
	random_number_generator.seed = seed
	
	step = (2 * PI) / frequency
	
	for i in range(frequency):
		points.append(random_number_generator.randf())


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


func _interpolate(w: float, x0: float, x1: float) -> float:
	return x0 + (x1 - x0) * _smoothstep(w)
