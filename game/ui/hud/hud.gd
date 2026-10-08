class_name HUD extends Control

@export var heart_bar: HUDHeartBar
@export var currency: HUDCurrency
@export var survive_label: Label
@export var time_label: Label

var time_passed: float = 0.0


func _draw() -> void:
	draw_rect(Rect2(Vector2(0.0, 0.0), Vector2(240.0, 135.0)), Color.hex(0x696359FF), false, 1.0)


func _process(delta: float) -> void:
	time_passed += delta
	var minutes := int(time_passed / 60)
	var seconds := int(time_passed - 60 * minutes)
	time_label.text = "%02d:%02d" % [minutes, seconds]


func start_survival_timer() -> void:
	survive_label.visible = true


func show_survival_time_left(time: float) -> void:
	survive_label.text = "00:%02d" % int(ceil(time))
