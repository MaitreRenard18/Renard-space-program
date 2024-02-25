class_name CircularNoise

var interpolation_function: int
var step: float
var points: Array = []


func _init(noise_seed: int, frequency: float) -> void:
	seed(noise_seed)
	step = (2 * PI) / frequency
	
	for i in range(frequency):
		var rand_float = randf()
		points.append(rand_float)


func get_noise_normal_angle(theta: float) -> float:
	var m: float = (-1 / _smoothstep_derivate(theta))
	return theta + atan(m) + (PI / 2)


func get_noise(theta: float) -> float:
	theta = fmod(theta, 2 * PI)
	var w: float = theta / (PI * 2.0) * len(points)

	var x0 = int(w) % len(points)
	var x1 = (int(w) + 1) % len(points)

	var y0: float = points[x0]
	var y1: float = points[x1]
	return _interpolate(w - x0, y0, y1)


func _smoothstep_derivate(x: float) -> float:
	return -6 * x ** 2 + 6 * x


func _smoothstep(x: float) -> float:
	if x < 0.0: return 0.0
	if x > 1.0: return 1.0
	return x * x * (3.0 - 2.0 * x)


func _interpolate(x: float, x0: float, x1: float) -> float:	
	return x0 + (x1 - x0) * _smoothstep(x)
