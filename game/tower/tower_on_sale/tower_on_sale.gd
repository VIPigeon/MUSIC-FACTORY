@tool
class_name TowerOnSale
extends Node2D

## Нужная сумма потрачена и башня теперь куплена (активна).
signal bought(tower_on_sale: TowerOnSale)

## Запрос потратить монетки игрока (прошлый buy_tick). [br]
## [br]
## Срабатывает если игрок находится в зоне продажи башни и cooldown прошлой траты уже прошёл.
## Если монеток достаточно, необходимо вызвать [member spend_coins].
signal spend_coins_request(coins: int)

## Подпись со стоимостью башни.
@onready var cost_label: Label = $CostLabel

## Зона покупки башни. Игрок должен находится в её пределах для вычета монет.
@onready var buy_area: Area2DInsideChecker = $Area2D

## Сколько осталось до покупки башни. Изначально равно [member cost].
@onready var remain_cost: int = cost:
	set(value):
		remain_cost = value
		if cost_label != null: # инициализируется раньше дочернего label
			cost_label.text = str(remain_cost)
		if Engine.is_editor_hint():
			update_configuration_warnings()

## Фильтр цвета для неактивной башни.
@export var inactive_color_filter: Color = Color.DIM_GRAY

## Стоимость покупки башни.[br]
## [br]
## Если изменяется во время игры, то [member remain_cost] сбрасывается.
@export var cost: int = -1:
	set(value):
		cost = value
		remain_cost = cost

## Какую башню (сцену) спавнить.
@export var tower_scene: PackedScene:
	set(value):
		tower_scene = value
		if Engine.is_editor_hint():
			update_configuration_warnings()

## Направление, в котором спавнить башню.
@export var direction: Vector2 = Vector2.DOWN

## Конфигурация музыки башни.
@export var music_config: MusicConfig

## Под каким узлом создавать башню.[br]
## [br]
## Если этот параметр не определён, то башня создаётся под родителем магазина,
## то есть будет соседом (sibling) магазина.
var tower_container: Node = null

var _hold_time: float = 0.0
var _time_since_buy_request: float = 0.0
var _current_buy_delay: float = 0.0
var _is_player_inside: bool = false

var _tower: Node2D = null
var _tower_orignal_modulate: Color = Color.WHITE


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	if cost < 0:
		Log.warn("Стоимость башни не определена (меньше 0)")

	if tower_container == null:
		Log.warn(
			"Не указан контейнер для башни, башня будет создана как сосед магазина с родителем %s"
			% get_parent().name
		)
		tower_container = get_parent()

	if tower_scene == null:
		Log.err("Не указана сцена башни для магазина, спавнить нечего, магазин отключается")
		deactivate()
		return

	# Добавить отключенную башню как образ.
	_tower = tower_scene.instantiate()
	_tower.process_mode = Node.PROCESS_MODE_DISABLED
	_tower_orignal_modulate = _tower.modulate
	_tower.modulate = inactive_color_filter
	_tower.position = position
	tower_container.add_child.call_deferred(_tower)

	if remain_cost == 0:
		_spawn_tower()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	var was_player_inside: bool = _is_player_inside
	_is_player_inside = buy_area.is_something_inside()

	if not _is_player_inside:
		_hold_time = 0.0
		_time_since_buy_request = 0.0
		return

	if not was_player_inside:
		# первый тик покупки
		spend_coins_request.emit(1)
		return

	# внутри не первый тик
	_hold_time += delta
	_time_since_buy_request += delta
	if _time_since_buy_request > _current_buy_delay:
		spend_coins_request.emit(1)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []

	if cost < 0:
		var msg := "Стоимость башни не определена (cost = %s < 0)" % cost
		warnings.push_back(msg)

	if tower_scene == null:
		var msg := "Не указана сцена башни. Неизвестно, что спавнить при покупке."
		warnings.push_back(msg)

	return warnings


## Потратить [param spent] монеток на башню. [br]
## [br]
## Также смотри [signal spend_coins_request].
func spend_coins(spent: int = 1) -> void:
	if remain_cost <= 0:
		Log.warn("Попытка списать деньги на уже купленную башню %s" % _tower.name)
		return

	if remain_cost < spent:
		Log.warn(
			"Попытка потратить на башню больше денег, чем требуется:
			`remain_cost = %s` < `spent = %s`"
			% [remain_cost, spent]
		)

	remain_cost = max(0, remain_cost - spent)
	if remain_cost == 0:
		_spawn_tower()

	_current_buy_delay = _get_new_buy_delay()
	_time_since_buy_request = 0.0


## Отключает магазин и прекращает его отображение. Вызывается автоматически
## после покупки башни.
func deactivate() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED
	Log.debug("Магазин %s отключен" % name)


## Текущая задержка между прошлой и следующей тратами на башню. [br]
## [br]
## Когда этот период проходит, срабатывает сигнал [signal spend_coins_request].
func get_current_buy_delay() -> float:
	return _current_buy_delay


func _get_new_buy_delay() -> float:
	# В теории, это можно заменить на кривую/график.
	return lerpf(
		Config.tower_buy_animation_max_delay,
		Config.tower_buy_animation_min_delay,
		min(1.0, _hold_time / Config.tower_buy_animation_time_to_full_speed),
	)


func _spawn_tower() -> void:
	_tower.modulate = _tower_orignal_modulate
	_tower.process_mode = Node.PROCESS_MODE_INHERIT
	bought.emit(self)
	deactivate()
	Log.info("Новая башня куплена, стоимость = %s, название = %s" % [cost, _tower.name])
