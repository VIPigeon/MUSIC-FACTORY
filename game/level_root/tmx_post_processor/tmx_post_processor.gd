extends Node
## Post-processor для .tmx уровней.
##
## Добавляет на уровень из Tiled сцены из Godot: игрок, спавнеры башен и т.п.

## Конфиг для работы с уровнем.
const SPAWN_CONFIG: TmxPostConfig = preload(
	"res://game/level_root/tmx_post_processor/tmx_post_config.tres"
)

## Скрипт (класс) для корня уровня.
const ROOT_LEVEL_SCRIPT: Script = preload("res://game/level_root/level_root.gd")

const TOWER_ON_SALE_SCENE = preload("res://game/tower/tower_on_sale/tower_on_sale.tscn")
const TOWERS_ON_SALE_CONTAINER_NAME = "TowerOnSaleContainer"
const TOWERS_CONTAINER_NAME = "TowersContainer"

## Тайловые слои по именам.
var _tile_layers: Dictionary[String, TileMapLayer] = { }

## Упорядоченный список всех тайловых слоёв в изначальном порядке.
var _ordered_layers: Array[TileMapLayer] = []

## Слой со спавном сущностей.
var _spawn_layer: TileMapLayer = null

## Слой со стенами локации.
var _wall_layer: TileMapLayer = null


## Пост-обработка импортируемой сцены из tmx файла. [br]
## [br]
## [param base_node] - [Node2D] с корнем импортируемой .tmx сцены.
func _post_process(base_node: Node2D) -> Node2D:
	_cache_tile_layers(base_node)

	if SPAWN_CONFIG == null:
		Log.err("Отсутствует конфигурация для спавна объектов, пропускаю пост-обработку сцены")
		return

	if not _spawn_layer:
		Log.err(
			"Слой для спавна '%s' не обнаружен, пропускаю пост-обработку сцены"
			% SPAWN_CONFIG.spawn_layer_name
		)
		return

	var root_node: LevelRoot = _init_root_node(base_node)
	var towers_container: Node2D = _init_towers_container(root_node)
	var towers_on_sale_container: Node2D = _init_towers_on_sale_container(root_node)

	root_node.towers_container = towers_container
	root_node.towers_on_sale_container = towers_on_sale_container

	var used_cells: Array[Vector2i] = _spawn_layer.get_used_cells()
	for cell in used_cells:
		_process_spawn_cell(_spawn_layer, cell, root_node)

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

	if SPAWN_CONFIG != null:
		_spawn_layer = _tile_layers.get(SPAWN_CONFIG.spawn_layer_name)
		_wall_layer = _tile_layers.get(SPAWN_CONFIG.wall_layer_name)


## Обработать тайл под спавн.
func _process_spawn_cell(layer: TileMapLayer, cell: Vector2i, root_node: LevelRoot) -> void:
	Log.debug("Обработка ячейки %s из слоя %s" % [cell, layer.name])

	# Игрок
	if layer.get_cell_tile_data(cell).has_meta(SPAWN_CONFIG.player_tag):
		var player: Player = SPAWN_CONFIG.player_scene.instantiate()
		player.position = layer.map_to_local(cell)
		root_node.add_child(player, true)
		player.owner = root_node
		Log.info("Игрок %s добавлен в позицию %s" % [player.name, player.position])
		return

	# Всё остальное
	var cnt: int = 0
	var spawn_map: Dictionary[String, PackedScene] = SPAWN_CONFIG.spawn_map
	for key: String in spawn_map.keys():
		if not layer.get_cell_tile_data(cell).has_meta(key):
			continue
		cnt += 1

		var tower_scene: PackedScene = spawn_map[key]
		if tower_scene == null:
			Log.warn(
				"Ошибка определения сцены для башни с тегом (ключем) %s в позиции %s" % [key, cell]
			)

		var tower_on_sale_position: Vector2 = layer.map_to_local(cell)
		var direction: Vector2 = _get_tile_direction(layer, cell)
		_create_tower_on_sale(root_node, tower_scene, tower_on_sale_position, direction)

	if cnt == 0:
		Log.warn("Ячейка спавна в позиции %s ничего не заспавнила" % [cell])

	if cnt > 1:
		Log.warn(
			"Ячейка спавна в позиции %s совпадает с несколькими ключами,
			возможно в одной точке находится несколько противников"
			% [cell]
		)

	Log.debug("Конец обработки ячейки %s из слоя %s" % [cell, layer.name])


## Получить направление тайла.
func _get_tile_direction(layer: TileMapLayer, cell: Vector2i) -> Vector2:
	var tile_data: TileData = layer.get_cell_tile_data(cell)
	if not tile_data.has_meta(SPAWN_CONFIG.direction_key):
		Log.warn(
			"У тайла в позиции %s не найден ключ направления '%s'"
			% [cell, SPAWN_CONFIG.direction_key]
		)
		return Vector2.DOWN # дефолтное значение

	var map_direction: Dictionary[String, Vector2] = {
		"up": Vector2.UP,
		"right": Vector2.RIGHT,
		"down": Vector2.DOWN,
		"left": Vector2.LEFT,
	}
	var direction_str: String = tile_data.get_meta(SPAWN_CONFIG.direction_key)
	direction_str = direction_str.to_lower()

	if not map_direction.has(direction_str):
		Log.warn("У тайла в позиции %s неизвестное направление '%s'" % [cell, direction_str])
		return Vector2.DOWN # дефолтное значение

	return map_direction[direction_str]


func _init_root_node(base_node: Node) -> LevelRoot:
	base_node.set_script(ROOT_LEVEL_SCRIPT)
	Log.info("К корню уровня прикреплён скрипт %s" % ROOT_LEVEL_SCRIPT)
	var root_node := base_node as LevelRoot
	root_node.spawn_layer = _spawn_layer
	root_node.wall_layer = _wall_layer
	root_node.tile_layers = _tile_layers
	return root_node


func _init_towers_container(root_node: LevelRoot) -> Node2D:
	var towers_container = Node2D.new()
	towers_container.name = TOWERS_CONTAINER_NAME
	root_node.add_child(towers_container, true)
	towers_container.owner = root_node
	Log.info("Создан контейнер для башен %s" % towers_container.name)
	return towers_container


func _init_towers_on_sale_container(root_node: LevelRoot) -> Node2D:
	var towers_on_sale_container = Node2D.new()
	towers_on_sale_container.name = TOWERS_ON_SALE_CONTAINER_NAME
	root_node.add_child(towers_on_sale_container, true)
	towers_on_sale_container.owner = root_node
	Log.info("Создан контейнер для магазинов башен %s" % towers_on_sale_container.name)
	return towers_on_sale_container


func _create_tower_on_sale(
	root_node: LevelRoot,
	tower_scene: PackedScene,
	tower_on_sale_position: Vector2,
	direction: Vector2,
) -> void:
	var tower_on_sale: TowerOnSale = TOWER_ON_SALE_SCENE.instantiate()
	root_node.towers_on_sale_container.add_child(tower_on_sale, true)
	tower_on_sale.position = tower_on_sale_position
	tower_on_sale.owner = root_node
	tower_on_sale.direction = direction
	tower_on_sale.tower_container = root_node.towers_container
	tower_on_sale.tower_scene = tower_scene
	Log.info(
		"Магазин башни %s добавлен в позицию %s" % [tower_on_sale.name, tower_on_sale.position]
	)
