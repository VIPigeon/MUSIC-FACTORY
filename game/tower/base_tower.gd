@abstract
class_name BaseTower extends Node2D

signal shot(position: Vector2, direction: Vector2)

@export var track: TowerTrack

var timing: int
var sound: AudioStream
var kind: Tower.Kind
var player: AudioStreamPlayer2D


func _shoot(direction: Vector2) -> void:
	player.stream = sound
	player.play()

	if shot.has_connections():
		shot.emit(position, direction)
	else:
		# При запуске какой-то башни как отдельной сцены
		# хотелось бы видеть как она стреляет, так что
		# вот так.
		var bullet := preload("uid://bu4ig5joh4xnx").instantiate()
		bullet.direction = direction
		add_child(bullet)
