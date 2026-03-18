extends Area2D

var direction := Vector2.RIGHT
var speed := 860.0
var damage := 1
var lifetime := 1.6
var radius := 6.0
var core_color := Color8(255, 241, 196)
var tail_color := Color8(255, 185, 71)
var damage_falloff_start := -1.0
var damage_falloff_end := -1.0
var minimum_damage := 1
var distance_traveled := 0.0


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


func configure(new_direction: Vector2, new_speed: float = 860.0, new_damage: int = 1, new_lifetime: float = 1.6, new_radius: float = 6.0, new_core_color: Color = Color8(255, 241, 196), new_tail_color: Color = Color8(255, 185, 71), new_damage_falloff_start: float = -1.0, new_damage_falloff_end: float = -1.0, new_minimum_damage: int = 1) -> void:
	direction = new_direction.normalized()
	speed = new_speed
	damage = new_damage
	lifetime = new_lifetime
	radius = new_radius
	core_color = new_core_color
	tail_color = new_tail_color
	damage_falloff_start = new_damage_falloff_start
	damage_falloff_end = new_damage_falloff_end
	minimum_damage = new_minimum_damage
	distance_traveled = 0.0
	rotation = direction.angle()


func _physics_process(delta: float) -> void:
	var start_position := global_position
	var end_position := start_position + direction * speed * delta
	var query := PhysicsRayQueryParameters2D.new()
	query.from = start_position
	query.to = end_position
	query.collision_mask = collision_mask
	query.collide_with_bodies = true
	query.collide_with_areas = false
	query.hit_from_inside = true
	query.exclude = [get_rid()]

	var hit: Dictionary = get_world_2d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		var hit_position: Vector2 = hit.get("position", end_position)
		distance_traveled += start_position.distance_to(hit_position)
		global_position = hit_position
		var collider: Variant = hit.get("collider")
		_damage_target(collider)
		return

	global_position = end_position
	distance_traveled += start_position.distance_to(end_position)
	lifetime -= delta

	if lifetime <= 0.0:
		queue_free()
		return

	if _has_damage_falloff() and minimum_damage <= 0 and distance_traveled >= damage_falloff_end:
		queue_free()
		return

	if global_position.x < -120.0 or global_position.x > 1400.0 or global_position.y < -120.0 or global_position.y > 840.0:
		queue_free()


func _on_body_entered(body: Node) -> void:
	_damage_target(body)


func _damage_target(target: Variant) -> void:
	if not (target is Node):
		return

	var body: Node = target as Node
	if not body.is_in_group("aliens"):
		return

	var effective_damage := _effective_damage()
	if effective_damage <= 0:
		queue_free()
		return

	if body.has_method("take_projectile_damage"):
		body.take_projectile_damage(effective_damage, -direction)
		queue_free()
		return

	if body.has_method("take_damage"):
		body.take_damage(effective_damage)
		queue_free()


func _has_damage_falloff() -> bool:
	return damage_falloff_start >= 0.0 and damage_falloff_end > damage_falloff_start


func _effective_damage() -> int:
	if not _has_damage_falloff():
		return damage
	if distance_traveled <= damage_falloff_start:
		return damage
	if distance_traveled >= damage_falloff_end:
		return minimum_damage

	var ratio := 1.0 - ((distance_traveled - damage_falloff_start) / (damage_falloff_end - damage_falloff_start))
	var scaled_damage := roundi(float(damage) * ratio)
	return clampi(scaled_damage, minimum_damage, damage)


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, core_color)
	draw_rect(Rect2(Vector2(0.0, -maxf(2.0, radius * 0.4)), Vector2(8.0 + radius, maxf(4.0, radius * 0.8))), tail_color)
