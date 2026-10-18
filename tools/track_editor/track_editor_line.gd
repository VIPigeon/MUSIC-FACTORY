class_name TrackEditorLine extends HBoxContainer

signal changed

var color_on: Color
var color_off: Color
var beats_per_tact: int
var tact_count: int

var toggle_scene := preload("uid://cswj3rcyii0es")
var tact: String


func _ready() -> void:
	tact = ""
	add_tact()


func add_tact() -> void:
	tact += '0'.repeat(beats_per_tact)
	
	for i in range(beats_per_tact):
		var toggle := toggle_scene.instantiate()
		toggle.color_on = color_on
		toggle.color_off = color_off
		toggle.toggled.connect(func(state: bool):
			_on_toggle(i + beats_per_tact * tact_count, state)
		)
		add_child(toggle)
		
	tact_count += 1


func _on_toggle(index: int, state: bool) -> void:
	tact[index] = '1' if state else '0'
	changed.emit()
