extends RigidBody2D

var G = 6.6743 * pow(10, -2)

@export_category("Object setting")
@export var initial_velocity:Vector2 = Vector2.ZERO
@export var is_sun:bool = true
@export var is_object:bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	linear_velocity = initial_velocity
	Globals.celestial_bodies.append(self)		
	
func _physics_process(delta):
	if !is_sun:
		Gravity(delta)
		explosion(delta)
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func explosion(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			#for body in Globals.celestial_bodies:
		for otherbody in Globals.celestial_bodies:
			
			if otherbody != self:
				var otherbodyMass = otherbody.mass
				var direction = position - otherbody.position
				var distance = direction.length()
				var forceMag = G * ((mass * otherbodyMass) / (distance * distance))
				var force = direction.normalized() * forceMag * 9999
				
				otherbody.apply_central_force(-force)
