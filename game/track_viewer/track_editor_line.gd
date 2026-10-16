class_name TrackEditorLine extends HBoxContainer

signal changed

var color_on: Color
var color_off: Color
var beats_per_tact: int

var toggle_scene := preload("uid://cswj3rcyii0es")
var tact: String


func _ready() -> void:
	tact = '0'.repeat(beats_per_tact)
	for i in range(beats_per_tact):
		var toggle := toggle_scene.instantiate()
		toggle.color_on = color_on
		toggle.color_off = color_off
		toggle.toggled.connect(func(state: bool):
			_on_toggle(i, state)
		)
		add_child(toggle)


func _on_toggle(index: int, state: bool) -> void:
	tact[index] = '1' if state else '0'
	changed.emit()
