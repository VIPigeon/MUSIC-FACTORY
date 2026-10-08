class_name BulletController

var bullet_parent: Node2D

var bullet_scene := preload("uid://bu4ig5joh4xnx")


func _init(world_node: Node2D) -> void:
	bullet_parent = Node2D.new()
	bullet_parent.name = "Bullets"
	world_node.add_child(bullet_parent)


func spawn_bullet(position: Vector2, direction: Vector2) -> void:
	var bullet := bullet_scene.instantiate()
	bullet.position = position
	bullet.direction = direction
	bullet.area_entered.connect(
		func(area: Area2D):
			_on_bullet_area_entered(area)
			bullet.queue_free(),
	)
	bullet_parent.add_child(bullet)


func _on_bullet_area_entered(area: Area2D) -> void:
	var player := area as Player
	if player != null:
		player.take_damage()
