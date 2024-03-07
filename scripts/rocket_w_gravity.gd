extends RigidBody2D

var G = 6.6743 * pow(10,-2)
var force = Vector2.ZERO
var rotation_direction = 0



@export_category("Object setting")
@export var initial_velocity:Vector2 = Vector2.ZERO
@export var is_sun:bool = true
@export var is_object:bool = false
@export var spin_power:int = 100000
@export var engine_power:int = 5000

func _ready():
	linear_velocity = initial_velocity
	Globals.celestial_bodies.append(self)

func _physics_process(delta):
	if !is_sun:
		movement(delta)
		Gravity(delta)
		print(linear_velocity)
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
	if Input.is_action_pressed("up"): 
		force = transform.x * engine_power
		apply_force(force)
	rotation_direction = Input.get_axis("left","right")
	apply_torque(rotation_direction * spin_power)
		
