extends StaticBody2D

signal destroyed(scrap_value: int, world_position: Vector2)
signal pulsed(boost_multiplier: float, boost_duration: float, drill_boost: float)
signal damaged(world_position: Vector2)

var health := 8
var max_health := 8
var scrap_value := 5
var pulse_interval := 5.2
var pulse_timer := 3.8
var boost_multiplier := 1.35
var boost_duration := 3.4
var drill_boost := 5.0
var pulse_flash := 0.0
var hit_flash := 0.0


func _ready() -> void:
	z_index = 11
	collision_layer = 2
	collision_mask = 0
	add_to_group("aliens")
	add_to_group("relay_nodes")

	var collision: CollisionShape2D = CollisionShape2D.new()
	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = 26.0
	collision.shape = shape
	add_child(collision)


func configure(new_health: int, new_pulse_interval: float, new_boost_multiplier: float, new_boost_duration: float, new_drill_boost: float, new_scrap_value: int = 5) -> void:
	health = new_health
	max_health = new_health
	pulse_interval = new_pulse_interval
	boost_multiplier = new_boost_multiplier
	boost_duration = new_boost_duration
	drill_boost = new_drill_boost
	scrap_value = new_scrap_value
	pulse_timer = maxf(1.6, pulse_interval * 0.72)
	pulse_flash = 0.0
	hit_flash = 0.0
	queue_redraw()


func _physics_process(delta: float) -> void:
	pulse_timer -= delta
	if pulse_flash > 0.0:
		pulse_flash = maxf(0.0, pulse_flash - delta)
		queue_redraw()
	if hit_flash > 0.0:
		hit_flash = maxf(0.0, hit_flash - delta)
		queue_redraw()

	if pulse_timer <= 0.0:
		pulse_timer = pulse_interval
		pulse_flash = 0.24
		pulsed.emit(boost_multiplier, boost_duration, drill_boost)
		queue_redraw()


func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		destroyed.emit(scrap_value, global_position)
		queue_free()
		return
	hit_flash = 0.16
	damaged.emit(global_position)
	queue_redraw()


func repair(amount: int) -> void:
	if amount <= 0 or health <= 0:
		return
	health = mini(max_health, health + amount)
	queue_redraw()


func get_health() -> int:
	return health


func get_max_health() -> int:
	return max_health


func _draw() -> void:
	var shell_color := Color8(112, 82, 160)
	var core_color := Color8(132, 225, 255)
	var beam_color := Color8(246, 180, 106)
	if pulse_flash > 0.0:
		shell_color = Color8(148, 114, 206)
		core_color = Color8(188, 240, 255)
		beam_color = Color8(255, 220, 150)
	elif hit_flash > 0.0:
		shell_color = Color8(188, 124, 214)
		core_color = Color8(234, 248, 255)
		beam_color = Color8(255, 208, 132)

	draw_circle(Vector2.ZERO, 24.0, shell_color)
	draw_circle(Vector2.ZERO, 12.0, core_color)
	draw_rect(Rect2(Vector2(-6.0, -46.0), Vector2(12.0, 26.0)), shell_color)
	draw_circle(Vector2(0.0, -52.0), 10.0, beam_color)
	draw_line(Vector2(-18.0, 12.0), Vector2(-34.0, 28.0), shell_color, 5.0, true)
	draw_line(Vector2(18.0, 12.0), Vector2(34.0, 28.0), shell_color, 5.0, true)
	draw_line(Vector2(0.0, -14.0), Vector2(0.0, -44.0), beam_color, 4.0, true)
	draw_rect(Rect2(Vector2(-28.0, -74.0), Vector2(56.0, 7.0)), Color8(32, 28, 44))
	draw_rect(Rect2(Vector2(-26.0, -72.0), Vector2(52.0 * (float(health) / float(maxi(1, max_health))), 3.0)), Color8(132, 225, 255))
	if pulse_flash > 0.0:
		draw_arc(Vector2.ZERO, 38.0, -PI, PI, 32, Color(0.76, 0.86, 1.0, 0.55), 3.0, true)
	if health < max_health and max_health > 0:
		var bar_y := -46.0
		var bar_w := 36.0
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
