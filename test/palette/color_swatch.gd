extends Control

@onready var backdrop := $Backdrop
@onready var color_rect := $ColorRect
@onready var hex_label := $HexColor


func set_color(color: Color) -> void:
	var brightness := (color.r + color.g + color.b) / 3
	if brightness > 0.5:
		backdrop.color = Color.BLACK
	else:
		backdrop.color = Color.WHITE
	color_rect.color = color
	var hex_string := String.num_uint64(color.to_rgba32(), 16, true)
	hex_string = hex_string.trim_suffix("FF")
	hex_string = hex_string.lpad(6, "0")
	hex_label.text = hex_string
