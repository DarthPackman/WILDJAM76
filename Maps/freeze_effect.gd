extends ColorRect

var time_frozen = false

func _ready():
	add_to_group("freezable")
	
func set_time_frozen(frozen: bool):
	time_frozen = frozen
	visible = time_frozen  # Show the overlay when time is frozen
