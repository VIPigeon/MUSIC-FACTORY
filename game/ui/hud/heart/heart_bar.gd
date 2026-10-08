class_name HUDHeartBar extends Control

@onready var container := $HBoxContainer

var health: Health
var hearts: Array[UIHeart]
var heart_scene := preload("uid://b2awulagoipvw")


func _ready() -> void:
	for i in range(int((health.max_value + 1) / 2)):
		var heart := heart_scene.instantiate() as UIHeart
		hearts.append(heart)
		container.add_child(heart)

	display_current_health()
	health.changed.connect(display_current_health)


func display_current_health() -> void:
	var current := health.current
	for heart in hearts:
		if current > 1:
			heart.set_state(UIHeart.State.FULL)
		elif current == 1:
			heart.set_state(UIHeart.State.HALF)
		else:
			heart.set_state(UIHeart.State.EMPTY)
		current -= 2
