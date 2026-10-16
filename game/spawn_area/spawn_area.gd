@tool
class_name SpawnArea
extends Area2D

## Что спавнить при старте сцены?
@export var object_to_spawn: PackedScene


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		# Функционал коллизий не нужен
		monitorable = false
		monitoring = false


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	if object_to_spawn == null:
		Log.warn(name, "нет объекта для спавна")
		return

	var spawn_position: Variant = _get_random_point_in_rect()
	if spawn_position == null:
		Log.warn(name, "не обнаружена прямоугольная зона спавна")
		return

	var instance := object_to_spawn.instantiate()
	add_child(instance)

	if instance is Node2D:
		instance.global_position = global_position + spawn_position
	else:
		Log.warn(
			name,
			"объект {0} не является Node2D, невозможно задать позицию".format([instance.name]),
		)


## Случайная точке в заданном прямоугольнике, либо null.
func _get_random_point_in_rect() -> Variant:
	var collision_shape := _get_collision_shape()
	if collision_shape == null:
		return null

	var rect_shape := collision_shape.shape as RectangleShape2D
	if rect_shape == null:
		return null

	var half_extents := rect_shape.size * 0.5
	var offset := collision_shape.position

	var local_x := randf_range(-half_extents.x, half_extents.x) + offset.x
	var local_y := randf_range(-half_extents.y, half_extents.y) + offset.y

	return Vector2(local_x, local_y)


## Возвращает первый дочерний CollisionShape2D.
func _get_collision_shape() -> CollisionShape2D:
	for child in get_children():
		if child is CollisionShape2D:
			return child
	return null


#region CONFIG_WARNINGS

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()

	if object_to_spawn == null:
		warnings.append("SpawnArea не содержит объект для спавна")

	var collision_shape: CollisionShape2D = null
	var shape_count := 0
	for child in get_children():
		if child is CollisionShape2D:
			shape_count += 1
			if collision_shape == null:
				collision_shape = child

	if shape_count == 0 or collision_shape == null:
		warnings.append(
			"Для SpawnArea нужен дочерний CollisionShape2D дабы задать прямоугольник спавна"
		)
		return warnings

	if collision_shape.shape == null or collision_shape.shape is not RectangleShape2D:
		warnings.append("Дочерний CollisionShape2D должен содержать RectangleShape2D.")

	return warnings


func _notification(what: int) -> void:
	if not Engine.is_editor_hint():
		return

	# Перепроверяем конфигурацию после следующих событий
	match what:
		NOTIFICATION_CHILD_ORDER_CHANGED, \
				NOTIFICATION_EDITOR_PRE_SAVE, \
				NOTIFICATION_TRANSFORM_CHANGED:
			update_configuration_warnings()

#endregion CONFIG_WARNINGS
