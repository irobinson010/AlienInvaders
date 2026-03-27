extends CharacterBody2D

signal destroyed(scrap_value: int, world_position: Vector2)
signal farmhouse_hit(damage: int)
signal structure_hit(structure_id: String, damage: int)
signal drill_site_reached(progress_boost: float)
signal ranged_attack(origin: Vector2, target_position: Vector2, damage: int, projectile_speed: float, target_structure_id: String)
signal damaged(world_position: Vector2, enemy_kind: String)

const KIND_SCOUT := "scout"
const KIND_DRILLER := "driller"
const KIND_HARRIER := "harrier"
const KIND_SHIELD := "shield_drone"
const KIND_BURROWER := "burrower"

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
var max_health := 2
var targets_drill_site := false
var attack_range := 0.0
var attack_interval := 1.45
var attack_cooldown := 0.0
var projectile_speed := 360.0
var signal_boost_timer := 0.0
var signal_boost_multiplier := 1.0
var target_structure_id := ""
var default_target_position := Vector2.ZERO
var default_target_structure_id := ""
var active_barricade: Node2D
var shield_disabled_timer := 0.0
var shield_hit_flash := 0.0


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


func configure(spawn_position: Vector2, goal_position: Vector2, current_wave: int, new_enemy_kind: String = KIND_SCOUT, new_targets_drill_site: bool = false, new_target_structure_id: String = "") -> void:
	global_position = spawn_position
	target_position = goal_position
	default_target_position = goal_position
	enemy_kind = new_enemy_kind
	targets_drill_site = new_targets_drill_site
	target_structure_id = new_target_structure_id
	default_target_structure_id = new_target_structure_id
	active_barricade = null
	attack_range = 0.0
	attack_interval = 1.45
	attack_cooldown = 0.0
	projectile_speed = 360.0
	signal_boost_timer = 0.0
	signal_boost_multiplier = 1.0
	shield_disabled_timer = 0.0
	shield_hit_flash = 0.0

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
		KIND_SHIELD:
			speed = 74.0 + randf_range(0.0, 12.0 + float(current_wave) * 4.0)
			health = 3 + int(floor(float(current_wave - 1) / 3.0))
			scrap_value = 3 + int(floor(float(current_wave - 1) / 4.0))
			farmhouse_damage = 1
			drill_progress_boost = 0.0
			body_radius = 22.0
		KIND_BURROWER:
			speed = 102.0 + randf_range(0.0, 14.0 + float(current_wave) * 5.0)
			health = 2 + int(floor(float(current_wave - 1) / 3.0))
			scrap_value = 2 + int(floor(float(current_wave - 1) / 4.0))
			farmhouse_damage = 2 if current_wave >= 6 else 1
			drill_progress_boost = 0.0
			body_radius = 18.0
		_:
			speed = 88.0 + randf_range(0.0, 28.0 + float(current_wave) * 8.0)
			health = 1 + int(floor(float(current_wave - 1) / 3.0))
			scrap_value = 2 + int(floor(float(current_wave - 1) / 4.0))
			farmhouse_damage = 1
			drill_progress_boost = 0.0
			body_radius = 20.0

	max_health = health
	queue_redraw()


func _physics_process(delta: float) -> void:
	var boost_expired := false
	if signal_boost_timer > 0.0:
		signal_boost_timer = maxf(0.0, signal_boost_timer - delta)
		if signal_boost_timer <= 0.0:
			signal_boost_multiplier = 1.0
			boost_expired = true
	if shield_disabled_timer > 0.0:
		shield_disabled_timer = maxf(0.0, shield_disabled_timer - delta)
		if shield_disabled_timer <= 0.0:
			queue_redraw()
	if shield_hit_flash > 0.0:
		shield_hit_flash = maxf(0.0, shield_hit_flash - delta)
		if shield_hit_flash <= 0.0:
			queue_redraw()

	if stun_timer > 0.0:
		stun_timer = maxf(0.0, stun_timer - delta)
		velocity = Vector2.ZERO
		move_and_slide()
		if not was_stunned or stun_timer <= 0.0 or boost_expired:
			was_stunned = stun_timer > 0.0
			queue_redraw()
		return

	if enemy_kind != KIND_HARRIER and enemy_kind != KIND_BURROWER and not targets_drill_site:
		_update_barricade_target()

	var offset := target_position - global_position
	if enemy_kind == KIND_HARRIER and not targets_drill_site:
		attack_cooldown = maxf(0.0, attack_cooldown - delta * signal_boost_multiplier)
		if global_position.y < 120.0:
			global_position.y = lerpf(global_position.y, 120.0, delta * 3.0)
		if offset.length() <= attack_range:
			velocity = Vector2.ZERO
			rotation = offset.angle()
			move_and_slide()
			if attack_cooldown <= 0.0:
				attack_cooldown = attack_interval
				var muzzle_position := global_position + offset.normalized() * (body_radius + 8.0)
				ranged_attack.emit(muzzle_position, target_position, farmhouse_damage, projectile_speed, target_structure_id)
			if was_stunned:
				was_stunned = false
				queue_redraw()
			return

	var contact_distance: float = 36.0 if enemy_kind == KIND_DRILLER else 30.0
	if enemy_kind == KIND_BURROWER:
		contact_distance = 24.0
	if offset.length() <= contact_distance:
		if targets_drill_site:
			drill_site_reached.emit(drill_progress_boost)
		elif active_barricade != null and is_instance_valid(active_barricade):
			active_barricade.take_damage(farmhouse_damage)
			if active_barricade.has_method("get_contact_damage"):
				var barb_damage: int = active_barricade.get_contact_damage()
				if barb_damage > 0:
					health -= barb_damage
					if health <= 0:
						destroyed.emit(scrap_value, global_position)
						queue_free()
						return
		elif target_structure_id != "":
			structure_hit.emit(target_structure_id, farmhouse_damage)
		else:
			farmhouse_hit.emit(farmhouse_damage)
		queue_free()
		return

	var direction := offset.normalized()
	rotation = direction.angle()
	velocity = direction * speed * signal_boost_multiplier
	move_and_slide()
	if was_stunned or boost_expired:
		was_stunned = false
		queue_redraw()


func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		destroyed.emit(scrap_value, global_position)
		queue_free()
	else:
		damaged.emit(global_position, enemy_kind)
		queue_redraw()


func take_projectile_damage(amount: int, attack_from_direction: Vector2) -> void:
	if enemy_kind == KIND_SHIELD and _shield_blocks_attack(attack_from_direction):
		shield_hit_flash = 0.16
		queue_redraw()
		return
	take_damage(amount)


func apply_stun(duration: float) -> void:
	stun_timer = maxf(stun_timer, duration)
	if not was_stunned:
		was_stunned = true
		queue_redraw()


func apply_emp(duration: float) -> void:
	if enemy_kind != KIND_SHIELD:
		return
	shield_disabled_timer = maxf(shield_disabled_timer, duration)
	shield_hit_flash = maxf(shield_hit_flash, 0.12)
	queue_redraw()


func apply_signal_boost(duration: float, multiplier: float) -> void:
	signal_boost_timer = maxf(signal_boost_timer, duration)
	signal_boost_multiplier = maxf(signal_boost_multiplier, multiplier)
	queue_redraw()


func _shield_blocks_attack(attack_from_direction: Vector2) -> bool:
	if shield_disabled_timer > 0.0:
		return false
	if attack_from_direction.length_squared() <= 0.001:
		return false

	var forward := Vector2.RIGHT.rotated(rotation)
	return forward.dot(attack_from_direction.normalized()) > 0.35


func _update_barricade_target() -> void:
	target_position = default_target_position
	target_structure_id = default_target_structure_id
	active_barricade = null

	var best_barricade: Node2D
	var best_distance_sq := 170.0 * 170.0
	for node in get_tree().get_nodes_in_group("barricades"):
		if node is Node2D:
			var barricade: Node2D = node
			if barricade.has_method("is_destroyed") and barricade.is_destroyed():
				continue
			if barricade.global_position.distance_to(default_target_position) > 160.0:
				continue
			var distance_sq: float = global_position.distance_squared_to(barricade.global_position)
			if distance_sq < best_distance_sq:
				best_distance_sq = distance_sq
				best_barricade = barricade

	if best_barricade != null:
		active_barricade = best_barricade
		target_position = best_barricade.global_position
		target_structure_id = ""


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
			draw_colored_polygon(PackedVector2Array([
				Vector2(0.0, -(body_radius - 4.0)),
				Vector2(-6.0, -(body_radius + 14.0)),
				Vector2(6.0, -(body_radius + 14.0))
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
		KIND_SHIELD:
			var hull_color := Color8(118, 209, 158)
			var shield_color := Color8(116, 214, 255)
			if shield_disabled_timer > 0.0:
				hull_color = Color8(162, 196, 176)
				shield_color = Color8(122, 136, 146)
			if shield_hit_flash > 0.0:
				shield_color = Color8(210, 246, 255)
			draw_circle(Vector2.ZERO, body_radius, hull_color)
			draw_circle(Vector2(-7.0, -5.0), 4.0, Color8(28, 38, 30))
			draw_circle(Vector2(7.0, -5.0), 4.0, Color8(28, 38, 30))
			draw_circle(Vector2.ZERO, 8.0, Color8(196, 247, 203))
			draw_line(Vector2(-18.0, 8.0), Vector2(-30.0, 20.0), hull_color, 4.0, true)
			draw_line(Vector2(18.0, 8.0), Vector2(30.0, 20.0), hull_color, 4.0, true)
			if shield_disabled_timer <= 0.0:
				draw_arc(Vector2.ZERO, body_radius + 9.0, -0.95, 0.95, 18, shield_color, 5.0, true)
				draw_arc(Vector2.ZERO, body_radius + 14.0, -0.72, 0.72, 16, Color(0.76, 0.94, 1.0, 0.45), 3.0, true)
			else:
				draw_line(Vector2(14.0, -18.0), Vector2(34.0, -10.0), shield_color, 3.0, true)
				draw_line(Vector2(16.0, 18.0), Vector2(36.0, 10.0), shield_color, 3.0, true)
		KIND_BURROWER:
			draw_circle(Vector2.ZERO, body_radius, Color8(115, 86, 60))
			draw_circle(Vector2(0.0, 6.0), body_radius - 4.0, Color8(84, 58, 42))
			draw_circle(Vector2.ZERO, 8.0, Color8(171, 255, 146))
			draw_line(Vector2(-6.0, -4.0), Vector2(-18.0, -12.0), Color8(198, 184, 120), 3.0, true)
			draw_line(Vector2(6.0, -4.0), Vector2(18.0, -12.0), Color8(198, 184, 120), 3.0, true)
			draw_line(Vector2(-14.0, 10.0), Vector2(-26.0, 18.0), Color8(92, 68, 48), 4.0, true)
			draw_line(Vector2(14.0, 10.0), Vector2(26.0, 18.0), Color8(92, 68, 48), 4.0, true)
			draw_line(Vector2(-10.0, 14.0), Vector2(-22.0, 26.0), Color8(148, 120, 78, 120), 3.0, true)
			draw_line(Vector2(10.0, 14.0), Vector2(22.0, 26.0), Color8(148, 120, 78, 120), 3.0, true)
			draw_line(Vector2(0.0, 16.0), Vector2(0.0, 30.0), Color8(148, 120, 78, 80), 2.0, true)
		_:
			draw_circle(Vector2.ZERO, body_radius, Color8(129, 238, 126))
			draw_circle(Vector2(-8.0, -4.0), 5.0, Color8(33, 42, 27))
			draw_circle(Vector2(8.0, -4.0), 5.0, Color8(33, 42, 27))
			draw_circle(Vector2.ZERO, 9.0, Color8(171, 255, 146))
			draw_line(Vector2(-20.0, 8.0), Vector2(-32.0, 18.0), Color8(129, 238, 126), 4.0, true)
			draw_line(Vector2(20.0, 8.0), Vector2(32.0, 18.0), Color8(129, 238, 126), 4.0, true)
	if stun_timer > 0.0:
		var stun_pulse := (sin(Time.get_ticks_msec() * 0.012) + 1.0) * 0.5
		var stun_alpha := lerpf(0.5, 0.9, stun_pulse)
		var stun_color := Color(0.57, 0.84, 1.0, stun_alpha)
		draw_arc(Vector2.ZERO, body_radius + 6.0, -0.8, 0.8, 18, stun_color, 4.0, true)
		draw_arc(Vector2.ZERO, body_radius + 6.0, PI - 0.8, PI + 0.8, 18, stun_color, 4.0, true)
		draw_arc(Vector2.ZERO, body_radius + 12.0, -0.5, 0.5, 14, Color(stun_color.r, stun_color.g, stun_color.b, stun_alpha * 0.4), 3.0, true)
		draw_arc(Vector2.ZERO, body_radius + 12.0, PI - 0.5, PI + 0.5, 14, Color(stun_color.r, stun_color.g, stun_color.b, stun_alpha * 0.4), 3.0, true)
		# Stun stars
		for star_i in range(3):
			var star_angle := float(star_i) * TAU / 3.0 + Time.get_ticks_msec() * 0.003
			var star_pos := Vector2(cos(star_angle), sin(star_angle)) * (body_radius + 8.0)
			draw_circle(star_pos, 2.5, Color(1.0, 1.0, 0.7, stun_alpha * 0.8))
	if signal_boost_timer > 0.0:
		draw_arc(Vector2.ZERO, body_radius + 12.0, -PI, PI, 28, Color8(203, 152, 255), 3.0, true)
		draw_arc(Vector2.ZERO, body_radius + 18.0, -PI * 0.85, PI * 0.15, 24, Color8(126, 228, 255), 2.0, true)
	if health < max_health and max_health > 0:
		var bar_y := -(body_radius + 12.0)
		var bar_w := 30.0
		var bar_h := 4.0
		var bar_x := -bar_w * 0.5
		draw_rect(Rect2(Vector2(bar_x, bar_y), Vector2(bar_w, bar_h)), Color8(40, 36, 32, 180))
		var ratio := clampf(float(health) / float(max_health), 0.0, 1.0)
		var fill_color := Color8(92, 214, 92)
		if ratio <= 0.25:
			fill_color = Color8(214, 72, 62)
		elif ratio <= 0.5:
			fill_color = Color8(214, 196, 82)
		draw_rect(Rect2(Vector2(bar_x + 1.0, bar_y + 1.0), Vector2((bar_w - 2.0) * ratio, bar_h - 2.0)), fill_color)
