class_name SpawnConfig
extends Resource

## Какой слой для спавна?
@export var spawn_layer_name: String = "spawn"

## Название тега с направлением тайла.
@export var direction_key: String = "direction"

## По какому тегу и что спавнить?
@export var spawn_map: Dictionary[String, PackedScene] = { }
