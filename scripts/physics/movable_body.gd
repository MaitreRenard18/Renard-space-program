extends RigidBody2D
class_name MovableBody

func _ready():
	BodyHandler.register_movable_body(self)

func _physics_process(delta):
	for body in BodyHandler.get_celestial_bodies():
		var direction = body.get_global_position() - get_global_position()
		var distance = direction.length()
		
		# Vérifier que la distance n'est pas zéro pour éviter la division par zéro
		if distance > 0:
			# Calculer la force gravitationnelle
			var force = direction.normalized() * (body.gravity * 50000000000 * mass) / (distance * distance)
			apply_central_force(force * delta)  # Appliquer la force en tenant compte du delta
