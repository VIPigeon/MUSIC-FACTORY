extends Control

@export var swatches_root: Control
@export var colors: Array[Color]

var color_swatch_scene := preload("uid://cxwb5lhhs4y5f")


func _ready() -> void:
	var color_count := 0
	var current_hbox: HBoxContainer = null
	for color in colors:
		if color_count % 4 == 0:
			var hbox := HBoxContainer.new()
			hbox.alignment = BoxContainer.ALIGNMENT_CENTER
			swatches_root.add_child(hbox)
			current_hbox = hbox

		var color_swatch := color_swatch_scene.instantiate()
		current_hbox.add_child(color_swatch)
		color_swatch.set_color(color)

		color_count += 1
