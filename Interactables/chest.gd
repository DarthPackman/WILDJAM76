extends Node2D

@export var chest_open: Sprite2D
@export var chest_closed: Sprite2D
@export var is_closed = true

func _on_interactable_interacted():
	if is_closed:
		is_closed = false
		set_chest_properties()

func set_chest_properties():
	chest_closed.visible = is_closed
	chest_open.visible = !is_closed

func _on_multiplayer_synchronizer_delta_synchronized() -> void:
	set_chest_properties()
