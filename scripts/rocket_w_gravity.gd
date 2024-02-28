extends RigidBody2D

var G = 6.6743 * pow(10,-2)
var initial_velocity:Vector2 = Vector2(200,100)
var is_sun:bool = false

func _ready():
	linear_velocity = initial_velocity
	Globals.celestial_bodies.append(self)

func _physics_process(delta):
	if !is_sun:
		movement(delta)
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
			
func movement(delta):
	var direction = get_global_mouse_position() - position
	var force = direction*100
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): 
		apply_central_force(force)
		
