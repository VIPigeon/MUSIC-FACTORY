class_name RhythmShooting

var bpm: float
var current_time: float
var quarter_beats: int
var tower_controller: TowerController


func _init(tower_controller_: TowerController) -> void:
	self.tower_controller = tower_controller_
	self.bpm = Config.bpm


func tick(delta: float) -> void:
	current_time += delta
	if current_time > seconds_per_quarter_beat():
		current_time -= seconds_per_quarter_beat()
		on_quarter_beat()


func set_bpm(new_bpm: float) -> void:
	if new_bpm == bpm:
		return

	bpm = new_bpm
	current_time = 0.0


func seconds_per_quarter_beat() -> float:
	return seconds_per_beat() / 4.0


func seconds_per_beat() -> float:
	return 60.0 / bpm


func on_quarter_beat() -> void:
	quarter_beats += 1
	quarter_beats %= 64

	for tower in tower_controller.towers:
		if quarter_beats % tower.timing == 0:
			if tower.kind == Tower.Kind.PLAYER_SHOOTER:
				tower.shoot()
			elif tower.kind == Tower.Kind.RADIAL_SHOOTER:
				tower.shoot()
