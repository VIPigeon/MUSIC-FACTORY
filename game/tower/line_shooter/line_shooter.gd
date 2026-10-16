class_name LineShooter extends BaseTower

enum Direction { RIGHT, LEFT, DOWN, UP }

const VECTOR_BY_DIRECTION := {
	Direction.RIGHT: Vector2.RIGHT,
	Direction.LEFT: Vector2.LEFT,
	Direction.DOWN: Vector2.DOWN,
	Direction.UP: Vector2.UP,
}

const INACTIVE_COLOR := Color(0.6, 0.6, 0.6)
const SALE_DIRECTION_META := &"line_shooter_direction"

@export var direction := Direction.RIGHT

@onready var sprite := $AnimatedSprite2D


func _ready() -> void:
	play_animation(sprite, direction, "idle")
	sprite.animation_finished.connect(
		func():
			play_animation(sprite, direction, "idle"),
	)
	player = $AudioStreamPlayer2D


func shoot() -> void:
	play_animation(sprite, direction, "shoot")
	super._shoot(VECTOR_BY_DIRECTION[direction])


## готовит клавишу на продаже: случайное направление и затемненный спрайт.
static func setup_on_sale(tower_on_sale: TowerOnSale) -> void:
	# TODO пока направление случайное
	# когда генерация будет задавать его сама, передавать направление параметром сюда
	var direction_: Direction = Direction.values().pick_random()
	# запоминаем направление прямо на продающейся башне, его заберет купленная
	tower_on_sale.set_meta(SALE_DIRECTION_META, direction_)
	play_animation(tower_on_sale.sprite, direction_, "idle")
	tower_on_sale.sprite.modulate = INACTIVE_COLOR


func take_direction_from(tower_on_sale: TowerOnSale) -> void:
	direction = tower_on_sale.get_meta(SALE_DIRECTION_META)


static func play_animation(sprite_: AnimatedSprite2D, direction_: Direction, action: String) -> void:
	var horizontal := direction_ == Direction.RIGHT or direction_ == Direction.LEFT
	sprite_.flip_h = direction_ == Direction.LEFT
	sprite_.flip_v = direction_ == Direction.UP
	sprite_.play(action + ("_horizontal" if horizontal else "_vertical"))
