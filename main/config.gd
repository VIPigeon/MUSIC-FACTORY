class_name ConfigGlobal extends Node

@export_category("Player")
@export var player_speed: float = 40.0
@export var player_health: int = 6
@export var endgame_survival_time: float = 30.0
@export_range(0, 500, 5.0) var starting_money: int = 10


@export_category("Rhythm")
@export var bpm: float = 60.0
@export var beats_in_tact: int = 16


@export_category("Dev")
@export var godmode: bool = false


@export_category("Tower buy animation")
@export_range(0.01, 1.0) var tower_buy_animation_min_delay: float = 0.07
@export_range(0.01, 1.0) var tower_buy_animation_max_delay: float = 0.40
@export_range(0.0, 3.0) var tower_buy_animation_time_to_full_speed: float = 1.5


@export_category("Bullets")
## Скорость пуль в `Пикселях / Секунду`
@export var bullet_speed: float = 20.0
