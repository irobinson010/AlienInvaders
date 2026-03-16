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
const DRILL_SITE_POS := Vector2(640.0, 386.0)
const BASE_TURRET_COST := 8
const ACT_ONE_WAVES = [
	{
		"title": "Act 1: First Contact",
		"story": "Strange lights sweep over the corn. Eli grabs his barn-built nailgun while Patch circles the porch, waiting for the first landing.",
		"objective": "Hold the north fence against 6 scout saucers.",
		"spawn_count": 6,
		"driller_count": 0,
		"spawn_interval": 1.95,
		"start_delay": 0.80,
		"spawn_mode": "top",
	},
	{
		"title": "Wave 2: Fence Breakers",
		"story": "The first wrecks are still smoking. Patch takes on a real job while a second alien rush lines up over the field with a heavier breaker in the mix.",
		"objective": "Stop 8 raiders, including the first driller brute, and put Patch's first training to work.",
		"spawn_count": 8,
		"driller_count": 1,
		"spawn_interval": 1.75,
		"start_delay": 0.75,
		"spawn_mode": "mixed",
	},
	{
		"title": "Wave 3: Drill Team",
		"story": "The invaders stop probing and start drilling. A real rig unfolds in the north field while driller aliens sprint to feed it power.",
		"objective": "Destroy the north-field drill rig and break 10 attackers before it breaches the field.",
		"spawn_count": 10,
		"driller_count": 2,
		"drill_site": true,
		"drill_rate": 2.30,
		"drill_health": 10,
		"spawn_interval": 1.50,
		"start_delay": 0.70,
		"spawn_mode": "sides",
	},
	{
		"title": "Wave 4: North Field Signal",
		"story": "Crop circles are no longer random. The whole north field is lining up around something buried deep below the roots.",
		"objective": "Clear 12 invaders while Eli and Patch hold the signal line.",
		"spawn_count": 12,
		"driller_count": 2,
		"spawn_interval": 1.30,
		"start_delay": 0.70,
		"spawn_mode": "top",
	},
	{
		"title": "Wave 5: Harvester Approach",
		"story": "More lights peel off the mothership. The farmhouse porch shakes as a harvester run starts forming over the silo.",
		"objective": "Hold off 14 attackers before the harvester locks onto the farm.",
		"spawn_count": 14,
		"driller_count": 3,
		"spawn_interval": 1.10,
		"start_delay": 0.65,
		"spawn_mode": "mixed",
	},
	{
		"title": "Wave 6: Final Stand At The Silo",
		"story": "Everything comes in at once. A command drill rig locks onto the signal under the field while the biggest driller wave of the night crashes toward the farm.",
		"objective": "Smash the command drill rig, survive the last 16 attackers, and keep the farmhouse standing.",
		"spawn_count": 16,
		"driller_count": 4,
		"drill_site": true,
		"drill_rate": 3.10,
		"drill_health": 14,
		"spawn_interval": 0.92,
		"start_delay": 0.60,
		"spawn_mode": "mixed",
	},
]

const PLAYER_SCENE := preload("res://scenes/player.tscn")
const DOG_SCENE := preload("res://scenes/dog.tscn")
const ALIEN_SCENE := preload("res://scenes/alien.tscn")
const DRILL_RIG_SCENE := preload("res://scenes/drill_rig.tscn")
const BULLET_SCENE := preload("res://scenes/bullet.tscn")
const TURRET_SCENE := preload("res://scenes/turret.tscn")
const BUILD_SPOT_SCENE := preload("res://scenes/build_spot.tscn")

var player: CharacterBody2D
var dog: CharacterBody2D
var current_drill_site: StaticBody2D
var stats_label: Label
var banner_label: Label
var hint_label: Label
var briefing_panel: PanelContainer
var briefing_title_label: Label
var briefing_body_label: Label
var briefing_footer_label: Label
var briefing_continue_button: Button
var upgrade_panel: PanelContainer
var upgrade_title_label: Label
var upgrade_body_label: Label
var upgrade_footer_label: Label
var upgrade_button_a: Button
var upgrade_button_b: Button
var upgrade_button_c: Button
var patch_panel: PanelContainer
var patch_title_label: Label
var patch_body_label: Label
var patch_footer_label: Label
var patch_scrap_button: Button
var patch_guard_button: Button
var patch_scout_button: Button
var spawn_timer: Timer
var banner_timer: Timer

var scrap := 12
var base_health := 10
var kills := 0
var wave := 0
var game_over := false
var mission_complete := false
var wave_active := false
var banner_default := ""
var patch_path := PatchPath.NONE
var patch_rank := 0
var player_bullet_damage := 1
var player_fire_interval := 0.16
var player_move_speed := 270.0
var turret_damage := 1
var turret_fire_interval := 0.80
var turret_cost := BASE_TURRET_COST
var current_objective_text := "Review Eli's first defense plan."
var current_wave_index := -1
var pending_wave_index := -1
var wave_total_spawns := 0
var wave_spawned := 0
var active_aliens := 0
var wave_drillers_remaining := 0
var current_wave_spawn_interval := 1.50
var current_wave_start_delay := 0.80
var current_wave_spawn_mode := "mixed"
var pending_upgrade_choices: Array[Dictionary] = []
var pending_upgrade_wave_index := -1
var pending_transition_text := ""


func _ready() -> void:
	randomize()
	_setup_ui()
	_setup_timers()
	_spawn_player()
	_spawn_dog()
	_spawn_build_spots()
	_update_hint()
	_update_stats()
	_show_briefing_for_wave(0, "Patch has not picked a specialty yet. This first wave is just about surviving the landing.")
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
	stats_label.size = Vector2(820.0, 30.0)
	stats_label.modulate = Color8(240, 236, 214)
	top_panel.add_child(stats_label)

	banner_label = Label.new()
	banner_label.position = Vector2(852.0, 14.0)
	banner_label.size = Vector2(388.0, 30.0)
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

	_setup_briefing_panel(canvas_layer)
	_setup_upgrade_panel(canvas_layer)
	_setup_patch_panel(canvas_layer)


func _setup_briefing_panel(canvas_layer: CanvasLayer) -> void:
	briefing_panel = PanelContainer.new()
	briefing_panel.position = Vector2(214.0, 124.0)
	briefing_panel.size = Vector2(852.0, 356.0)
	briefing_panel.visible = false
	briefing_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	briefing_panel.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	canvas_layer.add_child(briefing_panel)

	var panel_style: StyleBoxFlat = StyleBoxFlat.new()
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
	briefing_panel.add_theme_stylebox_override("panel", panel_style)

	var content: VBoxContainer = VBoxContainer.new()
	content.position = Vector2(26.0, 22.0)
	content.size = Vector2(800.0, 310.0)
	content.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	content.add_theme_constant_override("separation", 14)
	briefing_panel.add_child(content)

	briefing_title_label = Label.new()
	briefing_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	briefing_title_label.modulate = Color8(255, 222, 165)
	content.add_child(briefing_title_label)

	briefing_body_label = Label.new()
	briefing_body_label.size = Vector2(800.0, 180.0)
	briefing_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	briefing_body_label.modulate = Color8(239, 232, 213)
	content.add_child(briefing_body_label)

	briefing_footer_label = Label.new()
	briefing_footer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	briefing_footer_label.modulate = Color8(191, 198, 207)
	briefing_footer_label.text = "The field stays frozen until Eli commits to the next move."
	content.add_child(briefing_footer_label)

	briefing_continue_button = Button.new()
	briefing_continue_button.custom_minimum_size = Vector2(260.0, 48.0)
	briefing_continue_button.text = "Start Defense"
	briefing_continue_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	briefing_continue_button.pressed.connect(_on_briefing_continue_pressed)
	content.add_child(briefing_continue_button)


func _setup_upgrade_panel(canvas_layer: CanvasLayer) -> void:
	upgrade_panel = PanelContainer.new()
	upgrade_panel.position = Vector2(208.0, 116.0)
	upgrade_panel.size = Vector2(864.0, 372.0)
	upgrade_panel.visible = false
	upgrade_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	upgrade_panel.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	canvas_layer.add_child(upgrade_panel)

	var panel_style: StyleBoxFlat = StyleBoxFlat.new()
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
	upgrade_panel.add_theme_stylebox_override("panel", panel_style)

	var content: VBoxContainer = VBoxContainer.new()
	content.position = Vector2(24.0, 20.0)
	content.size = Vector2(816.0, 326.0)
	content.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	content.add_theme_constant_override("separation", 12)
	upgrade_panel.add_child(content)

	upgrade_title_label = Label.new()
	upgrade_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	upgrade_title_label.modulate = Color8(255, 222, 165)
	content.add_child(upgrade_title_label)

	upgrade_body_label = Label.new()
	upgrade_body_label.size = Vector2(816.0, 138.0)
	upgrade_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	upgrade_body_label.modulate = Color8(239, 232, 213)
	content.add_child(upgrade_body_label)

	var buttons_row: HBoxContainer = HBoxContainer.new()
	buttons_row.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	buttons_row.add_theme_constant_override("separation", 14)
	content.add_child(buttons_row)

	upgrade_button_a = Button.new()
	upgrade_button_a.custom_minimum_size = Vector2(250.0, 90.0)
	upgrade_button_a.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	upgrade_button_a.pressed.connect(_on_upgrade_selected.bind(0))
	buttons_row.add_child(upgrade_button_a)

	upgrade_button_b = Button.new()
	upgrade_button_b.custom_minimum_size = Vector2(250.0, 90.0)
	upgrade_button_b.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	upgrade_button_b.pressed.connect(_on_upgrade_selected.bind(1))
	buttons_row.add_child(upgrade_button_b)

	upgrade_button_c = Button.new()
	upgrade_button_c.custom_minimum_size = Vector2(250.0, 90.0)
	upgrade_button_c.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	upgrade_button_c.pressed.connect(_on_upgrade_selected.bind(2))
	buttons_row.add_child(upgrade_button_c)

	upgrade_footer_label = Label.new()
	upgrade_footer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	upgrade_footer_label.modulate = Color8(191, 198, 207)
	upgrade_footer_label.text = "Choose one invention. The others stay sketches on the workbench."
	content.add_child(upgrade_footer_label)


func _setup_patch_panel(canvas_layer: CanvasLayer) -> void:
	patch_panel = PanelContainer.new()
	patch_panel.position = Vector2(232.0, 140.0)
	patch_panel.size = Vector2(816.0, 300.0)
	patch_panel.visible = false
	patch_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	patch_panel.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	canvas_layer.add_child(patch_panel)

	var panel_style: StyleBoxFlat = StyleBoxFlat.new()
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
	patch_footer_label.text = "Patch earns deeper upgrades before waves 4 and 6."
	content.add_child(patch_footer_label)


func _setup_timers() -> void:
	spawn_timer = Timer.new()
	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)

	banner_timer = Timer.new()
	banner_timer.one_shot = true
	banner_timer.timeout.connect(_restore_banner)
	add_child(banner_timer)


func _spawn_player() -> void:
	player = PLAYER_SCENE.instantiate() as CharacterBody2D
	player.position = Vector2(640.0, 510.0)
	player.play_bounds = PLAY_BOUNDS
	player.set_move_speed(player_move_speed)
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


func _show_briefing_for_wave(wave_index: int, transition_text: String = "") -> void:
	var wave_data: Dictionary = ACT_ONE_WAVES[wave_index]
	pending_wave_index = wave_index
	wave = wave_index + 1
	wave_active = false
	current_objective_text = "Review the plan for wave %d." % wave
	banner_default = String(wave_data["title"])
	briefing_title_label.text = String(wave_data["title"])
	briefing_body_label.text = _compose_briefing_text(wave_data, transition_text)
	briefing_continue_button.text = "Start Wave %d" % wave
	if wave_index == 0:
		briefing_continue_button.text = "Start Defense"
	briefing_panel.visible = true
	upgrade_panel.visible = false
	patch_panel.visible = false
	get_tree().paused = true
	banner_label.text = banner_default
	_update_hint()
	_update_stats()


func _compose_briefing_text(wave_data: Dictionary, transition_text: String) -> String:
	var briefing_text: String = String(wave_data["story"])
	if transition_text != "":
		briefing_text = transition_text + "\n\n" + briefing_text
	briefing_text += "\n\nObjective: %s" % String(wave_data["objective"])
	return briefing_text


func _on_briefing_continue_pressed() -> void:
	if mission_complete:
		get_tree().paused = false
		get_tree().reload_current_scene()
		return

	briefing_panel.visible = false
	get_tree().paused = false
	_start_wave(pending_wave_index)


func _start_wave(wave_index: int) -> void:
	var wave_data: Dictionary = ACT_ONE_WAVES[wave_index]
	current_wave_index = wave_index
	wave = wave_index + 1
	wave_active = true
	current_wave_spawn_interval = float(wave_data["spawn_interval"])
	current_wave_start_delay = float(wave_data["start_delay"])
	current_wave_spawn_mode = String(wave_data["spawn_mode"])
	current_objective_text = String(wave_data["objective"])
	wave_total_spawns = int(wave_data["spawn_count"])
	wave_drillers_remaining = int(wave_data["driller_count"])
	wave_spawned = 0
	active_aliens = 0
	_spawn_wave_objectives(wave_data)
	banner_default = _story_text_for_wave(wave)
	_set_banner(banner_default, 3.0)
	_update_hint()
	_update_stats()
	spawn_timer.start(current_wave_start_delay)


func _on_spawn_timer_timeout() -> void:
	_spawn_alien()
	if wave_active and wave_spawned < wave_total_spawns:
		spawn_timer.start(current_wave_spawn_interval)


func _spawn_alien() -> void:
	if game_over or mission_complete or not wave_active:
		return

	var enemy_kind: String = _pick_enemy_kind()
	var alien: CharacterBody2D = ALIEN_SCENE.instantiate() as CharacterBody2D
	var spawn_position: Vector2 = _pick_spawn_position(current_wave_spawn_mode)
	var goal_position: Vector2 = FARMHOUSE_POS + Vector2(randf_range(-92.0, 92.0), randf_range(-30.0, 24.0))
	var targets_drill_site := false
	if enemy_kind == "driller" and _has_live_drill_site():
		goal_position = current_drill_site.global_position
		targets_drill_site = true
	alien.configure(spawn_position, goal_position, wave, enemy_kind, targets_drill_site)
	alien.destroyed.connect(_on_alien_destroyed)
	alien.farmhouse_hit.connect(_on_alien_farmhouse_hit)
	alien.drill_site_reached.connect(_on_alien_drill_site_reached)
	add_child(alien)
	wave_spawned += 1
	active_aliens += 1
	_update_stats()


func _spawn_wave_objectives(wave_data: Dictionary) -> void:
	current_drill_site = null
	if not bool(wave_data.get("drill_site", false)):
		return

	var drill_rig: StaticBody2D = DRILL_RIG_SCENE.instantiate() as StaticBody2D
	drill_rig.position = DRILL_SITE_POS
	drill_rig.configure(int(wave_data["drill_health"]), float(wave_data["drill_rate"]), 4 + wave)
	drill_rig.destroyed.connect(_on_drill_site_destroyed)
	drill_rig.breached.connect(_on_drill_site_breached)
	add_child(drill_rig)
	current_drill_site = drill_rig
	active_aliens += 1


func _pick_enemy_kind() -> String:
	if wave_drillers_remaining <= 0:
		return "scout"

	var should_spawn_driller := false
	var remaining_slots: int = wave_total_spawns - wave_spawned
	if wave_spawned >= int(floor(float(wave_total_spawns) * 0.5)):
		should_spawn_driller = true
	if remaining_slots <= wave_drillers_remaining:
		should_spawn_driller = true

	if should_spawn_driller:
		wave_drillers_remaining -= 1
		return "driller"

	return "scout"


func _has_live_drill_site() -> bool:
	return current_drill_site != null and is_instance_valid(current_drill_site)


func _pick_spawn_position(spawn_mode: String) -> Vector2:
	match spawn_mode:
		"top":
			return Vector2(randf_range(70.0, WORLD_SIZE.x - 70.0), -42.0)
		"sides":
			if randi() % 2 == 0:
				return Vector2(-42.0, randf_range(110.0, 360.0))
			return Vector2(WORLD_SIZE.x + 42.0, randf_range(110.0, 360.0))
		_:
			match randi() % 3:
				0:
					return Vector2(randf_range(70.0, WORLD_SIZE.x - 70.0), -42.0)
				1:
					return Vector2(-42.0, randf_range(100.0, 360.0))
				_:
					return Vector2(WORLD_SIZE.x + 42.0, randf_range(100.0, 360.0))


func _show_patch_choice() -> void:
	wave = 2
	current_objective_text = "Choose how Patch helps hold the farm."
	banner_default = "Patch needs a job before the second rush."
	patch_title_label.text = "Choose how Patch grows into the fight"
	patch_body_label.text = "Scrap Hound turns wrecks into bonus salvage. Guard Dog learns stun barks and doubles down on crowd control. Scout Nose uncovers buried stashes, schematics, and upgrades Eli would never find on his own."
	patch_panel.visible = true
	briefing_panel.visible = false
	upgrade_panel.visible = false
	get_tree().paused = true
	banner_label.text = banner_default
	_update_hint()
	_update_stats()


func _on_patch_path_selected(selected_path: int) -> void:
	patch_path = selected_path
	var upgrade_text: String = _apply_patch_rank(1, false)
	patch_panel.visible = false
	_show_upgrade_panel(1, "The first wrecks cool in the dirt while Eli picks Patch's lane.\n\nPatch upgrade: %s" % upgrade_text)


func _show_upgrade_panel(next_wave_index: int, transition_text: String) -> void:
	var next_wave_number: int = next_wave_index + 1
	var options: Array[Dictionary] = _upgrade_options_for_wave(next_wave_number)
	if options.is_empty():
		_show_briefing_for_wave(next_wave_index, transition_text)
		return

	pending_upgrade_wave_index = next_wave_index
	pending_transition_text = transition_text
	pending_upgrade_choices = options
	current_objective_text = "Choose Eli's next invention for wave %d." % next_wave_number
	banner_default = "Barn workshop: pick one invention before wave %d." % next_wave_number
	upgrade_title_label.text = "Workshop Break: Build One New Invention"
	upgrade_body_label.text = _upgrade_panel_text(next_wave_number, transition_text)
	upgrade_button_a.text = _upgrade_button_text(options[0])
	upgrade_button_b.text = _upgrade_button_text(options[1])
	upgrade_button_c.text = _upgrade_button_text(options[2])
	upgrade_panel.visible = true
	briefing_panel.visible = false
	patch_panel.visible = false
	get_tree().paused = true
	banner_label.text = banner_default
	_update_hint()
	_update_stats()


func _upgrade_panel_text(next_wave_number: int, transition_text: String) -> String:
	var body_text := transition_text
	if body_text != "":
		body_text += "\n\n"
	body_text += "Eli has time for one more bench-built upgrade before wave %d hits the fence." % next_wave_number
	return body_text


func _upgrade_button_text(option: Dictionary) -> String:
	return "%s\n%s" % [String(option["name"]), String(option["description"])]


func _upgrade_options_for_wave(next_wave_number: int) -> Array[Dictionary]:
	var options: Array[Dictionary] = []
	match next_wave_number:
		2:
			options = [
				{"id":"fence_crank_repeater","name":"Fence Crank Repeater","description":"Tighten Eli's nailgun cycle for faster shots."},
				{"id":"sheet_metal_siding","name":"Sheet-Metal Siding","description":"Bolt fresh plating onto the farmhouse. Base +2."},
				{"id":"salvage_sled","name":"Salvage Sled","description":"Hook a crate behind the tractor. Gain 6 scrap now."}
			]
		3:
			options = [
				{"id":"capacitor_slugs","name":"Capacitor Slugs","description":"Overcharge the ammo feed. Player shots hit harder."},
				{"id":"quick_weld_mounts","name":"Quick-Weld Mounts","description":"Let every turret track and fire faster."},
				{"id":"coil_molds","name":"Coil Molds","description":"Reuse emitter shells. Turrets cost 1 less scrap."}
			]
		4:
			options = [
				{"id":"boot_springs","name":"Boot Springs","description":"Give Eli a faster strafe and retreat pace."},
				{"id":"barn_batteries","name":"Barn Batteries","description":"Store extra charge in the shed. Gain 4 scrap and 1 base."},
				_path_upgrade_option_for_wave_four()
			]
		5:
			options = [
				{"id":"shock_braid","name":"Shock Braid","description":"Wrap the turret emitters. Turrets deal more damage."},
				{"id":"porch_reinforcement","name":"Porch Reinforcement","description":"Brace the front of the farmhouse. Base +3."},
				{"id":"windmill_dynamo","name":"Windmill Dynamo","description":"Push more current through the farm grid for faster shots."}
			]
		6:
			options = [
				{"id":"storm_dynamo","name":"Storm Dynamo","description":"Turn the whole defense grid up for the final rush."},
				{"id":"hotshot_feed","name":"Hotshot Feed","description":"Make Eli's weapon faster and meaner."},
				_path_upgrade_option_for_wave_six()
			]
	return options


func _path_upgrade_option_for_wave_four() -> Dictionary:
	match patch_path:
		PatchPath.SCRAP:
			return {"id":"smelter_sorter","name":"Smelter Sorter","description":"Patch marks the clean alloy. Gain 8 scrap and cheaper turrets."}
		PatchPath.GUARD:
			return {"id":"lane_whistle","name":"Lane Whistle","description":"Tune the defense line around Patch. Turrets hit harder and base +1."}
		PatchPath.SCOUT:
			return {"id":"survey_scope","name":"Survey Scope","description":"Patch leads Eli to a buried lens. Player damage up and turrets get cheaper."}
		_:
			return {"id":"coil_lattice","name":"Coil Lattice","description":"Rebalance the emitters. Turrets deal more damage."}


func _path_upgrade_option_for_wave_six() -> Dictionary:
	match patch_path:
		PatchPath.SCRAP:
			return {"id":"forge_crates","name":"Forge Crates","description":"Turn the salvage pile into a war reserve. Big scrap gain and stronger turrets."}
		PatchPath.GUARD:
			return {"id":"shock_harness","name":"Shock Harness","description":"Patch anchors the lane while Eli hardens the house and gun."}
		PatchPath.SCOUT:
			return {"id":"deepfield_map","name":"Deepfield Map","description":"Patch's last find reveals one more hidden cache under the field."}
		_:
			return {"id":"silo_cache","name":"Silo Cache","description":"Crack open the last barn stash. Gain scrap and more base strength."}


func _on_upgrade_selected(choice_index: int) -> void:
	if choice_index < 0 or choice_index >= pending_upgrade_choices.size():
		return

	var selected_option: Dictionary = pending_upgrade_choices[choice_index]
	var invention_text: String = _apply_invention_upgrade(String(selected_option["id"]))
	var transition_text := pending_transition_text
	if transition_text != "":
		transition_text += "\n\n"
	transition_text += "Eli invention: %s" % invention_text
	pending_upgrade_choices.clear()
	upgrade_panel.visible = false
	_show_briefing_for_wave(pending_upgrade_wave_index, transition_text)


func _apply_patch_rank(new_rank: int, announce_banner: bool = true) -> String:
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

	_update_hint()
	_update_stats()
	if announce_banner and upgrade_text != "":
		_set_banner(upgrade_text, 4.0)
	return upgrade_text


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
			turret_cost = maxi(4, BASE_TURRET_COST - 2)
			return "Patch uncovers buried coil plans in the field. Turrets now cost %d scrap." % turret_cost
		2:
			player_fire_interval = maxf(0.10, player_fire_interval - 0.03)
			if player != null and is_instance_valid(player):
				player.set_fire_interval(player_fire_interval)
			return "Patch finds an old capacitor cache. Eli can fire his homemade weapon faster."
		3:
			turret_damage += 1
			base_health += 2
			_refresh_turret_stats()
			return "Patch digs up a sealed alien lens. Turrets hit harder and the farmhouse gets reinforced."
		_:
			return ""


func _prepare_transition_for_wave(next_wave_number: int) -> String:
	var transition_text: String = _between_wave_text_for_wave(next_wave_number)
	var desired_rank: int = _desired_patch_rank_for_wave(next_wave_number)
	if patch_path != PatchPath.NONE and desired_rank > patch_rank:
		var upgrade_text: String = _apply_patch_rank(desired_rank, false)
		if transition_text != "":
			transition_text += "\n\n"
		transition_text += "Patch upgrade: %s" % upgrade_text
	return transition_text


func _apply_invention_upgrade(upgrade_id: String) -> String:
	match upgrade_id:
		"fence_crank_repeater":
			player_fire_interval = maxf(0.10, player_fire_interval - 0.02)
			player.set_fire_interval(player_fire_interval)
			return "Fence Crank Repeater online. Eli can cycle shots faster."
		"sheet_metal_siding":
			base_health += 2
			return "Sheet-Metal Siding installed. The farmhouse can take more punishment."
		"salvage_sled":
			scrap += 6
			return "Salvage Sled built. Eli drags 6 extra scrap into the barn."
		"capacitor_slugs":
			player_bullet_damage += 1
			return "Capacitor Slugs packed. Eli's shots now hit harder."
		"quick_weld_mounts":
			turret_fire_interval = maxf(0.48, turret_fire_interval - 0.10)
			_refresh_turret_stats()
			return "Quick-Weld Mounts fitted. Coil turrets cycle faster."
		"coil_molds":
			turret_cost = maxi(4, turret_cost - 1)
			return "Coil Molds finished. New turrets cost %d scrap." % turret_cost
		"boot_springs":
			player_move_speed += 24.0
			player.set_move_speed(player_move_speed)
			return "Boot Springs locked in. Eli moves faster between lanes."
		"barn_batteries":
			base_health += 1
			scrap += 4
			return "Barn Batteries charged. The house gains 1 base and Eli banks 4 scrap."
		"smelter_sorter":
			scrap += 8
			turret_cost = maxi(4, turret_cost - 1)
			return "Smelter Sorter running. Patch helps pull 8 scrap and turrets drop to %d." % turret_cost
		"lane_whistle":
			turret_damage += 1
			base_health += 1
			_refresh_turret_stats()
			return "Lane Whistle tuned. Turrets hit harder and the farmhouse gets 1 extra base."
		"survey_scope":
			player_bullet_damage += 1
			turret_cost = maxi(4, turret_cost - 1)
			return "Survey Scope mounted. Eli's shots hit harder and turrets now cost %d." % turret_cost
		"coil_lattice":
			turret_damage += 1
			_refresh_turret_stats()
			return "Coil Lattice finished. Turrets deal more damage."
		"shock_braid":
			turret_damage += 1
			_refresh_turret_stats()
			return "Shock Braid wrapped across the emitters. Turrets hit harder."
		"porch_reinforcement":
			base_health += 3
			return "Porch Reinforcement complete. The farmhouse gains 3 base."
		"windmill_dynamo":
			player_fire_interval = maxf(0.08, player_fire_interval - 0.015)
			turret_fire_interval = maxf(0.44, turret_fire_interval - 0.06)
			player.set_fire_interval(player_fire_interval)
			_refresh_turret_stats()
			return "Windmill Dynamo spins up the whole farm grid. Eli and the turrets fire faster."
		"storm_dynamo":
			turret_fire_interval = maxf(0.38, turret_fire_interval - 0.08)
			turret_damage += 1
			_refresh_turret_stats()
			return "Storm Dynamo armed. The final defense grid fires faster and harder."
		"hotshot_feed":
			player_fire_interval = maxf(0.08, player_fire_interval - 0.02)
			player_bullet_damage += 1
			player.set_fire_interval(player_fire_interval)
			return "Hotshot Feed loaded. Eli shoots faster and every round bites deeper."
		"forge_crates":
			scrap += 10
			turret_damage += 1
			_refresh_turret_stats()
			return "Forge Crates cracked open. Eli banks 10 scrap and the turret line gets meaner."
		"shock_harness":
			base_health += 2
			player_fire_interval = maxf(0.08, player_fire_interval - 0.02)
			player.set_fire_interval(player_fire_interval)
			return "Shock Harness rigged. Patch holds the lane while Eli gets faster and the house gains 2 base."
		"deepfield_map":
			scrap += 6
			player_bullet_damage += 1
			base_health += 1
			return "Deepfield Map decoded. Patch finds 6 scrap, Eli hits harder, and the house gains 1 base."
		"silo_cache":
			scrap += 6
			base_health += 2
			return "Silo Cache opened. Eli finds 6 scrap and braces the farmhouse for 2 more base."
		_:
			return "Eli scribbles a new plan, but it does not change the defense yet."


func _desired_patch_rank_for_wave(next_wave_number: int) -> int:
	if next_wave_number >= 6:
		return 3
	if next_wave_number >= 4:
		return 2
	if next_wave_number >= 2:
		return 1
	return 0


func _between_wave_text_for_wave(next_wave_number: int) -> String:
	match next_wave_number:
		2:
			return "Eli kicks apart the first saucer hulls, then crouches beside Patch to decide what the dog should become."
		3:
			return "The barn lights burn hot while Eli rewires farm junk into weapons. Out in the dark, the aliens start sending real drill teams."
		4:
			match patch_path:
				PatchPath.SCRAP:
					return "Patch starts dragging cleaner cores out of the wreck pile while the north field keeps pulsing under the dirt."
				PatchPath.GUARD:
					return "Patch keeps pacing the lane, waiting to cut off the next rush before it reaches the fence."
				PatchPath.SCOUT:
					return "Patch keeps circling one patch of trampled corn until Eli notices the field markers lining up like a map."
				_:
					return "Fresh crop circles point to something buried under the north field."
		5:
			return "A buried signal is fully awake now. The mothership starts vectoring heavier craft toward the farmhouse."
		6:
			match patch_path:
				PatchPath.SCRAP:
					return "The salvage pile behind the barn has become a real workshop, and Patch is still dragging in usable alloy."
				PatchPath.GUARD:
					return "Patch's bark rolls across the lane like thunder. Even the bigger saucers hesitate when he squares up."
				PatchPath.SCOUT:
					return "Patch digs up one last sealed cache near the tractor shed, and Eli folds it into the farm's last defenses."
				_:
					return "The silo throws long shadows over the field while the final rush lines up in the sky."
		_:
			return ""


func _refresh_turret_stats() -> void:
	for node in get_tree().get_nodes_in_group("turrets"):
		if node.has_method("set_stats"):
			node.set_stats(turret_fire_interval, turret_damage)


func _on_player_fired(origin: Vector2, direction: Vector2) -> void:
	if game_over or mission_complete:
		return

	var bullet: Area2D = BULLET_SCENE.instantiate() as Area2D
	bullet.global_position = origin
	bullet.configure(direction, 860.0, player_bullet_damage)
	add_child(bullet)


func _on_build_requested(spot) -> void:
	if game_over or mission_complete:
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

	active_aliens = maxi(0, active_aliens - 1)

	var total_scrap: int = scrap_value
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
	_check_wave_completion()


func _on_alien_drill_site_reached(progress_boost: float) -> void:
	if game_over:
		return

	active_aliens = maxi(0, active_aliens - 1)
	if _has_live_drill_site():
		current_drill_site.boost_progress(progress_boost)
		_set_banner("A driller fed the north-field rig.", 1.6)
	_update_stats()
	_check_wave_completion()


func _on_alien_farmhouse_hit(damage: int) -> void:
	if game_over:
		return

	active_aliens = maxi(0, active_aliens - 1)
	base_health -= damage
	if base_health <= 0:
		_trigger_game_over("The farmhouse is gone. Reset and hold the line again.")
	else:
		_set_banner("The farmhouse took a hit!", 1.4)
		_update_stats()
		_check_wave_completion()


func _on_drill_site_destroyed(scrap_value: int, _world_position: Vector2) -> void:
	if game_over:
		return

	active_aliens = maxi(0, active_aliens - 1)
	current_drill_site = null
	scrap += scrap_value
	_set_banner("North-field drill rig destroyed.", 2.0)
	_update_stats()
	_check_wave_completion()


func _on_drill_site_breached() -> void:
	if game_over:
		return

	active_aliens = maxi(0, active_aliens - 1)
	current_drill_site = null
	_trigger_game_over("North field breached. The aliens drilled into what was buried below.")


func _check_wave_completion() -> void:
	if not wave_active or game_over:
		return
	if wave_spawned < wave_total_spawns or active_aliens > 0:
		return

	wave_active = false
	spawn_timer.stop()
	current_objective_text = "Wave %d secure. Eli and Patch reset the fence line." % wave
	_update_hint()
	_update_stats()

	if current_wave_index == ACT_ONE_WAVES.size() - 1:
		_show_mission_complete()
		return

	if current_wave_index == 0 and patch_path == PatchPath.NONE:
		_show_patch_choice()
		return

	var next_wave_index: int = current_wave_index + 1
	var transition_text: String = _prepare_transition_for_wave(next_wave_index + 1)
	_show_briefing_for_wave(next_wave_index, transition_text)


func _show_mission_complete() -> void:
	mission_complete = true
	wave_active = false
	spawn_timer.stop()
	banner_timer.stop()
	current_objective_text = "Act 1 complete. Eli held the farm for one more night."
	banner_default = "Act 1 complete: Miller Farm survives the first assault."
	banner_label.text = banner_default
	briefing_title_label.text = "Act 1 Complete: The Farm Holds"
	briefing_body_label.text = "The last harvester wreck burns out beyond the silo. Eli and Patch keep the farmhouse standing, but the north field is still pulsing under the dirt.\n\n%s" % _mission_outro_for_patch()
	briefing_footer_label.text = "Act 2 can grow from here. For now, this run ends with the farm still standing."
	briefing_continue_button.text = "Restart Act 1"
	briefing_panel.visible = true
	upgrade_panel.visible = false
	patch_panel.visible = false
	get_tree().paused = true
	_update_hint()
	_update_stats()


func _mission_outro_for_patch() -> String:
	match patch_path:
		PatchPath.SCRAP:
			return "Patch's salvage trail has already turned the barn into a rough little war shop."
		PatchPath.GUARD:
			return "Patch owns the lane now, and the aliens have started learning to fear the bark before the bite."
		PatchPath.SCOUT:
			return "Patch has proven the field is hiding more than crop circles, and Eli finally knows where to dig next."
		_:
			return "Patch fought as hard as Eli did, even before the farm figured out what role he should grow into."


func _trigger_game_over(reason: String) -> void:
	game_over = true
	wave_active = false
	base_health = 0
	spawn_timer.stop()
	banner_timer.stop()
	briefing_panel.visible = false
	upgrade_panel.visible = false
	if patch_panel.visible:
		patch_panel.visible = false
	get_tree().paused = false
	banner_default = "Farm overrun. Press R to restart the defense."
	banner_label.text = banner_default
	current_objective_text = reason
	_update_hint()
	_update_stats()


func _set_banner(text: String, duration: float = 2.0) -> void:
	banner_label.text = text
	if duration > 0.0:
		banner_timer.start(duration)


func _restore_banner() -> void:
	banner_label.text = banner_default


func _update_stats() -> void:
	var threats_remaining: int = _threats_remaining()
	stats_label.text = "Scrap %02d  Base %02d  Wave %02d/%02d  Threat %02d  Kills %02d  Patch %s" % [scrap, base_health, maxi(1, wave), ACT_ONE_WAVES.size(), threats_remaining, kills, _patch_summary()]


func _threats_remaining() -> int:
	if not wave_active:
		return 0
	return active_aliens + maxi(0, wave_total_spawns - wave_spawned)


func _update_hint() -> void:
	if mission_complete:
		hint_label.text = "Act 1 complete. Press R or use the panel to restart the defense."
		return

	if game_over:
		hint_label.text = "Restart with R, then get Eli and Patch back on the fence line."
		return

	hint_label.text = "Objective: %s   WASD/Arrows Move   Mouse/Space Fire   Click Pad Build (%d)   R Restart" % [current_objective_text, turret_cost]


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
					return "Wave 2: Patch starts pulling clean alloy while the first driller brute hits the fence."
				PatchPath.GUARD:
					return "Wave 2: Patch locks onto the fence line as the first driller brute lumbers in."
				PatchPath.SCOUT:
					return "Wave 2: Patch starts sniffing around the north field markers while a driller brute tests the lane."
				_:
					return "Wave 2: Eli decides what kind of war dog Patch needs to become."
		3:
			return "Wave 3: The first north-field drill rig locks into the soil."
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
					return "Wave 6: Patch turns up sealed alien gear while the command rig drills for the signal."
				PatchPath.SCRAP:
					return "Wave 6: The salvage pile grows into a full workshop as the command rig bores into the field."
				PatchPath.GUARD:
					return "Wave 6: Patch's bark rolls across the farm while the command rig pounds the field."
				_:
					return "Wave 6: A command rig hammers the field while Eli turns the tractor shed into a war workshop."
		_:
			return "The field stays loud with engines and falling metal."


func _unhandled_input(event: InputEvent) -> void:
	if (game_over or mission_complete) and event.is_action_pressed("restart"):
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
