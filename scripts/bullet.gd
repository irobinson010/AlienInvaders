extends Area2D

var direction := Vector2.RIGHT
var speed := 860.0
var damage := 1
var lifetime := 1.6
var radius := 6.0
var core_color := Color8(255, 241, 196)
var tail_color := Color8(255, 185, 71)


func _ready() -> void:
	z_index = 24
	collision_layer = 4
	collision_mask = 2
	monitoring = true
	monitorable = false
	body_entered.connect(_on_body_entered)

	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = radius
	collision.shape = shape
	add_child(collision)


func configure(new_direction: Vector2, new_speed: float = 860.0, new_damage: int = 1, new_lifetime: float = 1.6, new_radius: float = 6.0, new_core_color: Color = Color8(255, 241, 196), new_tail_color: Color = Color8(255, 185, 71)) -> void:
	direction = new_direction.normalized()
	speed = new_speed
	damage = new_damage
	lifetime = new_lifetime
	radius = new_radius
	core_color = new_core_color
	tail_color = new_tail_color
	rotation = direction.angle()


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	lifetime -= delta

	if lifetime <= 0.0:
		queue_free()
		return

	if global_position.x < -120.0 or global_position.x > 1400.0 or global_position.y < -120.0 or global_position.y > 840.0:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("aliens") and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, core_color)
	draw_rect(Rect2(Vector2(0.0, -maxf(2.0, radius * 0.4)), Vector2(8.0 + radius, maxf(4.0, radius * 0.8))), tail_color)
