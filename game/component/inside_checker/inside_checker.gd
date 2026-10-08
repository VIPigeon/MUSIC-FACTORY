@icon("uid://i6idbn4egvyc")
class_name Area2DInsideChecker extends Area2D

var count_inside: int


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func is_something_inside() -> bool:
	return count_inside > 0


func _on_area_entered(_area: Area2D) -> void:
	count_inside += 1


func _on_area_exited(_area: Area2D) -> void:
	count_inside -= 1
