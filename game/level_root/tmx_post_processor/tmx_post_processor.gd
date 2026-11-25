extends Node
## Post-processor для .tmx уровней.
##
## Добавляет на уровень из Tiled сцены из Godot: игрок, спавнеры башен и т.п.

## Конфиг для работы с уровнем.
var _spawn_config: TmxPostConfig = preload(
	"res://game/level_root/tmx_post_processor/tmx_post_config.tres"
)
## Тайловые слои по именам.
var _tile_layers: Dictionary[String, TileMapLayer] = { }
## Упорядоченный список всех тайловых слоёв в изначальном порядке.
var _ordered_layers: Array[TileMapLayer] = []
## Слой со спавном сущностей.
var _spawn_layer: TileMapLayer = null
## Слой со стенами локации.
var _wall_layer: TileMapLayer = null
## Скрипт (класс) для корня уровня.
var _root_level_script: Script = preload("res://game/level_root/level_root.gd")


## Пост-обработка имортируемой сцены из tmx файла. [br]
## [br]
## [param base_node] - [Node2D] с корнем импортируемой .tmx сцены.
func _post_process(base_node: Node2D) -> Node2D:
	_cache_tile_layers(base_node)

	if not _spawn_config:
		Log.err("Отсутствует конфигурация для спавна объектов, пропускаю пост-обработку сцены")
		return

	if not _spawn_layer:
		Log.err(
			"Слой для спавна '%s' не обнаружен, пропускаю пост-обработку сцены"
			% _spawn_config.spawn_layer_name
		)
		return

	base_node.set_script(_root_level_script)
	base_node.spawn_layer = _spawn_layer
	base_node.wall_layer = _wall_layer
	base_node.tile_layers = _tile_layers

	# TODO возможно TowerController стоит сделать полноценным узлом и сохранять в сцене?
	var tower_controller := TowerController.new(base_node, null, null, null)
	var used_cells: Array[Vector2i] = _spawn_layer.get_used_cells()
	for cell in used_cells:
		_process_spawn_cell(tower_controller, _spawn_layer, cell, base_node)

	# вместо удаления тайлов, просто отключаю слой
	# эти тайлы потом будут полезны для определения бывших тайлов со спавном
	_spawn_layer.enabled = false
	Log.info("Слой со спавном отключён после обработки")

	return base_node


## Закэшировать текущие тайловые слои, чтобы в дальнейшем не обходить всех детей. [br]
## [br]
## [param base_node] - [Node2D] с корнем импортируемой .tmx сцены.
func _cache_tile_layers(base_node: Node2D) -> void:
	_tile_layers.clear()
	_ordered_layers.clear()
	for child in base_node.get_children():
		if child is TileMapLayer:
			_tile_layers[child.name] = child
			_ordered_layers.append(child)

	if _spawn_config:
		_spawn_layer = _tile_layers.get(_spawn_config.spawn_layer_name)
		_wall_layer = _tile_layers.get(_spawn_config.wall_layer_name)


## Обработать тайлы под спавн.
func _process_spawn_cell(
	tower_controller: TowerController,
	layer: TileMapLayer,
	cell: Vector2i,
	base_node: Node2D,
) -> void:
	Log.debug("Обработка ячейки %s из слоя %s" % [cell, layer.name])

	# Игрок
	if layer.get_cell_tile_data(cell).has_meta(_spawn_config.player_tag):
		var player: Player = _spawn_config.player_scene.instantiate()
		player.position = layer.map_to_local(cell)
		base_node.add_child(player)
		player.owner = base_node
		Log.info("Игрок добавлен в ячейку %s" % cell)
		return

	# Всё остальное
	var cnt: int = 0
	var spawn_map: Dictionary[String, Tower.Kind] = _spawn_config.spawn_map
	for key: String in spawn_map.keys():
		if not layer.get_cell_tile_data(cell).has_meta(key):
			continue
		cnt += 1

		var kind: Tower.Kind = spawn_map[key]
		var tower_position: Vector2 = layer.map_to_local(cell)
		Log.debug("Создание башни с типом %s через TowerController" % Tower.Kind.find_key(kind))
		# TODO башни без информации о музыке, я пока хз как это скриптом делать
		# и надо ли.
		tower_controller.create_tower_on_sale(kind, tower_position, -1, null, base_node)

		# TODO пока хз как нормально направление сделать
		#var direction: Vector2 = _get_tile_direction(layer, cell)
		#var look_point: Vector2 = direction + instance.global_position
		#instance.look_at(look_point)

	if cnt == 0:
		Log.warn("Ячейка спавна в позиции %s ничего не заспавнила" % [cell])
	if cnt > 1:
		Log.warn(
			"Ячейка спавна в позиции %s совпадает с несколькими ключами, возможно в одной
			точке находится несколько противников"
			% [cell]
		)

	Log.debug("Конец обработки ячейки %s из слоя %s" % [cell, layer.name])


## Получить направление тайла.
func _get_tile_direction(layer: TileMapLayer, cell: Vector2i) -> Vector2:
	var tile_data: TileData = layer.get_cell_tile_data(cell)
	if not tile_data.has_meta(_spawn_config.direction_key):
		Log.warn(
			"У тайла в позиции %s не найден ключ направления '%s'"
			% [cell, _spawn_config.direction_key]
		)
		return Vector2.DOWN # дефолтное значение

	var map_direction: Dictionary[String, Vector2] = {
		"up": Vector2.UP,
		"right": Vector2.RIGHT,
		"down": Vector2.DOWN,
		"left": Vector2.LEFT,
	}
	var direction_str: String = tile_data.get_meta(_spawn_config.direction_key)
	direction_str = direction_str.to_lower()

	if not map_direction.has(direction_str):
		Log.warn("У тайла в позиции %s неизвестное направление '%s'" % [cell, direction_str])
		return Vector2.DOWN # дефолтное значение

	return map_direction[direction_str]
