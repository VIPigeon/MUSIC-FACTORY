extends Control

signal base_game_started
signal speed_up_started


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == Key.KEY_Z:
			base_game_started.emit()
		elif event.keycode == Key.KEY_X:
			speed_up_started.emit()
