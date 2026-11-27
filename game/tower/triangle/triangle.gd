class_name Triangle extends BaseTower

const INACTIVE_COLOR := Color(0.6, 0.6, 0.6)

## на сколько шагов делится полный оборот. один шаг = один бит из трека
@export var steps_per_turn := 12
## для плавного поворота
@export var turn_time := 0.2

@onready var sprite := $AnimatedSprite2D
## вершины берем прямо из полигона коллизии
@onready var shape: CollisionPolygon2D = $SplitArea/CollisionPolygon2D

var target_rotation := 0.0
var tween: Tween


func _ready() -> void:
	sprite.play("idle")
	$SplitArea.area_entered.connect(_on_split_area_entered)
	player = $AudioStreamPlayer2D


func shoot() -> void:
	target_rotation += TAU / steps_per_turn
	if tween:
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "rotation", target_rotation, turn_time)


## попавший снаряд пропадает, а из центра к каждой вершине вылетает новый
func _on_split_area_entered(area: Area2D) -> void:
	var bullet := area as Bullet
	if bullet == null:
		return
	# свои снаряды вылетают из центра и летят от него
	if bullet.direction.dot(bullet.global_position - global_position) >= 0.0:
		return

	bullet.queue_free()
	for vertex in shape.polygon:
		var direction := (shape.to_global(vertex) - global_position).normalized()
		_shoot.call_deferred(direction)


## готовит треугольник на продаже: затемненный спрайт
static func setup_on_sale(tower_on_sale: TowerOnSale) -> void:
	tower_on_sale.sprite.play("idle")
	tower_on_sale.sprite.modulate = INACTIVE_COLOR
