extends CharacterBody2D

signal destroyed(scrap_value: int, world_position: Vector2)
signal farmhouse_hit(damage: int)

var target_position := Vector2.ZERO
var speed := 90.0
var health := 2
var scrap_value := 2
var stun_timer := 0.0
var was_stunned := false


func _ready() -> void:
	z_index = 18
	collision_layer = 2
	collision_mask = 0
	add_to_group("aliens")

	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 22.0
	collision.shape = shape
	add_child(collision)


func configure(spawn_position: Vector2, goal_position: Vector2, current_wave: int) -> void:
	global_position = spawn_position
	target_position = goal_position
	speed = 88.0 + randf_range(0.0, 28.0 + float(current_wave) * 8.0)
	health = 1 + int(floor(float(current_wave - 1) / 3.0))
	scrap_value = 2 + int(floor(float(current_wave - 1) / 4.0))


func _physics_process(delta: float) -> void:
	if stun_timer > 0.0:
		stun_timer = maxf(0.0, stun_timer - delta)
		velocity = Vector2.ZERO
		move_and_slide()
		if not was_stunned or stun_timer <= 0.0:
			was_stunned = stun_timer > 0.0
			queue_redraw()
		return

	var offset := target_position - global_position
	if offset.length() <= 30.0:
		farmhouse_hit.emit(1)
		queue_free()
		return

	var direction := offset.normalized()
	rotation = direction.angle()
	velocity = direction * speed
	move_and_slide()
	if was_stunned:
		was_stunned = false
		queue_redraw()


func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		destroyed.emit(scrap_value, global_position)
		queue_free()


func apply_stun(duration: float) -> void:
	stun_timer = maxf(stun_timer, duration)
	if not was_stunned:
		was_stunned = true
		queue_redraw()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 20.0, Color8(129, 238, 126))
	draw_circle(Vector2(-8.0, -4.0), 5.0, Color8(33, 42, 27))
	draw_circle(Vector2(8.0, -4.0), 5.0, Color8(33, 42, 27))
	draw_circle(Vector2.ZERO, 9.0, Color8(171, 255, 146))
	draw_line(Vector2(-20.0, 8.0), Vector2(-32.0, 18.0), Color8(129, 238, 126), 4.0, true)
	draw_line(Vector2(20.0, 8.0), Vector2(32.0, 18.0), Color8(129, 238, 126), 4.0, true)
	if stun_timer > 0.0:
		draw_arc(Vector2.ZERO, 28.0, -0.6, 0.6, 18, Color8(145, 214, 255), 4.0, true)
		draw_arc(Vector2.ZERO, 34.0, 2.54, 3.74, 18, Color8(145, 214, 255), 4.0, true)
