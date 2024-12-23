extends Node2D

@export var is_open = true
@export var open_door: Sprite2D
@export var closed_door: Sprite2D

func _on_area_2d_area_entered(area: Area2D) -> void:
	if not multiplayer.is_server():
		return
	if is_open:
		return
	is_open = true
	#area.owner.queue_free()
	set_door_properties()
	
func set_door_properties():
	open_door.visible = is_open
	closed_door.visible = !is_open


func _on_multiplayer_synchronizer_delta_synchronized() -> void:
	set_door_properties()
