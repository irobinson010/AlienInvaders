extends Node2D

enum PatchPath {
	NONE,
	SCRAP,
	GUARD,
	SCOUT,
}

const WORLD_SIZE := Vector2(1280.0, 720.0)
const PLAY_BOUNDS := Rect2(Vector2(70.0, 110.0), Vector2(1140.0, 540.0))
const FARMHOUSE_POS := Vector2(640.0, 610.0)
const BASE_TURRET_COST := 8

const PLAYER_SCENE := preload("res://scenes/player.tscn")
const DOG_SCENE := preload("res://scenes/dog.tscn")
const ALIEN_SCENE := preload("res://scenes/alien.tscn")
const BULLET_SCENE := preload("res://scenes/bullet.tscn")
const TURRET_SCENE := preload("res://scenes/turret.tscn")
const BUILD_SPOT_SCENE := preload("res://scenes/build_spot.tscn")

var player: CharacterBody2D
var dog: CharacterBody2D
var stats_label: Label
var banner_label: Label
var hint_label: Label
var patch_panel: PanelContainer
var patch_title_label: Label
var patch_body_label: Label
var patch_footer_label: Label
var patch_scrap_button: Button
var patch_guard_button: Button
var patch_scout_button: Button
var spawn_timer: Timer
var wave_timer: Timer
var banner_timer: Timer

var scrap := 12
var base_health := 10
var kills := 0
var wave := 1
var game_over := false
var banner_default := ""
var patch_path := PatchPath.NONE
var patch_rank := 0
var player_bullet_damage := 1
var player_fire_interval := 0.16
var turret_damage := 1
var turret_fire_interval := 0.80
var turret_cost := BASE_TURRET_COST


func _ready() -> void:
	randomize()
	_setup_ui()
	_setup_timers()
	_spawn_player()
	_spawn_dog()
	_spawn_build_spots()
	banner_default = _story_text_for_wave(wave)
	_update_hint()
	_update_stats()
	_set_banner(banner_default, 4.0)
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
	stats_label.size = Vector2(720.0, 30.0)
	stats_label.modulate = Color8(240, 236, 214)
	top_panel.add_child(stats_label)

	banner_label = Label.new()
	banner_label.position = Vector2(756.0, 14.0)
	banner_label.size = Vector2(500.0, 30.0)
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
	bottom_panel.add_child(hint_label)

	_setup_patch_panel(canvas_layer)


func _setup_patch_panel(canvas_layer: CanvasLayer) -> void:
	patch_panel = PanelContainer.new()
	patch_panel.position = Vector2(232.0, 140.0)
	patch_panel.size = Vector2(816.0, 300.0)
	patch_panel.visible = false
	patch_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	patch_panel.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	canvas_layer.add_child(patch_panel)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.12, 0.10, 0.08, 0.96)
	panel_style.border_color = Color8(245, 204, 124)
	panel_style.border_width_left = 3
	panel_style.border_width_top = 3
	panel_style.border_width_right = 3
	panel_style.border_width_bottom = 3
	panel_style.corner_radius_top_left = 12
	panel_style.corner_radius_top_right = 12
	panel_style.corner_radius_bottom_left = 12
	panel_style.corner_radius_bottom_right = 12
	patch_panel.add_theme_stylebox_override("panel", panel_style)

	var content: VBoxContainer = VBoxContainer.new()
	content.position = Vector2(24.0, 20.0)
	content.size = Vector2(768.0, 260.0)
	content.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	content.add_theme_constant_override("separation", 12)
	patch_panel.add_child(content)

	patch_title_label = Label.new()
	patch_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	patch_title_label.modulate = Color8(255, 222, 165)
	patch_title_label.text = "Choose Patch's training"
	content.add_child(patch_title_label)

	patch_body_label = Label.new()
	patch_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	patch_body_label.size = Vector2(768.0, 120.0)
	patch_body_label.modulate = Color8(239, 232, 213)
	content.add_child(patch_body_label)

	var buttons_row: HBoxContainer = HBoxContainer.new()
	buttons_row.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	buttons_row.add_theme_constant_override("separation", 14)
	content.add_child(buttons_row)

	patch_scrap_button = Button.new()
	patch_scrap_button.text = "Scrap Hound"
	patch_scrap_button.custom_minimum_size = Vector2(240.0, 48.0)
	patch_scrap_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	patch_scrap_button.pressed.connect(_on_patch_path_selected.bind(PatchPath.SCRAP))
	buttons_row.add_child(patch_scrap_button)

	patch_guard_button = Button.new()
	patch_guard_button.text = "Guard Dog"
	patch_guard_button.custom_minimum_size = Vector2(240.0, 48.0)
	patch_guard_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	patch_guard_button.pressed.connect(_on_patch_path_selected.bind(PatchPath.GUARD))
	buttons_row.add_child(patch_guard_button)

	patch_scout_button = Button.new()
	patch_scout_button.text = "Scout Nose"
	patch_scout_button.custom_minimum_size = Vector2(240.0, 48.0)
	patch_scout_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	patch_scout_button.pressed.connect(_on_patch_path_selected.bind(PatchPath.SCOUT))
	buttons_row.add_child(patch_scout_button)

	patch_footer_label = Label.new()
	patch_footer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	patch_footer_label.modulate = Color8(191, 198, 207)
	patch_footer_label.text = "The defense pauses until you choose."
	content.add_child(patch_footer_label)


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
	player = PLAYER_SCENE.instantiate() as CharacterBody2D
	player.position = Vector2(640.0, 510.0)
	player.play_bounds = PLAY_BOUNDS
	player.set_fire_interval(player_fire_interval)
	player.fired.connect(_on_player_fired)
	add_child(player)


func _spawn_dog() -> void:
	dog = DOG_SCENE.instantiate() as CharacterBody2D
	dog.position = Vector2(596.0, 542.0)
	dog.set_player(player)
	add_child(dog)


func _spawn_build_spots() -> void:
	var build_positions: Array[Vector2] = [
		Vector2(430.0, 548.0),
		Vector2(535.0, 582.0),
		Vector2(745.0, 582.0),
		Vector2(850.0, 548.0)
	]

	for build_position in build_positions:
		var build_spot: Area2D = BUILD_SPOT_SCENE.instantiate() as Area2D
		build_spot.position = build_position
		build_spot.build_requested.connect(_on_build_requested)
		add_child(build_spot)


func _spawn_alien() -> void:
	if game_over:
		return

	var alien: CharacterBody2D = ALIEN_SCENE.instantiate() as CharacterBody2D
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
	banner_default = _story_text_for_wave(wave)
	_set_banner(banner_default, 3.2)
	_handle_patch_progression()
	_update_hint()
	_update_stats()


func _handle_patch_progression() -> void:
	if wave == 2 and patch_path == PatchPath.NONE:
		_show_patch_choice()
		return

	var desired_rank := 0
	if wave >= 2:
		desired_rank = 1
	if wave >= 4:
		desired_rank = 2
	if wave >= 6:
		desired_rank = 3

	if patch_path != PatchPath.NONE and desired_rank > patch_rank:
		_apply_patch_rank(desired_rank)


func _show_patch_choice() -> void:
	patch_title_label.text = "Choose how Patch grows into the fight"
	patch_body_label.text = "Scrap Hound turns wrecks into bonus salvage. Guard Dog learns stun barks and doubles down on crowd control. Scout Nose uncovers buried stashes, schematics, and upgrades Eli would never find on his own."
	patch_panel.visible = true
	get_tree().paused = true


func _on_patch_path_selected(selected_path: int) -> void:
	patch_panel.visible = false
	get_tree().paused = false
	patch_path = selected_path
	_apply_patch_rank(1)


func _apply_patch_rank(new_rank: int) -> void:
	patch_rank = new_rank
	if dog != null and is_instance_valid(dog):
		dog.apply_path_rank(patch_path, patch_rank)

	var upgrade_text := ""
	match patch_path:
		PatchPath.SCRAP:
			upgrade_text = _apply_scrap_rank()
		PatchPath.GUARD:
			upgrade_text = _apply_guard_rank()
		PatchPath.SCOUT:
			upgrade_text = _apply_scout_rank()

	banner_default = _story_text_for_wave(wave)
	_update_hint()
	_update_stats()
	_set_banner(upgrade_text, 4.0)


func _apply_scrap_rank() -> String:
	match patch_rank:
		1:
			return "Patch becomes a scrap hound. He starts pulling bonus salvage from wrecks."
		2:
			return "Patch learns where the clean alloy hides. Salvage bonuses come faster."
		3:
			return "Patch is now stripping every saucer he drops. Scrap income spikes."
		_:
			return ""


func _apply_guard_rank() -> String:
	match patch_rank:
		1:
			return "Patch becomes the guard dog. His stun bark can freeze a small rush."
		2:
			return "Patch's bark carries across the lane now. More aliens lock in place."
		3:
			return "Patch unleashes a full war bark. The farm line gets real breathing room."
		_:
			return ""


func _apply_scout_rank() -> String:
	match patch_rank:
		1:
			turret_cost = max(4, BASE_TURRET_COST - 2)
			return "Patch uncovers buried coil plans in the field. Turrets now cost %d scrap." % turret_cost
		2:
			player_fire_interval = maxf(0.10, player_fire_interval - 0.03)
			player.set_fire_interval(player_fire_interval)
			return "Patch finds an old capacitor cache. Eli can fire his homemade weapon faster."
		3:
			turret_damage += 1
			base_health += 2
			_refresh_turret_stats()
			return "Patch digs up a sealed alien lens. Turrets hit harder and the farmhouse gets reinforced."
		_:
			return ""


func _refresh_turret_stats() -> void:
	for node in get_tree().get_nodes_in_group("turrets"):
		if node.has_method("set_stats"):
			node.set_stats(turret_fire_interval, turret_damage)


func _on_player_fired(origin: Vector2, direction: Vector2) -> void:
	if game_over:
		return

	var bullet: Area2D = BULLET_SCENE.instantiate() as Area2D
	bullet.global_position = origin
	bullet.configure(direction, 860.0, player_bullet_damage)
	add_child(bullet)


func _on_build_requested(spot) -> void:
	if game_over:
		return

	if scrap < turret_cost:
		_set_banner("Need %d scrap to wire up a coil turret." % turret_cost, 1.8)
		return

	if spot.occupied:
		return

	scrap -= turret_cost
	spot.mark_built()

	var turret: Node2D = TURRET_SCENE.instantiate() as Node2D
	turret.position = spot.position
	turret.configure(BULLET_SCENE, turret_fire_interval, turret_damage)
	add_child(turret)

	_set_banner("Coil turret online. Keep the lane clear.", 1.8)
	_update_hint()
	_update_stats()


func _on_alien_destroyed(scrap_value: int, _world_position: Vector2) -> void:
	if game_over:
		return

	var total_scrap := scrap_value
	var salvage_bonus := 0
	if patch_path == PatchPath.SCRAP and dog != null and is_instance_valid(dog):
		salvage_bonus = dog.claim_salvage_bonus()
		total_scrap += salvage_bonus

	scrap += total_scrap
	kills += 1
	if salvage_bonus > 0 and kills % 4 == 0:
		_set_banner("Patch strips extra alloy from the crash site.", 1.5)
	elif patch_path == PatchPath.SCOUT and kills % 8 == 0:
		_set_banner("Patch keeps circling the old field markers.", 1.5)
	elif kills % 6 == 0:
		_set_banner("Patch drags another chunk of saucer junk into the dirt.", 1.8)
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
	if patch_panel.visible:
		patch_panel.visible = false
		get_tree().paused = false
	banner_default = "Farm overrun. Press R to restart the defense."
	banner_label.text = banner_default
	hint_label.text = "Restart with R, then get Eli and Patch back on the fence line."
	_update_stats()


func _set_banner(text: String, duration: float = 2.0) -> void:
	banner_label.text = text
	if duration > 0.0:
		banner_timer.start(duration)


func _restore_banner() -> void:
	banner_label.text = banner_default


func _update_stats() -> void:
	stats_label.text = "Scrap %02d   Base %02d   Wave %02d   Kills %02d   Patch %s" % [scrap, base_health, wave, kills, _patch_summary()]


func _update_hint() -> void:
	if game_over:
		return

	var patch_hint := ""
	match patch_path:
		PatchPath.NONE:
			if wave >= 2:
				patch_hint = "Patch path ready: choose Scrap Hound, Guard Dog, or Scout Nose."
			else:
				patch_hint = "Patch fights beside Eli for now."
		PatchPath.SCRAP:
			patch_hint = "Patch path: Scrap Hound bonuses kick in after wrecks."
		PatchPath.GUARD:
			patch_hint = "Patch path: Guard Dog stun bark disrupts nearby aliens."
		PatchPath.SCOUT:
			patch_hint = "Patch path: Scout Nose reveals hidden upgrades."

	hint_label.text = "Move: WASD or arrows   Fire: left click or Space   Build: click a bright pad (%d scrap)   %s   Restart: R" % [turret_cost, patch_hint]


func _patch_summary() -> String:
	match patch_path:
		PatchPath.SCRAP:
			return "Scrap %s" % _patch_rank_to_roman(patch_rank)
		PatchPath.GUARD:
			return "Guard %s" % _patch_rank_to_roman(patch_rank)
		PatchPath.SCOUT:
			return "Scout %s" % _patch_rank_to_roman(patch_rank)
		_:
			return "Untrained"


func _patch_rank_to_roman(rank_value: int) -> String:
	match rank_value:
		1:
			return "I"
		2:
			return "II"
		3:
			return "III"
		_:
			return "-"


func _story_text_for_wave(current_wave: int) -> String:
	match current_wave:
		1:
			return "Wave 1: Eli and Patch hear the first saucers over Miller Farm."
		2:
			match patch_path:
				PatchPath.SCRAP:
					return "Wave 2: Patch starts pulling clean alloy from the smoking scouts."
				PatchPath.GUARD:
					return "Wave 2: Patch locks onto the fence line and starts barking down rushes."
				PatchPath.SCOUT:
					return "Wave 2: Patch starts sniffing around the north field markers."
				_:
					return "Wave 2: Eli decides what kind of war dog Patch needs to become."
		3:
			return "Wave 3: The barn bench spits out coil parts from salvaged alien cores."
		4:
			match patch_path:
				PatchPath.SCOUT:
					return "Wave 4: Patch tracks the crop circles to a buried signal spike."
				PatchPath.SCRAP:
					return "Wave 4: Eli and Patch turn the wreck pile into a real war chest."
				PatchPath.GUARD:
					return "Wave 4: Patch starts controlling the lane before the aliens even land."
				_:
					return "Wave 4: Fresh crop circles point to something buried under the north field."
		5:
			return "Wave 5: The invaders start drilling for whatever is below the corn."
		6:
			match patch_path:
				PatchPath.SCOUT:
					return "Wave 6: Patch turns up sealed alien gear under the tractor shed."
				PatchPath.SCRAP:
					return "Wave 6: The salvage pile grows into a full workshop behind the barn."
				PatchPath.GUARD:
					return "Wave 6: Patch's bark rolls across the farm like thunder."
				_:
					return "Wave 6: Eli turns the tractor shed into a war workshop."
		_:
			return "Wave %d: More saucers are diving for the farmhouse." % current_wave


func _unhandled_input(event: InputEvent) -> void:
	if game_over and event.is_action_pressed("restart"):
		get_viewport().set_input_as_handled()
		get_tree().paused = false
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
