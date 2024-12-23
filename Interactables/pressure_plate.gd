extends Node2D

var bodies_on_plate = 0
@export var plate_up: Sprite2D
@export var plate_down: Sprite2D
@export var is_down = false

var time_frozen = false 
var saved_bodies_on_plate = 0 

func _ready():
	add_to_group("freezable")

func _on_area_2d_body_entered(_body: Node2D) -> void:
	#if not multiplayer.is_server():
	#	return
	bodies_on_plate += 1
	check_plate()

func _on_area_2d_body_exited(_body: Node2D) -> void:
	#if not multiplayer.is_server():
	#	return
	if time_frozen:
		return

	bodies_on_plate -= 1
	check_plate()

func check_plate():
	is_down = bodies_on_plate >= 1
	change_plate()

func change_plate():
	plate_down.visible = is_down
	plate_up.visible = !is_down

func set_time_frozen(frozen: bool):
	#if not multiplayer.is_server():
	#	return
	time_frozen = frozen
	if time_frozen:
		saved_bodies_on_plate = bodies_on_plate
	else:
		recount_bodies_on_plate()
		check_plate()

func recount_bodies_on_plate():
	var area = $Area2D
	var overlapping_bodies = area.get_overlapping_bodies()
	bodies_on_plate = overlapping_bodies.size()
	
func _on_multiplayer_synchronizer_delta_synchronized() -> void:
	change_plate()
