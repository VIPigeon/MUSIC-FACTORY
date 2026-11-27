@tool
class_name TowerOnSale
extends Node2D

## Нужная сумма потрачена и башня теперь куплена (активна).
signal bought(tower: Node2D)

## Запрос потратить монетки игрока (прошлый buy_tick). [br]
## [br]
## Срабатывает если игрок находится в зоне продажи башни и cooldown прошлой траты уже прошёл.
## Если монеток достаточно, необходимо вызвать [member spend_coins]. В противном случае
## надо вызвать [member reject_spend_coins].
signal spend_coins_request(coins: int)

## Подпись со стоимостью башни.
@onready var cost_label: Label = $CostLabel

## Зона покупки башни. Игрок должен находится в её пределах для вычета монет.
@onready var buy_area: Area2DInsideChecker = $Area2D


## Стоимость покупки башни.[br]
## [br]
## Если изменяется во время игры, то [member remain_cost] сбрасывается.
@export var cost: int = -1:
	set(value):
		cost = value
		remain_cost = cost

## Конфигурация музыки башни.
@export var music_config: MusicConfig

## Фильтр цвета для неактивной башни.
@export var inactive_color_filter: Color = Color(0.412, 0.412, 0.412, 0.784)

## Направление, в котором спавнить башню.
@export var direction: Vector2 = Vector2.DOWN

## Под каким узлом создавать башню.[br]
## [br]
## Если этот параметр не определён, то башня создаётся под родителем магазина,
## то есть будет соседом (sibling) магазина.
@export var tower_container: Node:
	set(value):
		if tower_container == value:
			return

		tower_container = value
		if Engine.is_editor_hint():
			update_configuration_warnings()

		if _tower == null or tower_container == null:
			return

		if _tower.is_inside_tree():
			_tower.reparent(tower_container)
		else:
			tower_container.add_child(_tower)

## Какую башню (сцену) спавнить.
@export var tower_scene: PackedScene:
	set(value):
		tower_scene = value

		if Engine.is_editor_hint():
			update_configuration_warnings()

		if tower_scene == null:
			_tower = null
			return

		_tower = tower_scene.instantiate()


## Сколько осталось до покупки башни. Изначально равно [member cost].
var remain_cost: int = cost:
	set(value):
		remain_cost = value
		if cost_label != null: # инициализируется раньше дочернего label
			cost_label.text = str(remain_cost)
		if Engine.is_editor_hint():
			update_configuration_warnings()

var _tower: Node2D = null:
	set(value):
		if _tower != null:
			_tower.queue_free()

		_tower = value
		if _tower == null:
			return

		_tower.process_mode = Node.PROCESS_MODE_DISABLED
		_tower_orignal_modulate = _tower.modulate
		_tower.modulate = inactive_color_filter
		_tower.global_position = global_position

		if _tower.get_parent() != null:
			return

		# отложенный запуск, ибо контейнер может ещё не существовать.
		_assign_parent_to_tower.call_deferred()
		# и направления тоже ещё может не быть.
		_assign_direction.call_deferred()

var _tower_orignal_modulate: Color = Color.WHITE

var _hold_time: float = 0.0
var _time_since_buy_request: float = 0.0
var _current_buy_delay: float = 0.0
var _is_player_inside: bool = false

enum RequestStatus {
	NOT_SENT,
	SENT_AWAITING,
	PROCESSED,
}
var _request_status: RequestStatus = RequestStatus.NOT_SENT


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	if cost < 0:
		Log.warn("Стоимость башни не определена (меньше 0)")
	remain_cost = cost

	if _tower == null:
		Log.err("Башня не была создана, магазин отключается. Ошибка конфигурации?")
		deactivate()
		return

	if remain_cost == 0:
		_spawn_tower()


# Отобразить башню в редакторе (добавить preview)
func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		return
	tower_scene = tower_scene # триггер сеттера


# Убрать отображение башни в редакторе (убрать preview)
func _exit_tree() -> void:
	if not Engine.is_editor_hint():
		return
	_tower = null


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	var was_player_inside: bool = _is_player_inside
	_is_player_inside = buy_area.is_something_inside()

	if not _is_player_inside:
		if was_player_inside:
			Log.debug("Игрок покинул в зону магазина %s" % name)
		_hold_time = 0.0
		_time_since_buy_request = 0.0
		return

	if not was_player_inside:
		# первый тик покупки
		Log.debug("Игрок вошёл в зону магазина %s" % name)
		if _request_status != RequestStatus.SENT_AWAITING:
			Log.debug("Отправлен первый запрос потратить монетки в магазине %s" % name)
			spend_coins_request.emit(1)
			_request_status = RequestStatus.SENT_AWAITING
		return

	# внутри не первый тик
	_hold_time += delta
	_time_since_buy_request += delta

	var is_enough_time_passed: bool = _time_since_buy_request > _current_buy_delay
	var is_request_ready: bool = _request_status != RequestStatus.SENT_AWAITING
	if is_enough_time_passed and is_request_ready:
		spend_coins_request.emit(1)
		_request_status = RequestStatus.SENT_AWAITING
		Log.debug("Отправлен запрос потратить монетки в магазине %s" % name)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []

	if cost < 0:
		var msg := "Стоимость башни не определена (cost = %s < 0)" % cost
		warnings.push_back(msg)

	if tower_scene == null:
		var msg := "Не указана сцена башни. Неизвестно, что спавнить при покупке."
		warnings.push_back(msg)

	if tower_container == null:
		var msg := "Не указан контейнер для спавна башни."
		warnings.push_back(msg)

	return warnings


## Отклонить сигнал [signal spend_coins_request]; не тратить монетки.
func reject_spend_coins() -> void:
	if _request_status != RequestStatus.SENT_AWAITING:
		Log.warn("Обработка запроса, хотя его статус не 'SENT_AWAITING'")
	_request_status = RequestStatus.PROCESSED


## Потратить [param spent] монеток на башню. [br]
## [br]
## Также смотри [signal spend_coins_request].
func spend_coins(spent: int = 1) -> void:
	if _request_status != RequestStatus.SENT_AWAITING:
		Log.warn("За башню списываются деньги, хотя статус запроса не 'SENT_AWAITING'")

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
	_request_status = RequestStatus.PROCESSED


## Отключает магазин и прекращает его отображение. Вызывается автоматически
## после покупки башни вместе с сигналом [signal bought].
func deactivate() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED
	Log.debug("Магазин %s отключен" % name)


## Сколько игрок уже непрерывно находится в области магазина?
func get_hold_time() -> float:
	return _hold_time


## Сколько времени прошло с прошлого запроса потратить монеты [singal spend_coins_request].
func get_time_since_buy_request() -> float:
	return _time_since_buy_request


## Текущая задержка между прошлой и следующей тратами на башню. [br]
## [br]
## Когда этот период проходит, срабатывает сигнал [signal spend_coins_request].
func get_current_buy_delay() -> float:
	return _current_buy_delay


## Игрок сейчас в области магазина?
func get_is_player_inside() -> bool:
	return _is_player_inside


## Возвращает башню, за которую отвечает этот магазин.
func get_tower() -> Node2D:
	return _tower


func _get_new_buy_delay() -> float:
	# NOTE: В теории, это можно заменить на кривую/график.
	return lerpf(
		Config.tower_buy_animation_max_delay,
		Config.tower_buy_animation_min_delay,
		min(1.0, _hold_time / Config.tower_buy_animation_time_to_full_speed),
	)


func _spawn_tower() -> void:
	_tower.modulate = _tower_orignal_modulate
	_tower.process_mode = Node.PROCESS_MODE_INHERIT
	bought.emit(_tower)
	deactivate()
	Log.info("Новая башня куплена, стоимость = %s, название = %s" % [cost, _tower.name])


func _assign_parent_to_tower() -> void:
	if _tower.get_parent() != null:
		return

	if tower_container == null:
		add_sibling(_tower)
		if not Engine.is_editor_hint():
			Log.warn("Не указан контейнер для башни, башня будет создана как сосед магазина")
	else:
		tower_container.add_child(_tower)


func _assign_direction() -> void:
	# TODO я хз как это для других башен потом делать. Нужен какой-то общий интерфейс.
	if _tower is LineShooter:
		var line_direction: LineShooter.Direction = LineShooter.VECTOR_BY_DIRECTION.find_key(
			direction
		)
		Log.debug(
			"Для башни установлено направление %s" % LineShooter.Direction.find_key(line_direction)
		)
		_tower.direction = line_direction
