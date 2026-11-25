class_name TmxPostConfig
extends Resource

## Название слоя со спавном сущностей.
@export var spawn_layer_name: String = "spawn"

## Название слоя со стенами.
@export var wall_layer_name: String = "walls"

## Название тега с направлением тайла.
@export var direction_key: String = "direction"

## По какому тегу и что спавнить?
@export var spawn_map: Dictionary[String, PackedScene] = { }
