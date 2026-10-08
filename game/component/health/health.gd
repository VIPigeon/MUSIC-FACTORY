@icon("uid://ql7moj2hwr1v")
class_name Health

signal changed
signal dead

var current: int
var max_value: int
var is_dead: bool


func _init(max_value_: int) -> void:
	self.max_value = max_value_
	self.current = max_value_


func _ready() -> void:
	changed.emit()


func take_damage(damage: int = 1) -> void:
	current -= damage
	current = max(current, 0)
	if not is_dead:
		changed.emit()
		if current == 0:
			is_dead = true
			dead.emit()
