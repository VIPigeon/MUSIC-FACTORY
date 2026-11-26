class_name MusicDirector

signal beat(tact: int, beat: int)

var bpm: float
var beats_in_tact: int

var current_tact: int
var current_time: float
var current_beat: int


func _init() -> void:
	bpm = Config.bpm
	beats_in_tact = Config.beats_in_tact


func tick(delta: float) -> void:
	current_time += delta
	while current_time >= seconds_per_beat():
		current_time -= seconds_per_beat()
		on_beat()


func progress() -> float:
	return current_time / seconds_per_beat()


func seconds_per_beat() -> float:
	return 60.0 / bpm


func on_beat() -> void:
	current_beat += 1
	if current_beat >= beats_in_tact:
		current_tact += 1
		current_beat = 0
		
	beat.emit(current_tact, current_beat)
