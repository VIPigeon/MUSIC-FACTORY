class_name LevelRoot extends Node2D
## Корневой скрипт для уровней, импортированных из .tmx
##
## Отвечает за обработку уровня при его старте (размещение игрока, башен и т.п.)
## и предоставляет utility функции для работы с уровнем в run-time.


## Информация о тайле, полученном из конкретного слоя.
class TileInfo extends RefCounted:
	## Слой, из которого получен тайл.
	var layer: TileMapLayer
	## Имя узла слоя [member layer].
	var layer_name: String
	## Данные тайла (может быть null, если в ячейке нет тайла в этом слое).
	var data: TileData
	## Координаты ячейки, к которой относится тайл.
	var cell: Vector2i


	func _init(p_layer: TileMapLayer, p_cell: Vector2i) -> void:
		layer = p_layer
		layer_name = p_layer.name
		cell = p_cell
		data = p_layer.get_cell_tile_data(p_cell)


	## Пустой ли тайл (в ячейке нет тайла в этом слое).
	func is_empty() -> bool:
		return data == null


	## Получить список метаданных этого тайла. [br]
	## [br]
	## Note: это просто метаданные из [member data], метод создан для удобства.
	func get_tile_meta_list() -> Array[StringName]:
		return data.get_meta_list()


## Конфиг для работы с уровнем.
var spawn_config: SpawnConfig = preload("res://game/level_root/spawn_config.tres")

## Тайловые слои по именам.
var _tile_layers: Dictionary[String, TileMapLayer] = { }
## Упорядоченный список всех тайловых слоёв в изначальном порядке.
var _ordered_layers: Array[TileMapLayer] = []
## Слой со спавном сущностей.
var _spawn_layer = null
## Слой со стенами локации.
var _wall_layer = null


func _ready() -> void:
	_cache_tile_layers()

	if not spawn_config:
		Log.err("Отсутствует конфигурация для спавна объектов")
		return

	if not _spawn_layer:
		Log.warn("Слой для спавна противников '%s' не обнаружен" % spawn_config.spawn_layer_name)
		return

	var used_cells: Array[Vector2i] = _spawn_layer.get_used_cells()
	for cell in used_cells:
		_process_spawn_cell(_spawn_layer, cell)


## Закэшировать текущие тайловые слои, чтобы в дальнейшем не обходить всех детей. [br]
func _cache_tile_layers() -> void:
	_tile_layers.clear()
	_ordered_layers.clear()
	for child in get_children():
		if child is TileMapLayer:
			_tile_layers[child.name] = child
			_ordered_layers.append(child)

	if spawn_config:
		_spawn_layer = _tile_layers.get(spawn_config.spawn_layer_name)
		_wall_layer = _tile_layers.get(spawn_config.wall_layer_name)


## Найти слой уровня [TileMapLayer] по названию его узла. [br]
## Работает по кэшу, без обхода детей. [br]
## [br]
## [param layer_name] - [String] с названием узла.
func find_layer_by_name(layer_name: String) -> TileMapLayer:
	var layer: TileMapLayer = _tile_layers.get(layer_name)
	if not layer:
		Log.warn("Попытка найти слой уровня с названием '%s', но такой не обнаружен" % layer_name)
	return layer


## Перевести глобальные вещественные координаты в тайловые. [br]
## [br]
## [param global_pos] - позиция в глобальных координатах.
func global_to_tile(global_pos: Vector2) -> Vector2i:
	var ref := _get_reference_layer()
	if not ref:
		Log.err("Нет доступных тайловых слоёв для перевода глобальных координат в тайловые")
		return Vector2i.ZERO
	return ref.local_to_map(ref.to_local(global_pos))


## Получить все непустые тайлы из всех слоёв по тайловым координатам. [br]
## [br]
## [param cell] - координаты ячейки.
func get_tiles_at(cell: Vector2i) -> Array[TileInfo]:
	var result: Array[TileInfo] = []
	for layer in _ordered_layers:
		var info := TileInfo.new(layer, cell)
		if not info.is_empty():
			result.append(info)
	return result


## Получить все непустые тайлы из всех слоёв по глобальным координатам. [br]
## [br]
## [param global_pos] - позиция в глобальных координатах.
func get_tiles_at_global(global_pos: Vector2) -> Array[TileInfo]:
	return get_tiles_at(global_to_tile(global_pos))


## Проверить наличие стены по тайловым координатам. [br]
## [br]
## [param cell] - координаты ячейки.
func is_wall_at(cell: Vector2i) -> bool:
	if not _wall_layer:
		return false
	return _wall_layer.get_cell_tile_data(cell) != null


## Проверить наличие стены по глобальным координатам. [br]
## [br]
## [param global_pos] - позиция в глобальных координатах.
func is_wall_at_global(global_pos: Vector2) -> bool:
	return is_wall_at(global_to_tile(global_pos))


## Проверить наличие спавна по тайловым координатам. [br]
## [br]
## [param cell] - координаты ячейки.
func is_spawn_at(cell: Vector2i) -> bool:
	if not _spawn_layer:
		return false
	return _spawn_layer.get_cell_tile_data(cell) != null


## Проверить наличие спавна по глобальным координатам. [br]
## [br]
## [param global_pos] - позиция в глобальных координатах.
func is_spawn_at_global(global_pos: Vector2) -> bool:
	return is_spawn_at(global_to_tile(global_pos))


## Получить опорный слой для перевода координат. [br]
## Приоритет: стены -> спавн -> первый попавшийся слой.
func _get_reference_layer() -> TileMapLayer:
	if _wall_layer:
		return _wall_layer
	if _spawn_layer:
		return _spawn_layer
	if not _ordered_layers.is_empty():
		return _ordered_layers[0]
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
