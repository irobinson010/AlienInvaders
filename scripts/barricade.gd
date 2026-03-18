extends Node2D

var max_health := 6
var health := 6
var hit_flash := 0.0


func _ready() -> void:
	z_index = 10
	add_to_group("barricades")
	add_to_group("farm_defenses")


func configure(new_max_health: int = 6) -> void:
	max_health = new_max_health
	health = new_max_health
	hit_flash = 0.0
	queue_redraw()


func take_damage(amount: int) -> void:
	health = maxi(0, health - amount)
	hit_flash = 0.20
	if health <= 0:
		queue_free()
		return
	queue_redraw()


func is_destroyed() -> bool:
	return health <= 0


func _physics_process(delta: float) -> void:
	if hit_flash > 0.0:
		hit_flash = maxf(0.0, hit_flash - delta)
		queue_redraw()


func _draw() -> void:
	var post_color := Color8(114, 82, 56)
	var wire_color := Color8(214, 202, 176)
	var bar_color := Color8(255, 198, 126)
	if hit_flash > 0.0:
		post_color = Color8(148, 104, 74)
		wire_color = Color8(255, 234, 192)
		bar_color = Color8(255, 226, 148)

	draw_rect(Rect2(Vector2(-34.0, -40.0), Vector2(6.0, 58.0)), post_color)
	draw_rect(Rect2(Vector2(28.0, -40.0), Vector2(6.0, 58.0)), post_color)
	draw_line(Vector2(-28.0, -22.0), Vector2(28.0, -22.0), wire_color, 3.0, true)
	draw_line(Vector2(-28.0, -6.0), Vector2(28.0, -6.0), wire_color, 3.0, true)
	draw_line(Vector2(-28.0, 10.0), Vector2(28.0, 10.0), wire_color, 3.0, true)
	for spike_x in [-18.0, -4.0, 10.0, 24.0]:
		draw_line(Vector2(spike_x, -26.0), Vector2(spike_x + 6.0, -18.0), wire_color, 2.0, true)
		draw_line(Vector2(spike_x, -10.0), Vector2(spike_x + 6.0, -2.0), wire_color, 2.0, true)
		draw_line(Vector2(spike_x, 6.0), Vector2(spike_x + 6.0, 14.0), wire_color, 2.0, true)

	var health_ratio := float(health) / float(maxi(1, max_health))
	draw_rect(Rect2(Vector2(-30.0, -56.0), Vector2(60.0, 7.0)), Color8(30, 26, 22))
	draw_rect(Rect2(Vector2(-28.0, -54.0), Vector2(56.0 * health_ratio, 3.0)), bar_color)
