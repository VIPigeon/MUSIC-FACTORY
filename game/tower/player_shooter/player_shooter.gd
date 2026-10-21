class_name PlayerShooter extends BaseTower

@onready var sprite := $AnimatedSprite2D

var target: Node2D


func _ready() -> void:
	sprite.play("idle")


func shoot() -> void:
	super._shoot((target.position - position).normalized())
