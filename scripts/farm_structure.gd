extends Node2D

signal damaged(structure_id: String, world_position: Vector2)
signal destroyed(structure_id: String, world_position: Vector2)

const TYPE_BARN := "barn"
const TYPE_POWER_SHED := "power_shed"
const TYPE_SILO := "silo"

var structure_id := ""
var display_name := ""
var structure_type := TYPE_BARN
var max_health := 8
var health := 8
var hit_flash := 0.0
var destroyed_state := false


func _ready() -> void:
	z_index = 9


func configure(new_structure_id: String, new_display_name: String, new_structure_type: String, new_max_health: int) -> void:
	structure_id = new_structure_id
	display_name = new_display_name
	structure_type = new_structure_type
	max_health = new_max_health
	health = new_max_health
	hit_flash = 0.0
	destroyed_state = false
	queue_redraw()


func _physics_process(delta: float) -> void:
	if hit_flash > 0.0:
		hit_flash = maxf(0.0, hit_flash - delta)
		queue_redraw()
	elif not destroyed_state and get_health_ratio() < 0.25:
		queue_redraw()


func take_damage(amount: int) -> void:
	if destroyed_state:
		return

	health = maxi(0, health - amount)
	hit_flash = 0.20
	if health <= 0:
		destroyed_state = true
		destroyed.emit(structure_id, global_position)
	else:
		damaged.emit(structure_id, global_position)
	queue_redraw()


func is_destroyed() -> bool:
	return destroyed_state


func get_health() -> int:
	return health


func get_max_health() -> int:
	return max_health


func get_health_ratio() -> float:
	if max_health <= 0:
		return 0.0
	return float(health) / float(max_health)


func restore_full() -> void:
	destroyed_state = false
	health = max_health
	hit_flash = 0.0
	queue_redraw()


func _draw() -> void:
	match structure_type:
		TYPE_POWER_SHED:
			_draw_power_shed()
		TYPE_SILO:
			_draw_silo()
		_:
			_draw_barn()

	_draw_damage_overlay()
	_draw_health_bar()


func _draw_damage_overlay() -> void:
	var health_ratio := get_health_ratio()
	if destroyed_state or health_ratio >= 1.0:
		return

	# Determine overlay radius based on structure type
	var overlay_radius := 40.0
	match structure_type:
		TYPE_POWER_SHED:
			overlay_radius = 36.0
		TYPE_SILO:
			overlay_radius = 30.0
		_:
			overlay_radius = 44.0

	# Cracks appear below 75% health
	if health_ratio < 0.75:
		var crack_color := Color8(62, 48, 38, 160)
		draw_line(Vector2(-8.0, -12.0), Vector2(4.0, 6.0), crack_color, 2.0, true)
		draw_line(Vector2(6.0, -8.0), Vector2(-2.0, 10.0), crack_color, 2.0, true)

	# More cracks and darkening below 50%
	if health_ratio < 0.5:
		var dark_overlay := Color(0.0, 0.0, 0.0, 0.15)
		draw_circle(Vector2.ZERO, overlay_radius, dark_overlay)
		draw_line(Vector2(-14.0, -4.0), Vector2(8.0, 14.0), Color8(52, 38, 28, 180), 2.5, true)
		draw_line(Vector2(10.0, -14.0), Vector2(-6.0, 4.0), Color8(52, 38, 28, 180), 2.0, true)

	# Critical state below 25% - red tint and sparks
	if health_ratio < 0.25:
		var pulse := (sin(Time.get_ticks_msec() * 0.005) + 1.0) * 0.5
		var critical_color := Color(0.9, 0.2, 0.1, lerpf(0.08, 0.2, pulse))
		draw_circle(Vector2.ZERO, overlay_radius + 2.0, critical_color)


func _draw_health_bar() -> void:
	var bar_width := 70.0
	var bar_origin := Vector2(-bar_width * 0.5, -86.0)
	draw_rect(Rect2(bar_origin, Vector2(bar_width, 8.0)), Color8(28, 24, 20))
	var fill_color := Color8(139, 216, 126)
	if destroyed_state:
		fill_color = Color8(152, 74, 64)
	elif hit_flash > 0.0:
		fill_color = Color8(255, 208, 122)
	draw_rect(Rect2(bar_origin + Vector2(2.0, 2.0), Vector2((bar_width - 4.0) * get_health_ratio(), 4.0)), fill_color)


func _draw_barn() -> void:
	var wall_color := Color8(164, 84, 61)
	var roof_color := Color8(95, 44, 37)
	var trim_color := Color8(242, 232, 214)
	if destroyed_state:
		wall_color = Color8(86, 70, 64)
		roof_color = Color8(52, 42, 40)
		trim_color = Color8(120, 112, 106)
	elif hit_flash > 0.0:
		wall_color = Color8(216, 124, 86)
		roof_color = Color8(136, 63, 50)

	draw_rect(Rect2(Vector2(-54.0, -22.0), Vector2(108.0, 62.0)), wall_color)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-66.0, -22.0),
		Vector2(0.0, -66.0),
		Vector2(66.0, -22.0)
	]), roof_color)
	draw_rect(Rect2(Vector2(-12.0, -4.0), Vector2(24.0, 44.0)), trim_color)
	draw_rect(Rect2(Vector2(-40.0, -2.0), Vector2(18.0, 18.0)), trim_color)
	draw_rect(Rect2(Vector2(22.0, -2.0), Vector2(18.0, 18.0)), trim_color)
	if destroyed_state:
		draw_line(Vector2(-20.0, -8.0), Vector2(22.0, 22.0), Color8(52, 44, 40), 5.0, true)
		draw_line(Vector2(20.0, -8.0), Vector2(-22.0, 24.0), Color8(52, 44, 40), 5.0, true)


func _draw_power_shed() -> void:
	var wall_color := Color8(78, 104, 138)
	var roof_color := Color8(42, 56, 76)
	var arc_color := Color8(145, 226, 255)
	if destroyed_state:
		wall_color = Color8(74, 72, 80)
		roof_color = Color8(40, 38, 46)
		arc_color = Color8(118, 112, 124)
	elif hit_flash > 0.0:
		wall_color = Color8(124, 152, 188)
		arc_color = Color8(214, 247, 255)

	draw_rect(Rect2(Vector2(-42.0, -16.0), Vector2(84.0, 54.0)), wall_color)
	draw_rect(Rect2(Vector2(-48.0, -24.0), Vector2(96.0, 12.0)), roof_color)
	draw_rect(Rect2(Vector2(-26.0, -4.0), Vector2(16.0, 18.0)), Color8(30, 40, 56))
	draw_rect(Rect2(Vector2(10.0, -4.0), Vector2(16.0, 18.0)), Color8(30, 40, 56))
	draw_circle(Vector2(0.0, 10.0), 12.0, arc_color)
	draw_arc(Vector2(0.0, 10.0), 20.0, -0.8, 0.8, 20, arc_color, 3.0, true)
	draw_arc(Vector2(0.0, 10.0), 28.0, 2.34, 3.94, 20, arc_color, 3.0, true)
	if destroyed_state:
		draw_line(Vector2(-34.0, -12.0), Vector2(30.0, 26.0), Color8(38, 34, 36), 5.0, true)


func _draw_silo() -> void:
	var body_color := Color8(166, 176, 188)
	var roof_color := Color8(118, 88, 70)
	var stripe_color := Color8(240, 186, 104)
	if destroyed_state:
		body_color = Color8(94, 96, 104)
		roof_color = Color8(62, 54, 52)
		stripe_color = Color8(138, 118, 104)
	elif hit_flash > 0.0:
		body_color = Color8(214, 202, 182)
		stripe_color = Color8(255, 218, 148)

	draw_circle(Vector2(0.0, -36.0), 26.0, roof_color)
	draw_rect(Rect2(Vector2(-26.0, -36.0), Vector2(52.0, 92.0)), body_color)
	draw_circle(Vector2(0.0, 56.0), 26.0, body_color)
	draw_rect(Rect2(Vector2(-22.0, -4.0), Vector2(44.0, 8.0)), stripe_color)
	draw_rect(Rect2(Vector2(-8.0, -48.0), Vector2(16.0, 22.0)), Color8(82, 70, 66))
	if destroyed_state:
		draw_line(Vector2(-22.0, -12.0), Vector2(22.0, 20.0), Color8(50, 46, 48), 5.0, true)
