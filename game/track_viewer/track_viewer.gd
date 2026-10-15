class_name TrackViewer extends Control

@export var track: TowerTrack
@export var track_line_container: Container

var track_line_scene := preload("uid://pdg8fsjjca83")

var colors: Array[Color] = [Color.YELLOW, Color.LIME, Color.INDIAN_RED, Color.SKY_BLUE, Color.WEB_PURPLE]


func _ready() -> void:
	var color_index := 0
	for sound in track.sounds:
		var track_line := track_line_scene.instantiate()
		track_line.color_on = colors[color_index]
		track_line.color_off = Color.BLACK
		color_index += 1
		color_index %= len(colors)
		track_line_container.add_child(track_line)
	
