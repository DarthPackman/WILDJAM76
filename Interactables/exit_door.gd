extends Node2D

class_name ExitDoor

signal all_players_finished

@export var is_open = true
@export var open_door: Sprite2D
@export var closed_door: Sprite2D
@export var exit_area: Area2D

var finished_players = 0

func _on_area_2d_area_entered(area: Area2D) -> void:
	if not multiplayer.is_server():
		return
	if is_open:
		return
	is_open = true
	exit_area.monitoring = true
	area.owner.queue_free()
	set_door_properties()
	
func set_door_properties():
	open_door.visible = is_open
	closed_door.visible = !is_open


func _on_multiplayer_synchronizer_delta_synchronized() -> void:
	set_door_properties()


func _on_exit_area_2d_body_entered(body: Node2D) -> void:
	body.queue_free()
	finished_players += 1
	if finished_players > len(multiplayer.get_peers()):
		all_players_finished.emit()
