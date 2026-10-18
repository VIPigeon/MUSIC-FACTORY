class_name TrackEditorEnemyLine extends HBoxContainer

signal play

@export var play_button: Button
@export var track_line_container: Container

var colors: Array[Color] = [Color.YELLOW, Color.LIME, Color.INDIAN_RED, Color.SKY_BLUE, Color.WEB_PURPLE]
var track_line_scene := preload("uid://pdg8fsjjca83")

var beats_per_tact: int
var track_lines: Array[TrackEditorLine]
var is_playing: bool

var cur_track: Array[int]


func show_track(track: TowerTrack) -> void:
	var color_index := 0
	for sound in track.sounds:
		var track_line := track_line_scene.instantiate()
		track_line.color_on = colors[color_index]
		track_line.color_off = Color.BLACK
		track_line.beats_per_tact = beats_per_tact
		track_line.changed.connect(_on_change)
		color_index += 1
		color_index %= len(colors)


func _on_play_button_pressed() -> void:
	if is_playing:
		play.emit()
		play_button.text = "Stop"
	else:
		play_button.text = "Play"
	is_playing = !is_playing


func _on_add_tact_button_pressed() -> void:
	for track_line in track_lines:
		track_line.add_tact()


func _on_change() -> void:
	var res: Array[int]
	res.resize(beats_per_tact)
	
	var line_index := 0
	for line in track_lines:
		var j := 0
		for c in line.tact:
			if c == '1':
				res[j] += 1 << line_index
			j += 1
			
		line_index += 1
		
	cur_track = res
