extends Node2D

const WORLD_SIZE := Vector2(1280.0, 720.0)
const PLAY_BOUNDS := Rect2(Vector2(70.0, 110.0), Vector2(1140.0, 540.0))
const FARMHOUSE_POS := Vector2(640.0, 610.0)
const TURRET_COST := 8

const PLAYER_SCENE := preload("res://scenes/player.tscn")
const ALIEN_SCENE := preload("res://scenes/alien.tscn")
const BULLET_SCENE := preload("res://scenes/bullet.tscn")
const TURRET_SCENE := preload("res://scenes/turret.tscn")
const BUILD_SPOT_SCENE := preload("res://scenes/build_spot.tscn")

var player: CharacterBody2D
var stats_label: Label
var banner_label: Label
var hint_label: Label
var spawn_timer: Timer
var wave_timer: Timer
var banner_timer: Timer

var scrap := 12
var base_health := 10
var kills := 0
var wave := 1
var game_over := false
var banner_default := "Hold the north field. Build coil turrets on the bright pads."


func _ready() -> void:
	randomize()
	_setup_ui()
	_setup_timers()
	_spawn_player()
	_spawn_build_spots()
	_update_stats()
	_set_banner("Wave 1: First contact over Miller Farm.", 4.0)
	spawn_timer.start(2.35)
	wave_timer.start(18.0)
	queue_redraw()


func _setup_ui() -> void:
	var canvas_layer: CanvasLayer = CanvasLayer.new()
	add_child(canvas_layer)

	var top_panel: ColorRect = ColorRect.new()
	top_panel.position = Vector2(0.0, 0.0)
	top_panel.size = Vector2(WORLD_SIZE.x, 64.0)
	top_panel.color = Color(0.10, 0.16, 0.11, 0.84)
	top_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas_layer.add_child(top_panel)

	stats_label = Label.new()
	stats_label.position = Vector2(18.0, 14.0)
	stats_label.size = Vector2(560.0, 30.0)
	stats_label.modulate = Color8(240, 236, 214)
	top_panel.add_child(stats_label)

	banner_label = Label.new()
	banner_label.position = Vector2(560.0, 14.0)
	banner_label.size = Vector2(700.0, 30.0)
	banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	banner_label.modulate = Color8(255, 203, 120)
	top_panel.add_child(banner_label)

	var bottom_panel: ColorRect = ColorRect.new()
	bottom_panel.position = Vector2(0.0, WORLD_SIZE.y - 44.0)
	bottom_panel.size = Vector2(WORLD_SIZE.x, 44.0)
	bottom_panel.color = Color(0.16, 0.10, 0.08, 0.80)
	bottom_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas_layer.add_child(bottom_panel)

	hint_label = Label.new()
	hint_label.position = Vector2(18.0, 11.0)
	hint_label.size = Vector2(WORLD_SIZE.x - 36.0, 22.0)
	hint_label.modulate = Color8(244, 234, 215)
	hint_label.text = "Move: WASD or arrows   Fire: left click or Space   Build: click a bright pad (8 scrap)   Restart: R"
	bottom_panel.add_child(hint_label)


func _setup_timers() -> void:
	spawn_timer = Timer.new()
	spawn_timer.timeout.connect(_spawn_alien)
	add_child(spawn_timer)

	wave_timer = Timer.new()
	wave_timer.timeout.connect(_advance_wave)
	add_child(wave_timer)

	banner_timer = Timer.new()
	banner_timer.one_shot = true
	banner_timer.timeout.connect(_restore_banner)
	add_child(banner_timer)


func _spawn_player() -> void:
	player = PLAYER_SCENE.instantiate()
	player.position = Vector2(640.0, 510.0)
	player.play_bounds = PLAY_BOUNDS
	player.fired.connect(_on_player_fired)
	add_child(player)


func _spawn_build_spots() -> void:
	var build_positions: Array[Vector2] = [
		Vector2(430.0, 548.0),
		Vector2(535.0, 582.0),
		Vector2(745.0, 582.0),
		Vector2(850.0, 548.0)
	]

	for build_position in build_positions:
		var build_spot = BUILD_SPOT_SCENE.instantiate()
		build_spot.position = build_position
		build_spot.build_requested.connect(_on_build_requested)
		add_child(build_spot)


func _spawn_alien() -> void:
	if game_over:
		return

	var alien = ALIEN_SCENE.instantiate()
	var spawn_position: Vector2 = _pick_spawn_position()
	var goal_position: Vector2 = FARMHOUSE_POS + Vector2(randf_range(-92.0, 92.0), randf_range(-30.0, 24.0))
	alien.configure(spawn_position, goal_position, wave)
	alien.destroyed.connect(_on_alien_destroyed)
	alien.farmhouse_hit.connect(_on_alien_farmhouse_hit)
	add_child(alien)


func _pick_spawn_position() -> Vector2:
	match randi() % 3:
		0:
			return Vector2(randf_range(70.0, WORLD_SIZE.x - 70.0), -42.0)
		1:
			return Vector2(-42.0, randf_range(100.0, 360.0))
		_:
			return Vector2(WORLD_SIZE.x + 42.0, randf_range(100.0, 360.0))


func _advance_wave() -> void:
	if game_over:
		return

	wave += 1
	var next_spawn_time: float = maxf(0.70, spawn_timer.wait_time * 0.88)
	spawn_timer.start(next_spawn_time)
	banner_default = "Wave %d: More saucers are diving for the farmhouse." % wave
	_set_banner("Wave %d incoming. Their attack speed just jumped." % wave, 3.0)
	_update_stats()


func _on_player_fired(origin: Vector2, direction: Vector2) -> void:
	if game_over:
		return

	var bullet = BULLET_SCENE.instantiate()
	bullet.global_position = origin
	bullet.configure(direction, 860.0, 1)
	add_child(bullet)


func _on_build_requested(spot) -> void:
	if game_over:
		return

	if scrap < TURRET_COST:
		_set_banner("Need %d scrap to wire up a coil turret." % TURRET_COST, 1.8)
		return

	if spot.occupied:
		return

	scrap -= TURRET_COST
	spot.mark_built()

	var turret = TURRET_SCENE.instantiate()
	turret.position = spot.position
	turret.configure(BULLET_SCENE)
	add_child(turret)

	_set_banner("Coil turret online. Keep the lane clear.", 1.8)
	_update_stats()


func _on_alien_destroyed(scrap_value: int, _world_position: Vector2) -> void:
	if game_over:
		return

	scrap += scrap_value
	kills += 1
	if kills % 6 == 0:
		_set_banner("The wreck pile is growing. Spend that scrap.", 1.8)
	_update_stats()


func _on_alien_farmhouse_hit(damage: int) -> void:
	if game_over:
		return

	base_health -= damage
	if base_health <= 0:
		_trigger_game_over()
	else:
		_set_banner("The farmhouse took a hit!", 1.4)
		_update_stats()


func _trigger_game_over() -> void:
	game_over = true
	base_health = 0
	spawn_timer.stop()
	wave_timer.stop()
	banner_timer.stop()
	banner_default = "Farm overrun. Press R to restart the defense."
	banner_label.text = banner_default
	hint_label.text = "Restart with R, then rebuild the farm defense line."
	_update_stats()


func _set_banner(text: String, duration: float = 2.0) -> void:
	banner_label.text = text
	if duration > 0.0:
		banner_timer.start(duration)


func _restore_banner() -> void:
	banner_label.text = banner_default


func _update_stats() -> void:
	stats_label.text = "Scrap %02d   Base %02d   Wave %02d   Kills %02d" % [scrap, base_health, wave, kills]


func _unhandled_input(event: InputEvent) -> void:
	if game_over and event.is_action_pressed("restart"):
		get_viewport().set_input_as_handled()
		get_tree().reload_current_scene()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), Color8(251, 210, 157))
	draw_circle(Vector2(1116.0, 118.0), 76.0, Color8(255, 239, 174))
	draw_rect(Rect2(Vector2(0.0, 248.0), Vector2(WORLD_SIZE.x, 472.0)), Color8(195, 151, 82))
	draw_rect(Rect2(Vector2(0.0, 464.0), Vector2(WORLD_SIZE.x, 256.0)), Color8(120, 155, 76))

	for row in range(6):
		var y: float = 288.0 + float(row) * 34.0
		draw_line(Vector2(80.0, y), Vector2(1200.0, y + 54.0), Color8(147, 110, 58), 2.0, true)

	for x in range(96, 1184, 48):
		draw_line(Vector2(float(x), 440.0), Vector2(float(x), 470.0), Color8(235, 224, 193), 3.0, true)
	draw_line(Vector2(72.0, 444.0), Vector2(1208.0, 444.0), Color8(235, 224, 193), 4.0, true)
	draw_line(Vector2(72.0, 470.0), Vector2(1208.0, 470.0), Color8(235, 224, 193), 4.0, true)

	var lane_rect := Rect2(Vector2(FARMHOUSE_POS.x - 62.0, 420.0), Vector2(124.0, 180.0))
	draw_rect(lane_rect, Color8(170, 139, 94))

	var barn_body := Rect2(FARMHOUSE_POS + Vector2(-108.0, -112.0), Vector2(216.0, 118.0))
	draw_rect(barn_body, Color8(188, 62, 43))
	draw_rect(Rect2(FARMHOUSE_POS + Vector2(-26.0, -56.0), Vector2(52.0, 62.0)), Color8(93, 52, 33))
	draw_rect(Rect2(FARMHOUSE_POS + Vector2(-82.0, -86.0), Vector2(44.0, 34.0)), Color8(242, 233, 210))
	draw_rect(Rect2(FARMHOUSE_POS + Vector2(38.0, -86.0), Vector2(44.0, 34.0)), Color8(242, 233, 210))

	var roof_points := PackedVector2Array([
		FARMHOUSE_POS + Vector2(-122.0, -112.0),
		FARMHOUSE_POS + Vector2(0.0, -186.0),
		FARMHOUSE_POS + Vector2(122.0, -112.0)
	])
	draw_colored_polygon(roof_points, Color8(88, 41, 34))

	var silo_rect := Rect2(FARMHOUSE_POS + Vector2(146.0, -148.0), Vector2(58.0, 154.0))
	draw_rect(silo_rect, Color8(113, 123, 134))
	draw_circle(FARMHOUSE_POS + Vector2(175.0, -148.0), 29.0, Color8(141, 152, 163))
