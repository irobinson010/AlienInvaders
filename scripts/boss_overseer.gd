extends CharacterBody2D

signal destroyed(scrap_value: int, world_position: Vector2)
signal damaged(world_position: Vector2)
signal attack_volley(display_name: String, origin: Vector2, shot_count: int, damage: int, projectile_speed: float)
signal command_pulse(display_name: String, world_position: Vector2, boost_multiplier: float, boost_duration: float, drill_boost: float)
signal phase_changed(display_name: String, world_position: Vector2)

var display_name := "Overseer"
var health := 30
var max_health := 30
var scrap_value := 16
var patrol_min_x := 360.0
var patrol_max_x := 920.0
var hover_base_y := 196.0
var patrol_speed := 104.0
var patrol_direction := 1.0
var attack_interval := 2.25
var attack_timer := 1.30
var projectile_speed := 430.0
var projectile_damage := 1
var volley_count := 2
var pulse_interval := 6.20
var pulse_timer := 4.40
var frenzy_multiplier := 1.20
var frenzy_duration := 3.80
var drill_boost := 4.5
var stun_timer := 0.0
var hit_flash := 0.0
var pulse_flash := 0.0
var hover_time := 0.0
var phase_two := false


func _ready() -> void:
	z_index = 20
	collision_layer = 2
	collision_mask = 0
	add_to_group("aliens")
	add_to_group("bosses")

	var collision: CollisionShape2D = CollisionShape2D.new()
	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = 34.0
	collision.shape = shape
	add_child(collision)


func configure(config: Dictionary) -> void:
	display_name = String(config.get("name", "Overseer"))
	health = int(config.get("health", 30))
	max_health = health
	scrap_value = int(config.get("scrap", 16))
	patrol_min_x = float(config.get("patrol_min_x", 360.0))
	patrol_max_x = float(config.get("patrol_max_x", 920.0))
	hover_base_y = float(config.get("hover_base_y", 196.0))
	patrol_speed = float(config.get("patrol_speed", 104.0))
	attack_interval = float(config.get("attack_interval", 2.25))
	attack_timer = float(config.get("attack_start", attack_interval * 0.72))
	projectile_speed = float(config.get("projectile_speed", 430.0))
	projectile_damage = int(config.get("projectile_damage", 1))
	volley_count = int(config.get("volley_count", 2))
	pulse_interval = float(config.get("pulse_interval", 6.20))
	pulse_timer = float(config.get("pulse_start", pulse_interval * 0.70))
	frenzy_multiplier = float(config.get("boost_multiplier", 1.20))
	frenzy_duration = float(config.get("boost_duration", 3.80))
	drill_boost = float(config.get("drill_boost", 4.5))
	patrol_direction = -1.0 if randi() % 2 == 0 else 1.0
	global_position = Vector2(global_position.x, hover_base_y)
	stun_timer = 0.0
	hit_flash = 0.0
	pulse_flash = 0.0
	hover_time = randf_range(0.0, PI * 2.0)
	phase_two = false
	queue_redraw()


func _physics_process(delta: float) -> void:
	hover_time += delta
	if hit_flash > 0.0:
		hit_flash = maxf(0.0, hit_flash - delta)
		queue_redraw()
	if pulse_flash > 0.0:
		pulse_flash = maxf(0.0, pulse_flash - delta)
		queue_redraw()

	var desired_y := maxf(120.0, hover_base_y + sin(hover_time * 2.1) * 14.0)

	if stun_timer > 0.0:
		stun_timer = maxf(0.0, stun_timer - delta)
	else:
		attack_timer -= delta
		pulse_timer -= delta
		if attack_timer <= 0.0:
			attack_timer = attack_interval
			attack_volley.emit(display_name, global_position + Vector2(0.0, 28.0), volley_count + int(phase_two), projectile_damage, projectile_speed)
		if pulse_timer <= 0.0:
			pulse_timer = pulse_interval
			pulse_flash = 0.22
			command_pulse.emit(display_name, global_position, frenzy_multiplier, frenzy_duration, drill_boost)
			queue_redraw()

		var next_x := global_position.x + patrol_direction * patrol_speed * delta
		if next_x <= patrol_min_x:
			next_x = patrol_min_x
			patrol_direction = 1.0
		elif next_x >= patrol_max_x:
			next_x = patrol_max_x
			patrol_direction = -1.0
		global_position.x = next_x

	global_position.y = desired_y


func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		destroyed.emit(scrap_value, global_position)
		queue_free()
		return

	hit_flash = 0.16
	damaged.emit(global_position)
	if not phase_two and health <= int(ceil(float(max_health) * 0.5)):
		phase_two = true
		patrol_speed += 18.0
		attack_interval = maxf(1.45, attack_interval - 0.45)
		pulse_interval = maxf(4.80, pulse_interval - 0.70)
		phase_changed.emit(display_name, global_position)
	queue_redraw()


func take_projectile_damage(amount: int, _attack_from_direction: Vector2) -> void:
	take_damage(amount)


func apply_stun(duration: float) -> void:
	stun_timer = maxf(stun_timer, duration * 0.35)
	queue_redraw()


func apply_emp(duration: float) -> void:
	stun_timer = maxf(stun_timer, duration * 0.18)
	hit_flash = maxf(hit_flash, 0.12)
	queue_redraw()


func get_health() -> int:
	return health


func get_max_health() -> int:
	return max_health


func get_display_name() -> String:
	return display_name


func _draw() -> void:
	var hull_color := Color8(82, 94, 128)
	var trim_color := Color8(182, 204, 244)
	var core_color := Color8(255, 186, 124)
	if phase_two:
		hull_color = Color8(108, 78, 124)
		trim_color = Color8(228, 214, 255)
		core_color = Color8(255, 120, 102)
	if hit_flash > 0.0:
		hull_color = hull_color.lightened(0.20)
		trim_color = trim_color.lightened(0.12)
		core_color = core_color.lightened(0.14)
	elif pulse_flash > 0.0:
		hull_color = hull_color.lightened(0.10)
		trim_color = trim_color.lightened(0.06)

	draw_polygon(PackedVector2Array([
		Vector2(-58.0, -6.0),
		Vector2(-42.0, -24.0),
		Vector2(0.0, -30.0),
		Vector2(42.0, -24.0),
		Vector2(58.0, -6.0),
		Vector2(48.0, 16.0),
		Vector2(18.0, 28.0),
		Vector2(-18.0, 28.0),
		Vector2(-48.0, 16.0),
	]), PackedColorArray([hull_color]))
	draw_circle(Vector2.ZERO, 22.0, Color8(34, 40, 56))
	draw_circle(Vector2.ZERO, 12.0, core_color)
	draw_rect(Rect2(Vector2(-18.0, -46.0), Vector2(36.0, 20.0)), hull_color)
	draw_circle(Vector2(0.0, -50.0), 10.0, trim_color)
	draw_circle(Vector2(-26.0, -6.0), 8.0, trim_color)
	draw_circle(Vector2(26.0, -6.0), 8.0, trim_color)
	draw_line(Vector2(-42.0, 6.0), Vector2(-74.0, 22.0), hull_color, 6.0, true)
	draw_line(Vector2(42.0, 6.0), Vector2(74.0, 22.0), hull_color, 6.0, true)
	draw_line(Vector2(-14.0, 20.0), Vector2(-24.0, 42.0), trim_color, 5.0, true)
	draw_line(Vector2(14.0, 20.0), Vector2(24.0, 42.0), trim_color, 5.0, true)
	draw_arc(Vector2.ZERO, 40.0, -0.3, PI + 0.3, 28, Color(trim_color.r, trim_color.g, trim_color.b, 0.48), 3.0, true)
	if health < max_health and max_health > 0:
		var bar_y := -48.0
		var bar_w := 50.0
		var bar_h := 5.0
		var bar_x := -bar_w * 0.5
		draw_rect(Rect2(Vector2(bar_x, bar_y), Vector2(bar_w, bar_h)), Color8(40, 36, 32, 180))
		var ratio := clampf(float(health) / float(max_health), 0.0, 1.0)
		var fill_color := Color8(92, 214, 92)
		if ratio <= 0.25:
			fill_color = Color8(214, 72, 62)
		elif ratio <= 0.5:
			fill_color = Color8(214, 196, 82)
		draw_rect(Rect2(Vector2(bar_x + 1.0, bar_y + 1.0), Vector2((bar_w - 2.0) * ratio, bar_h - 2.0)), fill_color)
