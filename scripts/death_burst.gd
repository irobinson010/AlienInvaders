extends Node2D

const BURST_DURATION := 0.46

var burst_time := 0.0
var burst_scale := 1.0
var burst_style := 0
var core_color := Color8(255, 226, 176)
var spark_color := Color8(122, 255, 192)
var ember_color := Color8(255, 164, 108)
var fragments: Array[Dictionary] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 28
	if fragments.is_empty():
		_rebuild_fragments()
	queue_redraw()


func configure(new_core_color: Color, new_spark_color: Color, new_scale: float = 1.0, new_burst_style: int = 0) -> void:
	core_color = new_core_color
	spark_color = new_spark_color
	burst_scale = maxf(0.6, new_scale)
	burst_style = new_burst_style
	ember_color = core_color.lerp(spark_color, 0.38)
	_rebuild_fragments()
	queue_redraw()


func _process(delta: float) -> void:
	burst_time += delta
	if burst_time >= BURST_DURATION:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var progress := clampf(burst_time / BURST_DURATION, 0.0, 1.0)
	var flash_alpha := 1.0 - progress
	var outer_radius := lerpf(10.0, 48.0, progress) * burst_scale
	var inner_radius := lerpf(5.0, 19.0, progress) * burst_scale
	var shock_radius := lerpf(8.0, 38.0, progress) * burst_scale

	draw_circle(Vector2.ZERO, outer_radius, Color(core_color.r, core_color.g, core_color.b, 0.28 * flash_alpha))
	draw_circle(Vector2.ZERO, inner_radius, Color(1.0, 0.96, 0.82, 0.72 * flash_alpha))
	draw_arc(Vector2.ZERO, shock_radius, -PI, PI, 32, Color(spark_color.r, spark_color.g, spark_color.b, 0.42 * flash_alpha), maxf(1.0, 4.0 * (1.0 - progress) * burst_scale), true)

	for fragment in fragments:
		var direction := Vector2.RIGHT.rotated(float(fragment["angle"]))
		var distance := lerpf(float(fragment["start_distance"]), float(fragment["end_distance"]), progress)
		var fragment_length: float = float(fragment["length"]) * (1.0 - progress * 0.45)
		var start: Vector2 = direction * distance
		var end: Vector2 = direction * (distance + fragment_length)
		var width := maxf(1.0, float(fragment["width"]) * (1.0 - progress * 0.6))
		var spark_alpha: float = float(fragment["alpha"]) * flash_alpha
		var spark := Color(spark_color.r, spark_color.g, spark_color.b, spark_alpha)
		var ember := Color(ember_color.r, ember_color.g, ember_color.b, spark_alpha * 0.92)
		draw_line(start, end, spark, width, true)
		draw_circle(end, maxf(1.1, float(fragment["radius"]) * (1.0 - progress * 0.55)), ember)

	if burst_style == 1:  # Driller: ground slam ripple
		var ripple_alpha := clampf(1.0 - progress, 0.0, 0.6)
		draw_arc(Vector2.ZERO, 20.0 * burst_scale * progress, -PI, PI, 24, Color(0.8, 0.4, 0.2, ripple_alpha), 3.0 * burst_scale, true)
	elif burst_style == 2:  # Harrier: scatter fragments
		for i in range(4):
			var frag_angle := float(i) * TAU / 4.0 + progress * 1.5
			var frag_pos := Vector2(cos(frag_angle), sin(frag_angle)) * 16.0 * burst_scale * progress
			var frag_alpha := clampf(1.0 - progress, 0.0, 0.8)
			draw_rect(Rect2(frag_pos - Vector2(3.0, 2.0) * burst_scale, Vector2(6.0, 4.0) * burst_scale), Color(0.5, 0.65, 0.9, frag_alpha))
	elif burst_style == 3:  # Shield: EMP ring
		var ring_alpha := clampf(1.0 - progress * 0.8, 0.0, 0.7)
		draw_arc(Vector2.ZERO, 28.0 * burst_scale * progress, -PI, PI, 32, Color(0.45, 0.85, 1.0, ring_alpha), 4.0 * burst_scale, true)
	elif burst_style == 4:  # Burrower: dirt spray
		for i in range(5):
			var dirt_angle := float(i) * TAU / 5.0 + progress * 0.8
			var dirt_pos := Vector2(cos(dirt_angle), sin(dirt_angle)) * 12.0 * burst_scale * progress
			var dirt_alpha := clampf(1.0 - progress, 0.0, 0.6)
			draw_circle(dirt_pos, 4.0 * burst_scale * (1.0 - progress * 0.5), Color(0.58, 0.47, 0.3, dirt_alpha))


func _rebuild_fragments() -> void:
	fragments.clear()
	var fragment_count := 8 + int(round(burst_scale * 4.0))
	for _fragment_index in range(fragment_count):
		fragments.append({
			"angle": randf_range(-PI, PI),
			"start_distance": randf_range(2.0, 9.0) * burst_scale,
			"end_distance": randf_range(20.0, 58.0) * burst_scale,
			"length": randf_range(7.0, 18.0) * burst_scale,
			"width": randf_range(1.8, 4.4) * burst_scale,
			"radius": randf_range(1.8, 4.8) * burst_scale,
			"alpha": randf_range(0.48, 0.92),
		})
