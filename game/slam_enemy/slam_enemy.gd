class_name SlamEnemy extends Area2D

signal wall_hit

## Чем больше значение, тем медленнее старт и быстрее удар об стену.
@export_range(1.1, 6.0, 0.1) var acceleration_power: float = 3.0
@export var start_moving_right: bool = true

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D

var music_director: MusicDirector
var _left_x: float
var _right_x: float
var _from_x: float
var _target_x: float
var _starting_progress: float


func setup(director: MusicDirector, screen: Rect2) -> void:
	assert(music_director == null, "Ты уже настроил врага, зач ещё раз?")
	music_director = director
	
	assert(scale.x == 1, "Не ставь scale 😒")
	assert(collision.scale.x == 1, "Не ставь scale 😒")
	var half_width := collision.shape.get_rect().size.x * 0.5
	
	# 4 белых мягких стены.
	_left_x = screen.position.x + half_width
	_right_x = maxf(_left_x, screen.end.x - half_width)
	
	_from_x = position.x
	_target_x = _right_x if start_moving_right else _left_x
	_starting_progress = music_director.current_time / music_director.seconds_per_beat()
	
	music_director.beat.connect(_on_beat)


func _process(_delta: float) -> void:
	var progress := music_director.progress()
	progress = clampf((progress - _starting_progress) / maxf(1.0 - _starting_progress, 0.000001), 0.0, 1.0)
	position.x = lerpf(_from_x, _target_x, pow(progress, acceleration_power))


func _on_area_entered(area: Area2D) -> void:
	var player := area as Player
	if player != null:
		player.take_damage(1)


func _on_beat(_tact: int, _beat: int) -> void:
	position.x = _target_x
	wall_hit.emit()
	sound.play()
	
	_from_x = _target_x
	_target_x = _left_x if _target_x == _right_x else _right_x
	_starting_progress = 0.0
