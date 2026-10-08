class_name Bullet extends Area2D

var direction: Vector2 = Vector2.RIGHT


func _process(delta: float) -> void:
	position += direction * Config.bullet_speed * delta
