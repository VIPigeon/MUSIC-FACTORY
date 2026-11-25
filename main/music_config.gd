class_name MusicConfig
extends Resource

var sound: AudioStream
var timing: int


func _init(sound_: AudioStream, timing_: int) -> void:
	sound = sound_
	timing = timing_
