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


## Слой со спавном сущностей.
@export var spawn_layer: TileMapLayer = null
## Слой со стенами локации.
@export var wall_layer: TileMapLayer = null
## Все тайловые слои уровня по их именам.
@export var tile_layers: Dictionary[String, TileMapLayer] = { }


## Найти слой уровня [TileMapLayer] по названию его узла. [br]
## Работает по кэшу преобразования из tmx, без фактического обхода детей. [br]
## [br]
## [param layer_name] - [String] с названием узла.
func find_layer_by_name(layer_name: String) -> TileMapLayer:
	var layer: TileMapLayer = tile_layers.get(layer_name)
	if not layer:
		Log.warn("Попытка найти слой уровня с названием '%s', но такой не обнаружен" % layer_name)
	return layer


## Содержится ли слой уровня [TileMapLayer] с таким названием. [br]
## Работает по кэшу преобразования из tmx, без фактического обхода детей. [br]
## [br]
## [param layer_name] - [String] с названием узла.
func has_layer_name(layer_name: String) -> bool:
	return tile_layers.has(layer_name)


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
	for layer in tile_layers.values():
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
	if not wall_layer:
		return false
	return wall_layer.get_cell_tile_data(cell) != null


## Проверить наличие стены по глобальным координатам. [br]
## [br]
## [param global_pos] - позиция в глобальных координатах.
func is_wall_at_global(global_pos: Vector2) -> bool:
	return is_wall_at(global_to_tile(global_pos))


## Проверить наличие спавна по тайловым координатам. [br]
## [br]
## [param cell] - координаты ячейки.
func is_spawn_at(cell: Vector2i) -> bool:
	if not spawn_layer:
		return false
	return spawn_layer.get_cell_tile_data(cell) != null


## Проверить наличие спавна по глобальным координатам. [br]
## [br]
## [param global_pos] - позиция в глобальных координатах.
func is_spawn_at_global(global_pos: Vector2) -> bool:
	return is_spawn_at(global_to_tile(global_pos))


## Получить опорный слой для перевода координат. [br]
## Приоритет: стены -> спавн -> первый попавшийся слой.
func _get_reference_layer() -> TileMapLayer:
	if wall_layer:
		Log.debug("Слой со стенами взят в качестве опорного для перевода координат")
		return wall_layer
	if spawn_layer:
		Log.debug("Слой со спавном взят в качестве опорного для перевода координат")
		return spawn_layer
	if not tile_layers.is_empty():
		Log.debug("Взят первый попавшийся слой в качестве опорного для перевода координат")
		return tile_layers.values()[0]
	Log.debug("Опорный слой не найден")
	return null
