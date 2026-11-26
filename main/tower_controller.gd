class_name TowerController

signal tower_bought

var towers: Array[BaseTower]
var bank: Bank
var player: Player
var bullet_controller: BulletController

var world_node: Node2D
var tower_parent: Node2D
var tower_for_sale_parent: Node2D

var vfx_earn_money_scene := preload("uid://bao7joqjvbo8d")
var tower_on_sale_scene := preload("uid://deikrp0xtp5sx")
var tower_scene_by_kind: Dictionary = {
	Tower.Kind.PLAYER_SHOOTER: preload("uid://cddl2vlq7y4da"),
	Tower.Kind.RADIAL_SHOOTER: preload("uid://c5rpryhtwlqdb"),
	Tower.Kind.LINE_SHOOTER: preload("uid://cebhlbd5lvb1u"),
	Tower.Kind.TRIANGLE: preload("uid://cvp6g6h0jx0co"),
}
var sprite_frames_by_kind: Dictionary = {
	Tower.Kind.PLAYER_SHOOTER: preload("uid://cvex7dy365koe"),
	Tower.Kind.RADIAL_SHOOTER: preload("uid://b0dviuofy8rv7"),
	Tower.Kind.LINE_SHOOTER: preload("uid://d3vm2qri15dpw"),
	Tower.Kind.TRIANGLE: preload("uid://dg6srh3x4pdyq"),
}

# сколько заработано в каждой точке за этот кадр
var earned_by_position: Dictionary[Vector2, int] = {}


func _init(world_node_: Node2D, bank_: Bank, player_: Player, bullet_controller_: BulletController) -> void:
	tower_parent = Node2D.new()
	tower_parent.name = "Towers"
	world_node_.add_child(tower_parent)

	tower_for_sale_parent = Node2D.new()
	tower_for_sale_parent.name = "TowersForSale"
	world_node_.add_child(tower_for_sale_parent)

	self.bank = bank_
	self.player = player_
	self.world_node = world_node_
	self.bullet_controller = bullet_controller_


func create_tower_on_sale(
	kind: Tower.Kind,
	position: Vector2,
	cost: int,
	music_config: MusicConfig,
) -> TowerOnSale:
	var tower_on_sale := tower_on_sale_scene.instantiate()
	tower_on_sale.kind = kind
	tower_on_sale.cost = cost
	tower_on_sale.position = position
	tower_on_sale.bought.connect(on_tower_bought)
	tower_on_sale.music_config = music_config
	tower_on_sale.buy_tick.connect(
		func():
			if bank.spend(1):
				tower_on_sale.tick_buy(),
	)
	tower_for_sale_parent.add_child(tower_on_sale)
	tower_on_sale.sprite.frames = sprite_frames_by_kind[kind]
	if kind == Tower.Kind.LINE_SHOOTER:
		LineShooter.setup_on_sale(tower_on_sale)
	elif kind == Tower.Kind.TRIANGLE:
		Triangle.setup_on_sale(tower_on_sale)
	else:
		tower_on_sale.sprite.play("inactive")
	return tower_on_sale


func on_tower_bought(tower_on_sale: TowerOnSale) -> void:
	var kind := tower_on_sale.kind

	var tower: BaseTower = tower_scene_by_kind[kind].instantiate()
	tower.kind = kind
	tower.position = tower_on_sale.position
	tower.sound = tower_on_sale.music_config.sound
	tower.timing = tower_on_sale.music_config.timing
	if kind == Tower.Kind.PLAYER_SHOOTER:
		tower.target = player
	elif kind == Tower.Kind.LINE_SHOOTER:
		tower.take_direction_from(tower_on_sale)
	tower.shot.connect(bullet_controller.spawn_bullet)
	tower.shot.connect(award_money)
	tower_parent.add_child(tower)

	towers.append(tower)
	tower_on_sale.queue_free()

	tower_bought.emit()


func award_money(position: Vector2, _direction: Vector2) -> void:
	var amount := 1 # :(
	bank.earn(amount)
	if not earned_by_position.has(position):
		show_earned_money.call_deferred(position)
	earned_by_position[position] = earned_by_position.get(position, 0) + amount


func show_earned_money(position: Vector2) -> void:
	var vfx_earn_money := vfx_earn_money_scene.instantiate() as Label
	vfx_earn_money.text = "+%d" % earned_by_position[position]
	vfx_earn_money.position = position + Vector2(-6, -12)
	world_node.add_child(vfx_earn_money)
	earned_by_position.erase(position)
