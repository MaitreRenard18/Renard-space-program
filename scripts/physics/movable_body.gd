extends RigidBody2D
class_name MovableBody


func _physics_process(_delta):
	for body in BodyHandler.get_celestial_bodies():
		var direction = body.get_global_position() - get_global_position()
		var distance = direction.length()
		
		var force = direction.normalized() * (body.gravity * 100000000 * mass) / (distance * distance)
		apply_central_force(force)
