extends StaticBody2D

signal destroyed(scrap_value: int, world_position: Vector2)
signal breached()
signal damaged(world_position: Vector2)

var health := 10
var max_health := 10
var scrap_value := 5
var drill_rate := 2.0
var drill_progress := 0.0
var drill_goal := 100.0
var hit_flash := 0.0


func _ready() -> void:
	z_index = 10
	collision_layer = 2
	collision_mask = 0
	add_to_group("aliens")
	add_to_group("drill_sites")

	var collision: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(72.0, 62.0)
	collision.shape = shape
	add_child(collision)


func configure(new_health: int, new_drill_rate: float, new_scrap_value: int = 5) -> void:
	health = new_health
	max_health = new_health
	drill_rate = new_drill_rate
	scrap_value = new_scrap_value
	drill_progress = 0.0
	hit_flash = 0.0
	queue_redraw()


func _physics_process(delta: float) -> void:
	if hit_flash > 0.0:
		hit_flash = maxf(0.0, hit_flash - delta)

	drill_progress = minf(drill_goal, drill_progress + drill_rate * delta)
	if drill_progress >= drill_goal:
		breached.emit()
		queue_free()
		return
	queue_redraw()


func boost_progress(amount: float) -> void:
	drill_progress = minf(drill_goal, drill_progress + amount)
	if drill_progress >= drill_goal:
		breached.emit()
		queue_free()
		return
	queue_redraw()


func repair(amount: int) -> void:
	if amount <= 0 or health <= 0:
		return
	health = mini(max_health, health + amount)
	queue_redraw()


func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		destroyed.emit(scrap_value, global_position)
		queue_free()
		return
	hit_flash = 0.18
	damaged.emit(global_position)
	queue_redraw()


func get_progress_ratio() -> float:
	return drill_progress / drill_goal


func get_health() -> int:
	return health


func get_max_health() -> int:
	return max_health


func get_health_ratio() -> float:
	if max_health <= 0:
		return 0.0
	return float(health) / float(max_health)


func _draw() -> void:
	var progress_ratio: float = get_progress_ratio()
	var health_ratio: float = get_health_ratio()
	var shell_color := Color8(108, 114, 132)
	var beam_color := Color8(255, 118, 73)
	if health <= 4:
		shell_color = Color8(148, 88, 78)
		beam_color = Color8(255, 156, 115)
	if hit_flash > 0.0:
		shell_color = Color8(208, 102, 84)
		beam_color = Color8(255, 212, 160)

	draw_rect(Rect2(Vector2(-30.0, -14.0), Vector2(60.0, 28.0)), shell_color)
	draw_rect(Rect2(Vector2(-18.0, -42.0), Vector2(36.0, 28.0)), Color8(72, 76, 92))
	draw_rect(Rect2(Vector2(-6.0, -58.0), Vector2(12.0, 86.0)), Color8(168, 174, 186))
	draw_circle(Vector2(0.0, 34.0), 18.0, Color8(88, 68, 56))
	draw_line(Vector2(0.0, 28.0), Vector2(0.0, 58.0), Color8(62, 46, 39), 8.0, true)
	draw_line(Vector2(-16.0, -14.0), Vector2(-28.0, -34.0), shell_color, 6.0, true)
	draw_line(Vector2(16.0, -14.0), Vector2(28.0, -34.0), shell_color, 6.0, true)
	draw_rect(Rect2(Vector2(-32.0, -74.0), Vector2(64.0, 8.0)), Color8(49, 43, 39))
	draw_rect(Rect2(Vector2(-30.0, -72.0), Vector2(60.0 * progress_ratio, 4.0)), beam_color)
	draw_rect(Rect2(Vector2(-32.0, -92.0), Vector2(64.0, 7.0)), Color8(38, 34, 30))
	draw_rect(Rect2(Vector2(-30.0, -90.0), Vector2(60.0 * health_ratio, 3.0)), Color8(246, 120, 88))
	draw_line(Vector2(0.0, -58.0), Vector2(0.0, -118.0), beam_color, 4.0, true)
	draw_circle(Vector2(0.0, -120.0), 10.0 + progress_ratio * 8.0, Color(1.0, 0.62, 0.34, 0.35))
	if health < max_health and max_health > 0:
		var bar_y := -52.0
		var bar_w := 40.0
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
