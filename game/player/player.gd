class_name Player extends CharacterBody2D

@onready var sprite := $AnimatedSprite2D
@onready var iframes := $InvincibilityFramesTimer
@onready var wall_shape: RectangleShape2D = $WallCollider.shape

var health := Health.new(Config.player_health)
## куда смотрит игрок "down", "side" или "up"
var facing := "down"


func _physics_process(_delta: float) -> void:
	var vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if vector.length_squared() > 0.1:
		_update_facing(vector)
		sprite.play("run_" + facing)
	else:
		# айдл в ту сторону, куда последний раз шли
		sprite.play("idle_" + facing)

	velocity = vector * Config.player_speed
	move_and_slide()

	if iframes.time_left > 0.0:
		modulate = Color.YELLOW
	elif health.is_dead:
		modulate = Color.BLACK
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
