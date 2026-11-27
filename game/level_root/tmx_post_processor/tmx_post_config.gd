class_name TmxPostConfig
extends Resource

## Название слоя со спавном сущностей.
@export var spawn_layer_name: String = "spawn"

## Название слоя со стенами.
@export var wall_layer_name: String = "walls"

@export_group("Player")

## Тайл с каким тегом отвечает за спавн игрока.
@export var player_tag: String = "player"

## Сцена с игроком для спавна.
@export var player_scene: PackedScene = preload("res://game/player/player.tscn")

@export_group("Enemies")

## Название тега с направлением тайла.
@export var direction_key: String = "direction"

## По какому тегу и что спавнить?
@export var spawn_map: Dictionary[String, PackedScene] = { }
