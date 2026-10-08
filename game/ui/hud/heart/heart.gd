class_name UIHeart extends Control

enum State {
	EMPTY,
	HALF,
	FULL,
}

@onready var textures: Dictionary = {
	State.EMPTY: $EmptyHeart,
	State.HALF: $HalfHeart,
	State.FULL: $FullHeart,
}


func set_state(state: State) -> void:
	for key in textures:
		textures[key].visible = false
	textures[state].visible = true
