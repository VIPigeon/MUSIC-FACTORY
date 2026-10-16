class_name TrackEditor extends Control

@export var track: TowerTrack
@export var track_line_container: Container
@export var beats_per_tact: int = 16

var track_line_scene := preload("uid://pdg8fsjjca83")

var track_lines: Array[TrackEditorLine]
var colors: Array[Color] = [Color.YELLOW, Color.LIME, Color.INDIAN_RED, Color.SKY_BLUE, Color.WEB_PURPLE]

var cur_track: Array[int]


func _ready() -> void:
	var color_index := 0
	for sound in track.sounds:
		var track_line := track_line_scene.instantiate()
		track_line.color_on = colors[color_index]
		track_line.color_off = Color.BLACK
		track_line.beats_per_tact = beats_per_tact
		track_line.changed.connect(_on_change)
		color_index += 1
		color_index %= len(colors)
		track_line_container.add_child(track_line)
		track_lines.append(track_line)


func _on_change() -> void:
	var res: Array[int]
	res.resize(beats_per_tact)
	
	var line_index := 0
	for line in track_lines:
		var total := 0
		var j := 0
		for c in line.tact:
			if c == '1':
				res[j] += 1 << line_index
			j += 1
			
		line_index += 1
		
	cur_track = res


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_S and event.get_modifiers_mask() & KEY_MASK_CTRL:
			var resource := TowerTrack.new()
			resource.sounds = track.sounds
			resource.tacts.resize(1)
			var as_string: String = ""
			for val in cur_track:
				as_string += str(val)
			resource.tacts[0] = as_string
			
			var path := "res://resource/track/generated.tres"
			ResourceSaver.save(resource, path)
			print("Saved at ", path)
