class_name TowerOnSale extends Node2D

signal bought
signal buy_tick

@onready var cost_label: Label = $CostLabel
@onready var buy_area: Area2DInsideChecker = $BuyArea
@onready var sprite := $AnimatedSprite2D

var cost: int
var kind: Tower.Kind
var buy_in_progress: bool = false

var hold_time: float = 0.0
var current_hold_time: float = 0.0
var current_buy_delay: float = 0.0

var music_config: MusicConfig


func _process(delta: float) -> void:
	if buy_in_progress:
		if current_hold_time > current_buy_delay:
			buy_tick.emit()
		else:
			current_hold_time += delta
			hold_time += delta
	else:
		current_buy_delay = 0.0
		current_hold_time = 0.0
		hold_time = 0.0

	cost_label.text = str(cost)
	var buy_was_in_progress := buy_in_progress
	buy_in_progress = buy_area.is_something_inside()
	if !buy_was_in_progress and buy_in_progress:
		buy_tick.emit()


func tick_buy() -> void:
	if cost > 0:
		cost -= 1
		current_buy_delay = lerpf(
			Config.tower_buy_animation_max_delay,
			Config.tower_buy_animation_min_delay,
			min(1.0, hold_time / Config.tower_buy_animation_time_to_full_speed),
		)
		current_hold_time = 0.0

	if cost == 0:
		bought.emit(self)
