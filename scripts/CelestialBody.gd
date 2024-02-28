extends RigidBody2D

var G = 6.6743 * pow(10, -2)
var initial_velocity:Vector2 = Vector2.ZERO
var is_sun:bool = true

func _ready():
	linear_velocity = initial_velocity
	Globals.celestial_bodies.append(self)

func _physics_process(delta):
	if !is_sun:
		Gravity(delta)
	else:
		linear_velocity = Vector2.ZERO

func Gravity(delta):
	#for body in Globals.celestial_bodies:
		
	for otherbody in Globals.celestial_bodies:
		#print(otherbody)
		if otherbody != self:
				
			var otherbodyMass = otherbody.mass
			var direction = position - otherbody.position
			var distance = direction.length()
			var forceMag = G * ((mass * otherbodyMass) / (distance * distance))
			var force = direction.normalized() * forceMag
			
			apply_central_force(-force)


