class_name Player extends Area2D

@onready var sprite := $AnimatedSprite2D
@onready var iframes := $InvincibilityFramesTimer

var health := Health.new(Config.player_health)
var last_position: Vector2
## куда смотрит игрок "down", "side" или "up"
var facing := "down"


func _process(delta: float) -> void:
	last_position = position
	var vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if vector.length_squared() > 0.1:
		_update_facing(vector)
		sprite.play("run_" + facing)
	else:
		# айдл в ту сторону, куда последний раз шли
		sprite.play("idle_" + facing)

	position += vector * Config.player_speed * delta
	if iframes.time_left > 0.0:
		modulate = Color.YELLOW
	else:
		if health.is_dead:
			modulate = Color(0.0, 0.0, 0.0)
		else:
			modulate = Color.WHITE


func take_damage(damage: int = 1) -> void:
	if iframes.time_left == 0.0:
		health.take_damage(damage)
		iframes.start()


func _update_facing(vector: Vector2) -> void:
	if absf(vector.x) >= absf(vector.y):
		facing = "side"
		sprite.flip_h = vector.x < 0
	else:
		facing = "down" if vector.y > 0 else "up"
		sprite.flip_h = false
