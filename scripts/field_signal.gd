extends Node2D

var signal_stage := 0
var highlight_active := false
var pulse_time := 0.0


func _ready() -> void:
	z_index = 3
	visible = false


func set_signal_state(new_signal_stage: int, new_highlight_active: bool) -> void:
	signal_stage = maxi(0, new_signal_stage)
	highlight_active = new_highlight_active
	visible = signal_stage > 0
	queue_redraw()


func _process(delta: float) -> void:
	if signal_stage <= 0:
		return

	pulse_time += delta * (1.0 + float(signal_stage) * 0.08)
	queue_redraw()


func _draw() -> void:
	if signal_stage <= 0:
		return

	var pulse := 0.5 + 0.5 * sin(pulse_time * TAU)
	var base_color := Color8(95, 188, 230, int(60 + signal_stage * 18))
	var glow_color := Color8(255, 170, 98, int(44 + signal_stage * 14))
	if highlight_active:
		base_color = Color8(142, 222, 255, int(84 + signal_stage * 20))
		glow_color = Color8(255, 198, 124, int(68 + signal_stage * 18))

	var outer_radius := 42.0 + float(signal_stage) * 10.0 + pulse * 10.0
	var middle_radius := 26.0 + float(signal_stage) * 7.0 - pulse * 2.0
	var inner_radius := 12.0 + float(signal_stage) * 3.0 + pulse * 3.0

	draw_arc(Vector2.ZERO, outer_radius, -PI, PI, 48, base_color, 4.0, true)
	draw_arc(Vector2.ZERO, middle_radius, -PI, PI, 40, glow_color, 3.0, true)
	draw_arc(Vector2.ZERO, inner_radius, -PI, PI, 32, Color8(244, 235, 202, int(72 + pulse * 36.0)), 2.0, true)

	draw_line(Vector2(-outer_radius * 0.7, 0.0), Vector2(outer_radius * 0.7, 0.0), base_color, 2.0, true)
	draw_line(Vector2(0.0, -middle_radius * 0.6), Vector2(0.0, middle_radius * 0.6), glow_color, 2.0, true)
	draw_circle(Vector2.ZERO, 6.0 + pulse * 3.0, Color(1.0, 0.77, 0.48, 0.24 + pulse * 0.10))
