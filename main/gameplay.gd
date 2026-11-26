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
var music_director: MusicDirector
var player: Player
var player_bank: Bank
var hud: HUD

var game_rect: Rect2
var state: State
var survival_time: float
var track_config: Array[MusicConfig]
var sound_players: Dictionary

var slam_enemy_scene := preload("res://game/slam_enemy/slam_enemy.tscn")
var hud_scene := preload("uid://b20kj0ig0pnw4")
var player_scene := preload("uid://kcxl4qh3oikg")


func _init(world_node_: Node2D, gui_node_: Control) -> void:
	self.world_node = world_node_
	self.gui_node = gui_node_
	self.player_bank = Bank.new(Config.starting_money)
	self.game_rect = Rect2(
		Vector2.ZERO,
		Vector2(
			ProjectSettings.get_setting("display/window/size/viewport_width"),
			ProjectSettings.get_setting("display/window/size/viewport_height"),
		),
	)


func tick(delta: float) -> void:
	music_director.tick(delta)

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
	var tracks_dir := "res://resource/tracks"
	var track_files := DirAccess.get_files_at(tracks_dir)
	var tracks: Array[TowerTrack]
	for track_file in track_files:
		var track := ResourceLoader.load(tracks_dir.path_join(track_file)) as TowerTrack
		assert(track != null, "В папку %s импостора положили" % tracks_dir)
		for sound in track.sounds:
			if sound not in sound_players:
				var audio_player := AudioStreamPlayer.new()
				audio_player.stream = sound
				audio_player.max_polyphony = 8
				sound_players[sound] = audio_player
				world_node.add_child(audio_player)
				
		tracks.append(track)
		
	generate_starting_field(costs, tracks)


func generate_starting_field(costs: Array[int], track_config: Array[TowerTrack]) -> void:
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
	tower_controller.tower_bought.connect(_on_tower_bought)
	music_director = MusicDirector.new()
	music_director.beat.connect(_on_beat)

	# фу.. 🦍
	var slam_enemy := slam_enemy_scene.instantiate()
	var lane_y := game_rect.size.y * (0.75 if player.position.y < game_rect.size.y * 0.5 else 0.25)
	slam_enemy.position = Vector2(game_rect.position.x + 8.0, lane_y)
	world_node.add_child(slam_enemy)
	slam_enemy.setup(music_director, game_rect)

	var last: TowerOnSale
	for i in range(len(costs)):
		var tower_position = random_position_in_rect(field_rect)
		while tower_position.distance_to(player.position) < 10.0:
			tower_position = random_position_in_rect(field_rect)
		var kind: Tower.Kind = Tower.Kind.values().pick_random()
		last = tower_controller.create_tower_on_sale(
			kind,
			tower_position,
			costs[i],
			track_config[i],
		)
	
	if Config.dev_mode:
		for tower in tower_controller.towers_on_sale:
			tower_controller.on_tower_bought(tower)
	else:
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


func _on_tower_bought() -> void:
	if len(tower_controller.towers) == len(track_config):
		start_endgame()


func _on_beat(_tact: int, beat: int) -> void:
	for tower in tower_controller.towers:
		assert(tower.track != null, "Кто-то неправильно настроил врага! Ай-яй-яй!")
		var track := tower.track as TowerTrack
		var sound_index := track.tacts[beat]
		if sound_index != 0:
			var sound := track.sounds[sound_index - 1]
			tower.shoot()
			print("PLAY ", beat, sound)
			sound_players[sound].play()
