class_name HUDCurrency extends Control

@onready var animation_timer := $AnimationTimer
@onready var texture_rect := $HBoxContainer/TextureRect
@onready var count_label := $HBoxContainer/Count

var texture: AnimatedTexture


func _ready() -> void:
	texture = texture_rect.texture as AnimatedTexture
	animation_timer.timeout.connect(_reset_animation)
	texture.pause = true
	_reset_animation()


func show_currency(count: int) -> void:
	count_label.text = str(count)
	texture.current_frame = 1
	animation_timer.start()


func _reset_animation() -> void:
	texture.current_frame = 0
