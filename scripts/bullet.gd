extends Area2D

var direction := Vector2.RIGHT
var speed := 860.0
var damage := 1
var lifetime := 1.6


func _ready() -> void:
	z_index = 24
	collision_layer = 4
	collision_mask = 2
	monitoring = true
	monitorable = false
	body_entered.connect(_on_body_entered)

	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 6.0
	collision.shape = shape
	add_child(collision)


func configure(new_direction: Vector2, new_speed: float = 860.0, new_damage: int = 1) -> void:
	direction = new_direction.normalized()
	speed = new_speed
	damage = new_damage
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
	draw_circle(Vector2.ZERO, 5.0, Color8(255, 241, 196))
	draw_rect(Rect2(Vector2(0.0, -2.0), Vector2(14.0, 4.0)), Color8(255, 185, 71))
