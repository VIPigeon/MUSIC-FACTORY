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

## Узел-контейнер для башен, добавляемых через [TowerOnSale].
@export var towers_container: Node2D = null

## Узел-контейнер для [TowerOnSale].
@export var towers_on_sale_container: Node2D = null

var _towers_on_sale: Array[TowerOnSale] = []
var _active_towers: Dictionary[Node2D, bool] = { } # типа сет
var _inactive_towers: Dictionary[Node2D, bool] = { } # типа сет


func _ready() -> void:
	# _towers_on_sale
	for child: Node in towers_on_sale_container.get_children():
		if child is TowerOnSale:
			_towers_on_sale.push_back(child as TowerOnSale)

	# _inactive_towers & _active_towers
	for child: Node in towers_container.get_children():
		if child is not Node2D:
			continue
		var tower: Node2D = child as Node2D
		if tower.process_mode == Node.PROCESS_MODE_DISABLED:
			_inactive_towers[tower] = true # добавить в сет
		else:
			_active_towers[tower] = true # добавить в сет


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


## Возвращает массив со всеми магазинами башен [TowerOnSale] в этом уровне.
func get_towers_on_sale() -> Array[TowerOnSale]:
	return _towers_on_sale


## Возвращает все ещё не купленные башни.
func get_inactive_towers() -> Array[Node2D]:
	return _inactive_towers.keys()


## Возвращает уже купленные башни.
func get_active_towers() -> Array[Node2D]:
	return _active_towers.keys()


# Купленная башня теперь должна быть среди активированных.
func _on_tower_bought(tower: Node2D) -> void:
	if not _inactive_towers.has(tower):
		Log.warn(
			"Новая купленная башня '%s' не была указана как неактивная.
			Она добавлена другим скриптом?"
			% tower.name
		)
		return
	_inactive_towers.erase(tower)
	_active_towers[tower] = true


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
