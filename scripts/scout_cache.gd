extends Node2D

signal revealed(world_position: Vector2)
signal discovered(reward_type: String, reward_value: int, world_position: Vector2)

enum State { HIDDEN, REVEALED, DISCOVERED }

var state := State.HIDDEN
var reward_type := "scrap"
var reward_value := 2
var anim_time := 0.0
var fade_timer := 0.0


func _ready() -> void:
	z_index = 5
	add_to_group("scout_caches")


func configure(new_reward_type: String, new_reward_value: int) -> void:
	reward_type = new_reward_type
	reward_value = new_reward_value


func is_hidden() -> bool:
	return state == State.HIDDEN


func is_revealed() -> bool:
	return state == State.REVEALED


func reveal() -> void:
	if state != State.HIDDEN:
		return
	state = State.REVEALED
	revealed.emit(global_position)
	queue_redraw()


func claim() -> void:
	if state != State.REVEALED:
		return
	state = State.DISCOVERED
	fade_timer = 0.5
	discovered.emit(reward_type, reward_value, global_position)
	queue_redraw()


func _process(delta: float) -> void:
	anim_time += delta
	if state == State.DISCOVERED:
		fade_timer = maxf(0.0, fade_timer - delta)
		if fade_timer <= 0.0:
			queue_free()
			return
	queue_redraw()


func _draw() -> void:
	var scout_blue := Color8(107, 192, 226)
	match state:
		State.HIDDEN:
			var pulse := (sin(anim_time * 2.4) + 1.0) * 0.5
			var alpha := lerpf(0.06, 0.18, pulse)
			var ring_color := Color(scout_blue.r, scout_blue.g, scout_blue.b, alpha)
			draw_arc(Vector2.ZERO, 12.0, -PI, PI, 24, ring_color, 2.0, true)
			draw_arc(Vector2.ZERO, 20.0, -PI, PI, 24, Color(ring_color.r, ring_color.g, ring_color.b, alpha * 0.5), 1.5, true)
			draw_circle(Vector2.ZERO, 3.0, Color(scout_blue.r, scout_blue.g, scout_blue.b, alpha * 0.7))
		State.REVEALED:
			var pulse := (sin(anim_time * 3.6) + 1.0) * 0.5
			var alpha := lerpf(0.5, 0.9, pulse)
			var ring_color := Color(scout_blue.r, scout_blue.g, scout_blue.b, alpha)
			draw_circle(Vector2.ZERO, 6.0, Color(scout_blue.r, scout_blue.g, scout_blue.b, 0.85))
			draw_arc(Vector2.ZERO, 14.0, -PI, PI, 28, ring_color, 2.5, true)
			draw_arc(Vector2.ZERO, 22.0, -PI, PI, 28, Color(ring_color.r, ring_color.g, ring_color.b, alpha * 0.4), 2.0, true)
			var expand := lerpf(26.0, 32.0, pulse)
			draw_arc(Vector2.ZERO, expand, -PI, PI, 28, Color(ring_color.r, ring_color.g, ring_color.b, alpha * 0.2), 1.5, true)
		State.DISCOVERED:
			var fade := fade_timer / 0.5
			var flash_color := Color(1.0, 1.0, 1.0, fade * 0.8)
			var ring_alpha := fade * 0.6
			draw_circle(Vector2.ZERO, lerpf(14.0, 8.0, fade), flash_color)
			draw_arc(Vector2.ZERO, lerpf(36.0, 18.0, fade), -PI, PI, 28, Color(scout_blue.r, scout_blue.g, scout_blue.b, ring_alpha), 2.0, true)
