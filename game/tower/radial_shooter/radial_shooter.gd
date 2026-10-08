extends BaseTower

@export var bullet_count = 5

@onready var sprite := $AnimatedSprite2D


func _ready() -> void:
	sprite.play("idle")
	sprite.animation_finished.connect(
		func():
			sprite.play("idle"),
	)
	player = $AudioStreamPlayer2D


func shoot() -> void:
	sprite.play("shoot")
	var step: float = TAU / bullet_count
	for i in range(bullet_count):
		var angle_begin := i * step
		var angle_end := (i + 1) * step

		var angle := randf_range(angle_begin, angle_end)

		super._shoot(Vector2.from_angle(angle))
