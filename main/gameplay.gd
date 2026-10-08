class_name Gameplay

enum State {
	PREPARING,
	RUNNING,
	ENDGAME,
}

signal victory
signal loss

var world_node: Node2D
var gui_node: Control

var tower_controller: TowerController
var bullet_controller: BulletController
var rhythm_shooting: RhythmShooting
var player: Player
var player_bank: Bank
var hud: HUD

var game_rect: Rect2
var state: State
var survival_time: float
var track_config: Array[MusicConfig]

var hud_scene := preload("uid://b20kj0ig0pnw4")
var player_scene := preload("uid://kcxl4qh3oikg")


func _init(world_node_: Node2D, gui_node_: Control) -> void:
	self.world_node = world_node_
	self.gui_node = gui_node_
	self.player_bank = Bank.new(Config.starting_money)
	self.game_rect = Rect2(Vector2(0, 0), Vector2(240, 135))


func tick(delta: float) -> void:
	rhythm_shooting.tick(delta)

	if player != null:
		var player_rect := Rect2(player.position - Vector2(3.0, 3.0), Vector2(6, 6))
		if !game_rect.encloses(player_rect):
			player.position = player.last_position

	if state == State.ENDGAME:
		survival_time -= delta
		hud.show_survival_time_left(survival_time)
		if survival_time <= 0:
			victory.emit()


func create_base_game() -> void:
	if state != State.PREPARING:
		return
	state = State.RUNNING

	var costs: Array[int] = [10, 10, 30, 30, 60, 60, 60, 120]
	track_config = [
		MusicConfig.new(preload("res://resource/sound/drum1.wav"), 16),
		MusicConfig.new(preload("res://resource/sound/drum2.wav"), 16),
		MusicConfig.new(preload("res://resource/sound/drum3.wav"), 8),
		MusicConfig.new(preload("res://resource/sound/drum4.wav"), 8),
		MusicConfig.new(preload("res://resource/sound/synth1.wav"), 32),
		MusicConfig.new(preload("res://resource/sound/synth2.wav"), 16),
		MusicConfig.new(preload("res://resource/sound/synth3.wav"), 2),
		MusicConfig.new(preload("res://resource/sound/synth4.wav"), 4),
	]

	generate_starting_field(costs, track_config)


func generate_starting_field(costs: Array[int], music_config_: Array[MusicConfig]) -> void:
	var pad := 8

	var window_size := Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height"),
	)
	var field_rect := Rect2(Vector2(pad, pad), Vector2(window_size) - 2 * Vector2(pad, pad))

	var player_position = random_position_in_rect(field_rect)
	player = player_scene.instantiate()
	player.position = player_position
	player.health.dead.connect(loss.emit)
	world_node.add_child(player)

	hud = hud_scene.instantiate()
	hud.heart_bar.health = player.health
	gui_node.add_child(hud)
	hud.currency.show_currency(player_bank.money.value)
	player_bank.money.changed.connect(
		func(money: int):
			hud.currency.show_currency(money),
	)

	bullet_controller = BulletController.new(world_node)
	tower_controller = TowerController.new(world_node, player_bank, player, bullet_controller)
	tower_controller.tower_bought.connect(on_tower_bought)
	rhythm_shooting = RhythmShooting.new(tower_controller)

	var last: TowerOnSale
	for i in range(len(costs)):
		var tower_position = random_position_in_rect(field_rect)
		while tower_position.distance_to(player.position) < 10.0:
			tower_position = random_position_in_rect(field_rect)
		var kind := Tower.Kind.RADIAL_SHOOTER if randi_range(0, 1) == 0 else Tower \
				.Kind \
				.PLAYER_SHOOTER
		last = tower_controller.create_tower_on_sale(
			kind,
			tower_position,
			costs[i],
			music_config_[i],
		)
	tower_controller.on_tower_bought(last)


func random_position_in_rect(rect: Rect2) -> Vector2:
	return Vector2(
		randf_range(rect.position.x, rect.position.x + rect.size.x),
		randf_range(rect.position.y, rect.position.y + rect.size.y),
	)


func start_endgame() -> void:
	hud.start_survival_timer()
	state = State.ENDGAME
	survival_time = Config.endgame_survival_time


func create_speed_up() -> void:
	if state != State.PREPARING:
		return
	# А тут ничего не поменялось! TODO
	create_base_game()


func on_tower_bought() -> void:
	if len(tower_controller.towers) == len(track_config):
		start_endgame()
