extends CharacterBody2D

signal destroyed(scrap_value: int, world_position: Vector2)
signal farmhouse_hit(damage: int)
signal drill_site_reached(progress_boost: float)
signal ranged_attack(origin: Vector2, target_position: Vector2, damage: int, projectile_speed: float)
signal damaged(world_position: Vector2, enemy_kind: String)

const KIND_SCOUT := "scout"
const KIND_DRILLER := "driller"
const KIND_HARRIER := "harrier"

var target_position := Vector2.ZERO
var speed := 90.0
var health := 2
var scrap_value := 2
var stun_timer := 0.0
var was_stunned := false
var enemy_kind := KIND_SCOUT
var farmhouse_damage := 1
var drill_progress_boost := 0.0
var body_radius := 20.0
var targets_drill_site := false
var attack_range := 0.0
var attack_interval := 1.45
var attack_cooldown := 0.0
var projectile_speed := 360.0


func _ready() -> void:
	z_index = 18
	collision_layer = 2
	collision_mask = 0
	add_to_group("aliens")

	var collision: CollisionShape2D = CollisionShape2D.new()
	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = body_radius + 4.0
	collision.shape = shape
	add_child(collision)


func configure(spawn_position: Vector2, goal_position: Vector2, current_wave: int, new_enemy_kind: String = KIND_SCOUT, new_targets_drill_site: bool = false) -> void:
	global_position = spawn_position
	target_position = goal_position
	enemy_kind = new_enemy_kind
	targets_drill_site = new_targets_drill_site
	attack_range = 0.0
	attack_interval = 1.45
	attack_cooldown = 0.0
	projectile_speed = 360.0

	match enemy_kind:
		KIND_DRILLER:
			speed = 68.0 + randf_range(0.0, 14.0 + float(current_wave) * 5.0)
			health = 3 + int(floor(float(current_wave - 1) / 2.0))
			scrap_value = 3 + int(floor(float(current_wave - 1) / 3.0))
			farmhouse_damage = 2
			drill_progress_boost = 10.0 + float(current_wave) * 1.5
			body_radius = 24.0
		KIND_HARRIER:
			speed = 76.0 + randf_range(0.0, 16.0 + float(current_wave) * 4.0)
			health = 2 + int(floor(float(current_wave - 1) / 3.0))
			scrap_value = 3 + int(floor(float(current_wave - 1) / 4.0))
			farmhouse_damage = 1 + int(current_wave >= 6)
			drill_progress_boost = 0.0
			body_radius = 18.0
			attack_range = 238.0 + float(current_wave) * 8.0
			attack_interval = maxf(1.0, 1.48 - float(current_wave) * 0.04)
			attack_cooldown = randf_range(0.35, attack_interval)
			projectile_speed = 360.0 + float(current_wave) * 12.0
		_:
			speed = 88.0 + randf_range(0.0, 28.0 + float(current_wave) * 8.0)
			health = 1 + int(floor(float(current_wave - 1) / 3.0))
			scrap_value = 2 + int(floor(float(current_wave - 1) / 4.0))
			farmhouse_damage = 1
			drill_progress_boost = 0.0
			body_radius = 20.0

	queue_redraw()


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
	if enemy_kind == KIND_HARRIER and not targets_drill_site:
		attack_cooldown = maxf(0.0, attack_cooldown - delta)
		if offset.length() <= attack_range:
			velocity = Vector2.ZERO
			rotation = offset.angle()
			move_and_slide()
			if attack_cooldown <= 0.0:
				attack_cooldown = attack_interval
				var muzzle_position := global_position + offset.normalized() * (body_radius + 8.0)
				ranged_attack.emit(muzzle_position, target_position, farmhouse_damage, projectile_speed)
			if was_stunned:
				was_stunned = false
				queue_redraw()
			return

	var contact_distance: float = 36.0 if enemy_kind == KIND_DRILLER else 30.0
	if offset.length() <= contact_distance:
		if targets_drill_site:
			drill_site_reached.emit(drill_progress_boost)
		else:
			farmhouse_hit.emit(farmhouse_damage)
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
	else:
		damaged.emit(global_position, enemy_kind)


func apply_stun(duration: float) -> void:
	stun_timer = maxf(stun_timer, duration)
	if not was_stunned:
		was_stunned = true
		queue_redraw()


func _draw() -> void:
	match enemy_kind:
		KIND_DRILLER:
			draw_circle(Vector2.ZERO, body_radius, Color8(214, 112, 74))
			draw_circle(Vector2(-8.0, -5.0), 5.0, Color8(42, 21, 18))
			draw_circle(Vector2(8.0, -5.0), 5.0, Color8(42, 21, 18))
			draw_rect(Rect2(Vector2(-10.0, 10.0), Vector2(20.0, 8.0)), Color8(255, 184, 112))
			draw_colored_polygon(PackedVector2Array([
				Vector2(0.0, body_radius - 4.0),
				Vector2(-8.0, body_radius + 18.0),
				Vector2(8.0, body_radius + 18.0)
			]), Color8(119, 129, 140))
			draw_line(Vector2(-16.0, 6.0), Vector2(-30.0, 18.0), Color8(214, 112, 74), 5.0, true)
			draw_line(Vector2(16.0, 6.0), Vector2(30.0, 18.0), Color8(214, 112, 74), 5.0, true)
		KIND_HARRIER:
			draw_circle(Vector2.ZERO, body_radius, Color8(122, 163, 236))
			draw_circle(Vector2(-6.0, -5.0), 4.0, Color8(32, 36, 62))
			draw_circle(Vector2(6.0, -5.0), 4.0, Color8(32, 36, 62))
			draw_circle(Vector2.ZERO, 8.0, Color8(198, 225, 255))
			draw_colored_polygon(PackedVector2Array([
				Vector2(-body_radius - 10.0, -2.0),
				Vector2(-6.0, -12.0),
				Vector2(-4.0, 8.0)
			]), Color8(84, 118, 196))
			draw_colored_polygon(PackedVector2Array([
				Vector2(body_radius + 10.0, -2.0),
				Vector2(6.0, -12.0),
				Vector2(4.0, 8.0)
			]), Color8(84, 118, 196))
			draw_rect(Rect2(Vector2(-4.0, 10.0), Vector2(8.0, 10.0)), Color8(255, 184, 94))
		_:
			draw_circle(Vector2.ZERO, body_radius, Color8(129, 238, 126))
			draw_circle(Vector2(-8.0, -4.0), 5.0, Color8(33, 42, 27))
			draw_circle(Vector2(8.0, -4.0), 5.0, Color8(33, 42, 27))
			draw_circle(Vector2.ZERO, 9.0, Color8(171, 255, 146))
			draw_line(Vector2(-20.0, 8.0), Vector2(-32.0, 18.0), Color8(129, 238, 126), 4.0, true)
			draw_line(Vector2(20.0, 8.0), Vector2(32.0, 18.0), Color8(129, 238, 126), 4.0, true)
	if stun_timer > 0.0:
		draw_arc(Vector2.ZERO, 28.0, -0.6, 0.6, 18, Color8(145, 214, 255), 4.0, true)
		draw_arc(Vector2.ZERO, 34.0, 2.54, 3.74, 18, Color8(145, 214, 255), 4.0, true)
