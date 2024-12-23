extends CharacterBody2D

@export var player_sprite: AnimatedSprite2D

@export var player_camera: PackedScene
@export var camera_height = -50

@export var present_scene: PackedScene
var current_present: Node = null

var is_time_frozen = false
@export var freeze_timer: Timer

@export var movement_speed = 300
@export var gravity = 30
@export var jump_strength = 600
@export var max_jumps = 1

var owner_id = 1
var jump_count = 0
var camera_instance
var direction = true
var is_free = true

@onready var initial_sprite_scale = player_sprite.scale

func _enter_tree():
	owner_id = name.to_int()
	set_multiplayer_authority(owner_id)
	if owner_id != multiplayer.get_unique_id():
		return
	
	
	camera_instance = player_camera.instantiate()
	camera_instance.global_position.y = camera_height
	get_tree().current_scene.add_child.call_deferred(camera_instance)
	
func _process(_delta):
	if multiplayer.multiplayer_peer == null:
		return 
	
	if owner_id != multiplayer.get_unique_id():
		return
		
	camera_instance.global_position.x = global_position.x

func _physics_process(_delta):
	if owner_id != multiplayer.get_unique_id():
		return
		
	var horizontal_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	velocity.x = horizontal_input * movement_speed
	velocity.y += gravity
	
	freeze_time()
	throw_present()
	shrink()
	handle_movement_state()
	move_and_slide()
	face_movement_direction(horizontal_input)
			
func set_up_camera():
	camera_instance = player_camera.instantiate()
	camera_instance.global_position.y = camera_height
	get_tree().current_scene.add_child.call_deferred(camera_instance)
	
func update_camera_pos():
	camera_instance.global_position.x = global_position.x
	
func handle_movement_state():
	var is_falling = velocity.y > 0.0 and not is_on_floor()
	var is_jumping = Input.is_action_just_pressed("jump") and is_on_floor()
	var is_double_jumping = Input.is_action_just_pressed("jump") and is_falling and jump_count < max_jumps
	var is_jump_canceled = Input.is_action_just_released("jump") and velocity.y < 0.0
	var is_idle = is_on_floor() and is_zero_approx(velocity.x)
	var is_walking = is_on_floor() and not is_zero_approx(velocity.x)
	
	if is_jumping and is_free:
		player_sprite.play("Jump")
	elif is_double_jumping and is_free:
		player_sprite.play("Jump")
	elif is_walking and is_free:
		player_sprite.play("Walk")
	elif is_falling and is_free:
		player_sprite.play("Fall")
	elif is_idle and is_free:
		player_sprite.play("Idle")
	
	if is_jumping:
		jump_count += 1
		velocity.y = -jump_strength
	elif is_double_jumping:
		if jump_count <= max_jumps:
			velocity.y = -jump_strength
			jump_count += 1
	elif is_jump_canceled:
		velocity.y = 0.0
	elif is_on_floor():
		jump_count = 0
	
func face_movement_direction(horizontal_input):
	if not is_zero_approx(horizontal_input):
		if horizontal_input < 0:
			direction = false  # Facing left
			player_sprite.scale = Vector2(-initial_sprite_scale.x, initial_sprite_scale.y)
		else:
			direction = true  # Facing right
			player_sprite.scale = initial_sprite_scale

func shrink():
	var is_shrunk = Input.is_action_pressed("shrink")
	var original_scale = Vector2(1, 1)
	var shrunk_scale = Vector2(0.5, 0.5)
	if is_shrunk:
		scale = shrunk_scale
	else:
		scale = original_scale

func throw_present():
	var is_throwing = Input.is_action_just_pressed("throw")
	if is_throwing:
		
		if current_present:
			current_present.queue_free()
			
		var present = present_scene.instantiate()
		var top_offset = Vector2(0, -50)
		present.global_position = global_position + top_offset
		var throw_direction = Vector2(300, 0) if direction else Vector2(-300, 0)
		if present.has_method("set_linear_velocity"):
			present.set_linear_velocity(throw_direction)
		get_tree().current_scene.add_child(present)
		current_present = present
		is_free = false
		player_sprite.play("Throw")
		
func freeze_time():
	var is_frozen = Input.is_action_just_pressed("freeze")
	if is_frozen:
		is_time_frozen = !is_time_frozen
		for obj in get_tree().get_nodes_in_group("freezable"):
			if obj.has_method("set_time_frozen"):
				obj.set_time_frozen(is_time_frozen)
		if is_time_frozen:
			freeze_timer.start(5.0)
		else:
			freeze_timer.stop()
			
func _on_freeze_timer_timeout():
	if is_time_frozen:
		is_time_frozen = false
		for obj in get_tree().get_nodes_in_group("freezable"):
			if obj.has_method("set_time_frozen"):
				obj.set_time_frozen(is_time_frozen)

func _on_animated_sprite_2d_animation_finished():
	is_free = true
