extends Node2D

var spawn_config: SpawnConfig = preload("res://game/level_processing/spawn_config.tres")


func _ready() -> void:
	if not spawn_config:
		Log.err("Отсутствует конфигурация для спавна объектов")
		return

	var spawn_layer: TileMapLayer = _find_layer_by_name(spawn_config.spawn_layer_name)
	if not spawn_layer:
		Log.warn("Layer '%s' not found." % spawn_config.spawn_layer_name)
		return

	var used_cells: Array[Vector2i] = spawn_layer.get_used_cells()

	for cell in used_cells:
		_process_spawn_cell(spawn_layer, cell)


## Найти нужный слой.
func _find_layer_by_name(layer_name: String) -> TileMapLayer:
	for child in get_children():
		if child is TileMapLayer and child.name == layer_name:
			return child
	return null


## Обработать тайлы под спавн.
func _process_spawn_cell(layer: TileMapLayer, cell: Vector2i) -> void:
	var cnt: int = 0
	var spawn_map: Dictionary[String, PackedScene] = spawn_config.spawn_map
	for key: String in spawn_map.keys():
		if not layer.get_cell_tile_data(cell).has_meta(key):
			continue
		cnt += 1

		var instance: Node2D = spawn_map[key].instantiate() as Node2D
		if instance == null:
			Log.err("Сцена для ключа '%s' не является Node2D" % key)
			continue

		instance.position = layer.map_to_local(cell)
		add_child(instance)

		var direction: Vector2 = _get_tile_direction(layer, cell)
		var look_point: Vector2 = direction + instance.global_position
		instance.look_at(look_point)

	if cnt == 0:
		Log.warn("Ячейка в позиции %s ничего не заспавнила" % [cell])
	elif cnt > 0:
		layer.erase_cell(cell)
	if cnt > 1:
		Log.warn("Ячейка в позиции %s совпадает с несколькими ключами" % [cell])


## Получить направление тайла.
func _get_tile_direction(layer: TileMapLayer, cell: Vector2i) -> Vector2:
	var tile_data: TileData = layer.get_cell_tile_data(cell)
	if not tile_data.has_meta(spawn_config.direction_key):
		Log.warn(
			"У тайла в позиции %s не найден ключ направления '%s'"
			% [cell, spawn_config.direction_key]
		)
		return Vector2.DOWN # дефолтное значение

	var map_direction: Dictionary[String, Vector2] = {
		"up": Vector2.UP,
		"right": Vector2.RIGHT,
		"down": Vector2.DOWN,
		"left": Vector2.LEFT,
	}
	var direction_str: String = tile_data.get_meta(spawn_config.direction_key)
	direction_str = direction_str.to_lower()

	if not map_direction.has(direction_str):
		Log.warn("У тайла в позиции %s неизвестное направление '%s'" % [cell, direction_str])
		return Vector2.DOWN # дефолтное значение

	return map_direction[direction_str]
