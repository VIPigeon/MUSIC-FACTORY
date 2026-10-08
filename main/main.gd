class_name Main extends Node

enum GameState {
	MAIN_MENU,
	GAMEPLAY,
	VICTORY,
}

@onready var world_node := $World
@onready var gui_node := $GUI

var start_screen_scene := preload("uid://m3pmo1yhup8a")
var victory_screen_scene := preload("uid://ctnxptsonhabb")

var music_config: Array[MusicConfig]
var current_gameplay: Gameplay


func _ready() -> void:
	var start_screen := start_screen_scene.instantiate()
	start_screen.base_game_started.connect(
		func():
			delete_current_scene()
			var gameplay := Gameplay.new(world_node, gui_node)
			gameplay.victory.connect(on_victory)
			gameplay.loss.connect(on_loss)
			gameplay.create_base_game()

			current_gameplay = gameplay,
	)
	start_screen.speed_up_started.connect(
		func():
			delete_current_scene()
			var gameplay := Gameplay.new(world_node, gui_node)
			gameplay.victory.connect(on_victory)
			gameplay.loss.connect(on_loss)
			gameplay.create_speed_up()

			current_gameplay = gameplay,
	)
	gui_node.add_child(start_screen)


func _process(delta: float) -> void:
	if current_gameplay != null:
		current_gameplay.tick(delta)


func on_victory() -> void:
	delete_current_scene()
	var victory_screen := victory_screen_scene.instantiate()
	gui_node.add_child(victory_screen)
	current_gameplay = null


func on_loss() -> void:
	print("LOSER!")
	pass


func delete_current_scene() -> void:
	for child in world_node.get_children():
		child.queue_free()

	for child in gui_node.get_children():
		child.queue_free()
