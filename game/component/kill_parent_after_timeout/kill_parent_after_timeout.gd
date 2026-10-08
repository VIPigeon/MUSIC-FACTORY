@icon("uid://g5wiwnmlff53")
extends Timer


func _ready() -> void:
	timeout.connect(
		func():
			get_parent().queue_free(),
	)
