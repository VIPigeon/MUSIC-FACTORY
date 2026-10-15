class_name TrackToggle extends ColorRect

var color_on: Color = Color.WHITE
var color_off: Color = Color.BLACK

var state: bool


func _ready() -> void:
	update_color()


func update_color() -> void:
	color = color_on if state else color_off


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		state = !state
		update_color()
