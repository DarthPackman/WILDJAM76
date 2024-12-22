extends RigidBody2D

var time_frozen = false
var saved_linear_velocity = Vector2.ZERO
var saved_angular_velocity = 0.0
var saved_gravity_scale = 1.0

func _ready():
	add_to_group("freezable")

func _process(delta):
	if time_frozen:
		linear_velocity = Vector2.ZERO
		angular_velocity = 0.0

func set_time_frozen(frozen):
	time_frozen = frozen
	if time_frozen:
		saved_linear_velocity = linear_velocity
		saved_angular_velocity = angular_velocity
		saved_gravity_scale = gravity_scale
		linear_velocity = Vector2.ZERO
		angular_velocity = 0.0
		gravity_scale = 0.0
		sleeping = true  
	else:
		linear_velocity = saved_linear_velocity
		angular_velocity = saved_angular_velocity
		gravity_scale = saved_gravity_scale
		sleeping = false  
