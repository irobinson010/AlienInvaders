extends Node2D

signal discharged(origin: Vector2)

var range := 168.0
var fire_interval := 1.25
var cooldown := 0.25
var damage := 1
var stun_duration := 0.55
var pulse_flash := 0.0


func _ready() -> void:
	z_index = 11
	add_to_group("shock_posts")
	add_to_group("farm_defenses")


func configure(new_fire_interval: float = 1.25, new_damage: int = 1, new_stun_duration: float = 0.55) -> void:
	fire_interval = new_fire_interval
	damage = new_damage
	stun_duration = new_stun_duration


func set_stats(new_fire_interval: float, new_damage: int, new_stun_duration: float) -> void:
	fire_interval = new_fire_interval
	damage = new_damage
	stun_duration = new_stun_duration


func _physics_process(delta: float) -> void:
	cooldown = maxf(0.0, cooldown - delta)
	if pulse_flash > 0.0:
		pulse_flash = maxf(0.0, pulse_flash - delta)
		queue_redraw()

	var target: Node2D = _find_target()
	if target == null:
		return

	var aim: Vector2 = target.global_position - global_position
	rotation = aim.angle()
	if cooldown > 0.0:
		return

	cooldown = fire_interval
	pulse_flash = 0.18
	if target.has_method("apply_stun"):
		target.apply_stun(stun_duration)
	if target.has_method("take_damage"):
		target.take_damage(damage)
	discharged.emit(global_position)
	queue_redraw()


func _find_target() -> Node2D:
	var best_target: Node2D
	var best_distance_sq: float = range * range

	for node in get_tree().get_nodes_in_group("aliens"):
		if node is Node2D:
			var alien: Node2D = node
			var distance_sq: float = global_position.distance_squared_to(alien.global_position)
			if distance_sq < best_distance_sq:
				best_distance_sq = distance_sq
				best_target = alien

	return best_target


func _draw() -> void:
	var coil_color := Color8(92, 144, 181)
	var arc_color := Color8(136, 225, 255)
	if pulse_flash > 0.0:
		coil_color = Color8(158, 214, 238)
		arc_color = Color8(214, 247, 255)

	draw_circle(Vector2.ZERO, 16.0, Color8(68, 60, 54))
	draw_rect(Rect2(Vector2(-6.0, -28.0), Vector2(12.0, 34.0)), coil_color)
	draw_circle(Vector2.ZERO, 8.0, Color8(230, 206, 128))
	draw_line(Vector2(-12.0, -18.0), Vector2(-26.0, -30.0), coil_color, 4.0, true)
	draw_line(Vector2(12.0, -18.0), Vector2(26.0, -30.0), coil_color, 4.0, true)
	if pulse_flash > 0.0:
		draw_arc(Vector2.ZERO, 28.0, -0.7, 0.7, 18, arc_color, 3.0, true)
		draw_arc(Vector2.ZERO, 34.0, 2.34, 3.94, 18, arc_color, 3.0, true)
