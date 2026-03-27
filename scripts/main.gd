extends Node2D

enum PatchPath {
	NONE,
	SCRAP,
	GUARD,
	SCOUT,
}

enum ControlMode {
	AUTO,
	DESKTOP,
	TOUCH,
}

const WORLD_SIZE := Vector2(1280.0, 720.0)
const PLAY_BOUNDS_MARGIN_X := 70.0
const PLAY_BOUNDS_TOP := 250.0
const PLAY_BOUNDS_BOTTOM_MARGIN := 74.0
const FARMHOUSE_POS := Vector2(640.0, 610.0)
const DRILL_SITE_POS := Vector2(640.0, 386.0)
const BASE_TURRET_COST := 8
const FARM_STRUCTURE_ORDER := ["barn", "power_shed", "silo"]
const FARM_STRUCTURE_REPAIR_PRIORITY := ["power_shed", "silo", "barn"]
const FARM_STRUCTURE_DEFS := {
	"barn": {"name":"Barn", "type":"barn", "position":Vector2(236.0, 542.0), "health":8},
	"power_shed": {"name":"Power Shed", "type":"power_shed", "position":Vector2(938.0, 602.0), "health":6},
	"silo": {"name":"Silo", "type":"silo", "position":Vector2(1054.0, 470.0), "health":9},
}
const BARN_SURVIVAL_BONUS := 2
const POWER_SHED_FIRE_PENALTY := 1.30
const SILO_DAMAGE_PENALTY := 1
const _WaveData = preload("res://scripts/wave_data.gd")
const ACT_ONE_WAVES = _WaveData.ACT_ONE_WAVES


const PLAYER_SCENE := preload("res://scenes/player.tscn")
const DOG_SCENE := preload("res://scenes/dog.tscn")
const ALIEN_SCENE := preload("res://scenes/alien.tscn")
const FARM_STRUCTURE_SCENE := preload("res://scenes/farm_structure.tscn")
const DRILL_RIG_SCENE := preload("res://scenes/drill_rig.tscn")
const SIGNAL_RELAY_SCENE := preload("res://scenes/signal_relay.tscn")
const ACT2_OBJECTIVE_SCENE := preload("res://scenes/act2_objective.tscn")
const BOSS_OVERSEER_SCENE := preload("res://scenes/boss_overseer.tscn")
const FIELD_SIGNAL_SCENE := preload("res://scenes/field_signal.tscn")
const ROCKET_TRACTOR_SCENE := preload("res://scenes/rocket_tractor.tscn")
const BULLET_SCENE := preload("res://scenes/bullet.tscn")
const DEATH_BURST_SCENE := preload("res://scenes/death_burst.tscn")
const ENEMY_BOLT_SCENE := preload("res://scenes/enemy_bolt.tscn")
const TURRET_SCENE := preload("res://scenes/turret.tscn")
const SHOCK_POST_SCENE := preload("res://scenes/shock_post.tscn")
const BARRICADE_SCENE := preload("res://scenes/barricade.tscn")
const BUILD_SPOT_SCENE := preload("res://scenes/build_spot.tscn")
const SCOUT_CACHE_SCENE := preload("res://scenes/scout_cache.tscn")
const DAMAGE_NUMBER_SCENE := preload("res://scenes/damage_number.tscn")
const AUDIO_MANAGER_SCENE := preload("res://scripts/audio_manager.gd")
const MUSIC_FARM_DEFENSE_LOOP := preload("res://assets/audio/music/music_farm_defense_loop.ogg")
const MUSIC_WAVE_WARNING_STING := preload("res://assets/audio/music/music_wave_warning_sting.ogg")
const SFX_WEAPON_LASER_PEW := preload("res://assets/audio/sfx/sfx_weapon_laser_pew.wav")
const SFX_WEAPON_HEAVY_BLAST := preload("res://assets/audio/sfx/sfx_weapon_heavy_blast.wav")
const SFX_WEAPON_ROCKET_LAUNCH := preload("res://assets/audio/sfx/sfx_weapon_rocket_launch.wav")
const SFX_DOG_BARK_ALERT := preload("res://assets/audio/sfx/sfx_dog_bark_alert.wav")
const SFX_DOG_GROWL_GUARD := preload("res://assets/audio/sfx/sfx_dog_growl_guard.wav")
const SFX_ALIEN_CHITTER_IDLE := preload("res://assets/audio/sfx/sfx_alien_chitter_idle.wav")
const SFX_ALIEN_HURT := preload("res://assets/audio/sfx/sfx_alien_hurt.wav")
const SFX_ALIEN_DEATH := preload("res://assets/audio/sfx/sfx_alien_death.wav")
const SFX_ALIEN_BRUTE_ROAR := preload("res://assets/audio/sfx/sfx_alien_brute_roar.wav")
const WEAPON_NAILGUN := "nailgun"
const WEAPON_SCRAP_BLASTER := "scrap_blaster"
const WEAPON_TRACTOR_CANNON := "tractor_cannon"
const BUILD_COIL_TURRET := "coil_turret"
const BUILD_SHOCK_POST := "shock_post"
const BUILD_BARRICADE := "barricade"
const SCRAP_BLASTER_PELLET_COUNT := 5
const SCRAP_BLASTER_SPREAD := 0.30
const NAILGUN_FALLOFF_START := 150.0
const NAILGUN_FALLOFF_END := 350.0
const MUSIC_LOOP_BASE_DB := -14.0
const MUSIC_STING_BASE_DB := -9.0
const TOUCH_PAD_SIZE := Vector2(156.0, 156.0)
const TOUCH_KNOB_SIZE := Vector2(62.0, 62.0)
const TOUCH_PAD_RADIUS := 54.0

var player: CharacterBody2D
var dog: CharacterBody2D
var current_drill_site: StaticBody2D
var current_signal_relay: StaticBody2D
var current_act_two_objectives: Array[StaticBody2D] = []
var current_wave_boss: CharacterBody2D
var field_signal: Node2D
var rocket_tractor
var top_panel: ColorRect
var bottom_panel: ColorRect
var stats_label: Label
var farm_status_label: Label
var banner_label: Label
var hint_label: Label
var title_panel: PanelContainer
var title_title_label: Label
var title_body_label: Label
var title_footer_label: Label
var title_auto_button: Button
var title_desktop_button: Button
var title_touch_button: Button
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
var pause_panel: PanelContainer
var pause_title_label: Label
var pause_body_label: Label
var pause_footer_label: Label
var pause_resume_button: Button
var pause_restart_button: Button
var pause_auto_button: Button
var pause_desktop_button: Button
var pause_touch_button: Button
var pause_music_slider: HSlider
var pause_music_value_label: Label
var pause_sfx_slider: HSlider
var pause_sfx_value_label: Label
var prep_panel: PanelContainer
var prep_title_label: Label
var prep_body_label: Label
var prep_footer_label: Label
var prep_start_button: Button
var touch_hud_root: Control
var touch_move_base: ColorRect
var touch_move_knob: ColorRect
var touch_aim_base: ColorRect
var touch_aim_knob: ColorRect
var touch_pause_button: Button
var touch_swap_button: Button
var touch_coil_button: Button
var touch_shock_button: Button
var touch_fence_button: Button
var spawn_timer: Timer
var banner_timer: Timer
var music_player: AudioStreamPlayer
var music_sting_player: AudioStreamPlayer
var audio_started := false
var settings_menu_open := false
var prep_phase_active := false
var music_volume_level := 1.0
var sfx_volume_level := 1.0
var pause_restore_banner := ""
var pause_restore_objective := ""

var control_mode_preference := ControlMode.AUTO
var auto_touch_detected := false
var touch_controls_active := false
var touch_move_touch_id := -1
var touch_aim_touch_id := -1
var touch_move_knob_offset := Vector2.ZERO
var touch_aim_vector := Vector2.RIGHT
var touch_aim_knob_offset := Vector2.ZERO
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
var current_weapon_id := WEAPON_NAILGUN
var scrap_blaster_unlocked := false
var scrap_blaster_fire_interval := 0.54
var tractor_cannon_unlocked := false
var tractor_cannon_fire_interval := 0.74
var rocket_tractor_unlocked := false
var rocket_tractor_patrol_speed := 84.0
var rocket_tractor_fire_interval := 2.8
var rocket_tractor_damage := 5
var rocket_tractor_rocket_speed := 470.0
var turret_damage := 1
var turret_fire_interval := 0.80
var turret_cost := BASE_TURRET_COST
var selected_build_type := BUILD_COIL_TURRET
var shock_post_unlocked := false
var shock_post_cost := 10
var shock_post_damage := 1
var shock_post_fire_interval := 1.25
var shock_post_stun_duration := 0.55
var barricade_unlocked := false
var barricade_cost := 6
var barricade_health := 6
var current_objective_text := "Review Eli's first defense plan."
var base_wave_objective_text := "Review Eli's first defense plan."
var farm_structures := {}
var current_wave_index := -1
var pending_wave_index := -1
var wave_total_spawns := 0
var wave_spawned := 0
var active_aliens := 0
var wave_drillers_remaining := 0
var wave_harriers_remaining := 0
var wave_shields_remaining := 0
var wave_burrowers_remaining := 0
var current_wave_spawn_interval := 1.50
var current_wave_start_delay := 0.80
var current_wave_spawn_mode := "mixed"
var relay_spawned_for_wave := false
var boss_spawned_for_wave := false
var boss_target_cycle := 0
var shield_warning_sent := false
var burrower_warning_sent := false
var driller_warning_sent := false
var harrier_warning_sent := false
var structure_raid_pool: Array[String] = []
var structure_raid_notice_sent := false
var pending_upgrade_choices: Array[Dictionary] = []
var pending_upgrade_wave_index := -1
var pending_transition_text := ""
var wave_clear_pending := false
var wave_clear_farm_text := ""

# Audio manager
var audio_manager: Node

# Group cache
var cached_aliens: Array[Node] = []
var cached_barricades: Array[Node] = []
var _aliens_dirty := true
var _barricades_dirty := true

# Farm penalty visual state
var power_penalty_visual_active := false
var silo_penalty_visual_active := false
var penalty_pulse_time := 0.0

# Scout cache
var active_scout_caches: Array[Node2D] = []

# Act 2 expansion
var excavation_depth := 0.0
const EXCAVATION_MAX := 100.0
var dawn_progress := 0.0

# Screen shake
var shake_intensity := 0.0
var shake_decay := 8.0

# Combo kill streak
var combo_count := 0
var combo_timer := 0.0
const COMBO_WINDOW := 2.0


func _ready() -> void:
	randomize()
	audio_manager = AUDIO_MANAGER_SCENE.new()
	add_child(audio_manager)
	_setup_ui()
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_setup_timers()
	_setup_audio()
	_spawn_player()
	_spawn_dog()
	_spawn_field_signal()
	_spawn_farm_structures()
	_spawn_build_spots()
	_layout_ui()
	_update_hint()
	_update_stats()
	_show_title_screen()
	queue_redraw()


func _physics_process(delta: float) -> void:
	if _aliens_dirty:
		cached_aliens = get_tree().get_nodes_in_group("aliens")
		_aliens_dirty = false
	if _barricades_dirty:
		cached_barricades = get_tree().get_nodes_in_group("barricades")
		_barricades_dirty = false
	penalty_pulse_time += delta
	if wave_active and _act_two_active() and current_wave_index == ACT_ONE_WAVES.size() - 1:
		dawn_progress = minf(1.0, dawn_progress + delta * 0.012)
		queue_redraw()
	if shake_intensity > 0.01:
		shake_intensity = maxf(0.0, shake_intensity - shake_decay * delta)
		position = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
	elif position != Vector2.ZERO:
		position = Vector2.ZERO
	if combo_timer > 0.0:
		combo_timer = maxf(0.0, combo_timer - delta)
		if combo_timer <= 0.0 and combo_count >= 3:
			_set_banner("Streak ended at %d kills." % combo_count, 1.5)
			combo_count = 0
		elif combo_timer <= 0.0:
			combo_count = 0
	if wave_active and audio_manager != null:
		audio_manager.set_combat_intensity(_live_threat_count(), wave_total_spawns)


func get_cached_aliens() -> Array[Node]:
	return cached_aliens


func get_cached_barricades() -> Array[Node]:
	return cached_barricades


func mark_aliens_dirty() -> void:
	_aliens_dirty = true


func mark_barricades_dirty() -> void:
	_barricades_dirty = true


func _setup_ui() -> void:
	var canvas_layer: CanvasLayer = CanvasLayer.new()
	add_child(canvas_layer)

	top_panel = ColorRect.new()
	top_panel.position = Vector2(0.0, 0.0)
	top_panel.size = Vector2(WORLD_SIZE.x, 72.0)
	top_panel.color = Color(0.10, 0.16, 0.11, 0.84)
	top_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas_layer.add_child(top_panel)

	stats_label = Label.new()
	stats_label.position = Vector2(18.0, 10.0)
	stats_label.size = Vector2(820.0, 22.0)
	stats_label.modulate = Color8(240, 236, 214)
	top_panel.add_child(stats_label)

	farm_status_label = Label.new()
	farm_status_label.position = Vector2(18.0, 38.0)
	farm_status_label.size = Vector2(820.0, 22.0)
	farm_status_label.modulate = Color8(190, 214, 191)
	top_panel.add_child(farm_status_label)

	banner_label = Label.new()
	banner_label.position = Vector2(852.0, 22.0)
	banner_label.size = Vector2(388.0, 24.0)
	banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	banner_label.modulate = Color8(255, 203, 120)
	top_panel.add_child(banner_label)

	bottom_panel = ColorRect.new()
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

	_setup_title_panel(canvas_layer)
	_setup_briefing_panel(canvas_layer)
	_setup_upgrade_panel(canvas_layer)
	_setup_patch_panel(canvas_layer)
	_setup_pause_panel(canvas_layer)
	_setup_prep_panel(canvas_layer)
	_setup_touch_hud(canvas_layer)


func _setup_title_panel(canvas_layer: CanvasLayer) -> void:
	title_panel = PanelContainer.new()
	title_panel.position = Vector2(196.0, 106.0)
	title_panel.size = Vector2(888.0, 402.0)
	title_panel.visible = false
	title_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	title_panel.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	canvas_layer.add_child(title_panel)

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
	title_panel.add_theme_stylebox_override("panel", panel_style)

	var content: VBoxContainer = VBoxContainer.new()
	content.position = Vector2(28.0, 24.0)
	content.size = Vector2(832.0, 346.0)
	content.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	content.add_theme_constant_override("separation", 14)
	title_panel.add_child(content)

	title_title_label = Label.new()
	title_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_title_label.modulate = Color8(255, 222, 165)
	content.add_child(title_title_label)

	title_body_label = Label.new()
	title_body_label.size = Vector2(832.0, 168.0)
	title_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_body_label.modulate = Color8(239, 232, 213)
	content.add_child(title_body_label)

	var buttons_col: VBoxContainer = VBoxContainer.new()
	buttons_col.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	buttons_col.add_theme_constant_override("separation", 8)
	content.add_child(buttons_col)

	title_auto_button = Button.new()
	title_auto_button.text = "Auto — desktop by default, switches to touch on screen tap"
	title_auto_button.custom_minimum_size = Vector2(0.0, 48.0)
	title_auto_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_auto_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	title_auto_button.pressed.connect(_on_control_mode_selected.bind(ControlMode.AUTO))
	buttons_col.add_child(title_auto_button)

	title_desktop_button = Button.new()
	title_desktop_button.text = "Desktop — keyboard movement, mouse aim"
	title_desktop_button.custom_minimum_size = Vector2(0.0, 48.0)
	title_desktop_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_desktop_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	title_desktop_button.pressed.connect(_on_control_mode_selected.bind(ControlMode.DESKTOP))
	buttons_col.add_child(title_desktop_button)

	title_touch_button = Button.new()
	title_touch_button.text = "Touch — on-screen pads for phones and tablets"
	title_touch_button.custom_minimum_size = Vector2(0.0, 48.0)
	title_touch_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_touch_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	title_touch_button.pressed.connect(_on_control_mode_selected.bind(ControlMode.TOUCH))
	buttons_col.add_child(title_touch_button)

	title_footer_label = Label.new()
	title_footer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_footer_label.modulate = Color8(191, 198, 207)
	content.add_child(title_footer_label)


func _setup_briefing_panel(canvas_layer: CanvasLayer) -> void:
	briefing_panel = PanelContainer.new()
	briefing_panel.position = Vector2(214.0, 40.0)
	briefing_panel.size = Vector2(852.0, 640.0)
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

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(8.0, 8.0)
	scroll.size = Vector2(836.0, 624.0)
	scroll.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	briefing_panel.add_child(scroll)

	var content: VBoxContainer = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	content.add_theme_constant_override("separation", 10)
	scroll.add_child(content)

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
	upgrade_panel.position = Vector2(208.0, 56.0)
	upgrade_panel.size = Vector2(864.0, 608.0)
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

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(8.0, 8.0)
	scroll.size = Vector2(848.0, 592.0)
	scroll.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	upgrade_panel.add_child(scroll)

	var content: VBoxContainer = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	content.add_theme_constant_override("separation", 10)
	scroll.add_child(content)

	upgrade_title_label = Label.new()
	upgrade_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	upgrade_title_label.modulate = Color8(255, 222, 165)
	content.add_child(upgrade_title_label)

	upgrade_body_label = Label.new()
	upgrade_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	upgrade_body_label.modulate = Color8(239, 232, 213)
	content.add_child(upgrade_body_label)

	upgrade_button_a = Button.new()
	upgrade_button_a.custom_minimum_size = Vector2(0.0, 64.0)
	upgrade_button_a.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	upgrade_button_a.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	upgrade_button_a.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	upgrade_button_a.pressed.connect(_on_upgrade_selected.bind(0))
	content.add_child(upgrade_button_a)

	upgrade_button_b = Button.new()
	upgrade_button_b.custom_minimum_size = Vector2(0.0, 64.0)
	upgrade_button_b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	upgrade_button_b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	upgrade_button_b.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	upgrade_button_b.pressed.connect(_on_upgrade_selected.bind(1))
	content.add_child(upgrade_button_b)

	upgrade_button_c = Button.new()
	upgrade_button_c.custom_minimum_size = Vector2(0.0, 64.0)
	upgrade_button_c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	upgrade_button_c.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	upgrade_button_c.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	upgrade_button_c.pressed.connect(_on_upgrade_selected.bind(2))
	content.add_child(upgrade_button_c)

	upgrade_footer_label = Label.new()
	upgrade_footer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	upgrade_footer_label.modulate = Color8(191, 198, 207)
	upgrade_footer_label.text = "Choose one invention. The others stay sketches on the workbench."
	content.add_child(upgrade_footer_label)


func _setup_patch_panel(canvas_layer: CanvasLayer) -> void:
	patch_panel = PanelContainer.new()
	patch_panel.position = Vector2(232.0, 40.0)
	patch_panel.size = Vector2(816.0, 640.0)
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

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(8.0, 8.0)
	scroll.size = Vector2(800.0, 624.0)
	scroll.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	patch_panel.add_child(scroll)

	var content: VBoxContainer = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	content.add_theme_constant_override("separation", 10)
	scroll.add_child(content)

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

	var buttons_col: VBoxContainer = VBoxContainer.new()
	buttons_col.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	buttons_col.add_theme_constant_override("separation", 8)
	content.add_child(buttons_col)

	patch_scrap_button = Button.new()
	patch_scrap_button.text = "Scrap Hound — better salvage and stronger scrap economy"
	patch_scrap_button.custom_minimum_size = Vector2(0.0, 44.0)
	patch_scrap_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	patch_scrap_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	patch_scrap_button.pressed.connect(_on_patch_path_selected.bind(PatchPath.SCRAP))
	buttons_col.add_child(patch_scrap_button)

	patch_guard_button = Button.new()
	patch_guard_button.text = "Guard Dog — stun bark and stronger lane control"
	patch_guard_button.custom_minimum_size = Vector2(0.0, 44.0)
	patch_guard_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	patch_guard_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	patch_guard_button.pressed.connect(_on_patch_path_selected.bind(PatchPath.GUARD))
	buttons_col.add_child(patch_guard_button)

	patch_scout_button = Button.new()
	patch_scout_button.text = "Scout Nose — find buried caches and hidden upgrades"
	patch_scout_button.custom_minimum_size = Vector2(0.0, 44.0)
	patch_scout_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	patch_scout_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	patch_scout_button.pressed.connect(_on_patch_path_selected.bind(PatchPath.SCOUT))
	buttons_col.add_child(patch_scout_button)

	patch_footer_label = Label.new()
	patch_footer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	patch_footer_label.modulate = Color8(191, 198, 207)
	patch_footer_label.text = "Patch earns deeper upgrades before waves 4 and 6."
	content.add_child(patch_footer_label)


func _setup_pause_panel(canvas_layer: CanvasLayer) -> void:
	pause_panel = PanelContainer.new()
	pause_panel.position = Vector2(220.0, 96.0)
	pause_panel.size = Vector2(840.0, 436.0)
	pause_panel.visible = false
	pause_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_panel.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	canvas_layer.add_child(pause_panel)

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
	pause_panel.add_theme_stylebox_override("panel", panel_style)

	var content: VBoxContainer = VBoxContainer.new()
	content.position = Vector2(24.0, 20.0)
	content.size = Vector2(792.0, 392.0)
	content.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	content.add_theme_constant_override("separation", 10)
	pause_panel.add_child(content)

	pause_title_label = Label.new()
	pause_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_title_label.modulate = Color8(255, 222, 165)
	pause_title_label.text = "Pause / Field Settings"
	content.add_child(pause_title_label)

	pause_body_label = Label.new()
	pause_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pause_body_label.size = Vector2(792.0, 68.0)
	pause_body_label.modulate = Color8(239, 232, 213)
	pause_body_label.text = "Pause the run, change control mode, or rebalance the mix without leaving the defense."
	content.add_child(pause_body_label)

	var action_row: HBoxContainer = HBoxContainer.new()
	action_row.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	action_row.add_theme_constant_override("separation", 14)
	content.add_child(action_row)

	pause_resume_button = Button.new()
	pause_resume_button.custom_minimum_size = Vector2(240.0, 48.0)
	pause_resume_button.text = "Resume Defense"
	pause_resume_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	pause_resume_button.pressed.connect(_on_pause_resume_pressed)
	action_row.add_child(pause_resume_button)

	pause_restart_button = Button.new()
	pause_restart_button.custom_minimum_size = Vector2(240.0, 48.0)
	pause_restart_button.text = "Restart Campaign"
	pause_restart_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	pause_restart_button.pressed.connect(_on_pause_restart_pressed)
	action_row.add_child(pause_restart_button)

	var controls_title: Label = Label.new()
	controls_title.text = "Controls"
	controls_title.modulate = Color8(216, 204, 177)
	content.add_child(controls_title)

	var controls_row: HBoxContainer = HBoxContainer.new()
	controls_row.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	controls_row.add_theme_constant_override("separation", 12)
	content.add_child(controls_row)

	pause_auto_button = Button.new()
	pause_auto_button.custom_minimum_size = Vector2(184.0, 44.0)
	pause_auto_button.text = "Auto"
	pause_auto_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	pause_auto_button.pressed.connect(_on_pause_control_mode_pressed.bind(ControlMode.AUTO))
	controls_row.add_child(pause_auto_button)

	pause_desktop_button = Button.new()
	pause_desktop_button.custom_minimum_size = Vector2(184.0, 44.0)
	pause_desktop_button.text = "Desktop"
	pause_desktop_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	pause_desktop_button.pressed.connect(_on_pause_control_mode_pressed.bind(ControlMode.DESKTOP))
	controls_row.add_child(pause_desktop_button)

	pause_touch_button = Button.new()
	pause_touch_button.custom_minimum_size = Vector2(184.0, 44.0)
	pause_touch_button.text = "Touch"
	pause_touch_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	pause_touch_button.pressed.connect(_on_pause_control_mode_pressed.bind(ControlMode.TOUCH))
	controls_row.add_child(pause_touch_button)

	var audio_title: Label = Label.new()
	audio_title.text = "Audio"
	audio_title.modulate = Color8(216, 204, 177)
	content.add_child(audio_title)

	content.add_child(_make_pause_slider_row("Music", "pause_music"))
	content.add_child(_make_pause_slider_row("SFX", "pause_sfx"))

	pause_footer_label = Label.new()
	pause_footer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_footer_label.modulate = Color8(191, 198, 207)
	pause_footer_label.text = "Esc opens this menu on desktop. The pause button does the same on touch."
	content.add_child(pause_footer_label)

	_refresh_pause_panel()


func _setup_prep_panel(canvas_layer: CanvasLayer) -> void:
	prep_panel = PanelContainer.new()
	prep_panel.position = Vector2(260.0, 92.0)
	prep_panel.size = Vector2(760.0, 176.0)
	prep_panel.visible = false
	prep_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	canvas_layer.add_child(prep_panel)

	var panel_style: StyleBoxFlat = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.12, 0.10, 0.08, 0.94)
	panel_style.border_color = Color8(245, 204, 124)
	panel_style.border_width_left = 3
	panel_style.border_width_top = 3
	panel_style.border_width_right = 3
	panel_style.border_width_bottom = 3
	panel_style.corner_radius_top_left = 12
	panel_style.corner_radius_top_right = 12
	panel_style.corner_radius_bottom_left = 12
	panel_style.corner_radius_bottom_right = 12
	prep_panel.add_theme_stylebox_override("panel", panel_style)

	var content: VBoxContainer = VBoxContainer.new()
	content.position = Vector2(22.0, 18.0)
	content.size = Vector2(716.0, 140.0)
	content.add_theme_constant_override("separation", 10)
	prep_panel.add_child(content)

	prep_title_label = Label.new()
	prep_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prep_title_label.modulate = Color8(255, 222, 165)
	content.add_child(prep_title_label)

	prep_body_label = Label.new()
	prep_body_label.size = Vector2(716.0, 54.0)
	prep_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prep_body_label.modulate = Color8(239, 232, 213)
	content.add_child(prep_body_label)

	prep_start_button = Button.new()
	prep_start_button.custom_minimum_size = Vector2(240.0, 46.0)
	prep_start_button.text = "Start Wave"
	prep_start_button.pressed.connect(_on_prep_start_pressed)
	content.add_child(prep_start_button)

	prep_footer_label = Label.new()
	prep_footer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prep_footer_label.modulate = Color8(191, 198, 207)
	content.add_child(prep_footer_label)


func _make_pause_slider_row(label_text: String, slider_kind: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	row.add_theme_constant_override("separation", 12)

	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(92.0, 28.0)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.modulate = Color8(239, 232, 213)
	row.add_child(label)

	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 100.0
	slider.step = 1.0
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	row.add_child(slider)

	var value_label := Label.new()
	value_label.custom_minimum_size = Vector2(70.0, 28.0)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	value_label.modulate = Color8(215, 218, 223)
	row.add_child(value_label)

	if slider_kind == "pause_music":
		pause_music_slider = slider
		pause_music_value_label = value_label
		pause_music_slider.value_changed.connect(_on_pause_music_slider_changed)
	else:
		pause_sfx_slider = slider
		pause_sfx_value_label = value_label
		pause_sfx_slider.value_changed.connect(_on_pause_sfx_slider_changed)

	return row


func _setup_touch_hud(canvas_layer: CanvasLayer) -> void:
	touch_hud_root = Control.new()
	touch_hud_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	touch_hud_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	touch_hud_root.visible = false
	canvas_layer.add_child(touch_hud_root)

	touch_move_base = ColorRect.new()
	touch_move_base.position = Vector2(26.0, 488.0)
	touch_move_base.size = TOUCH_PAD_SIZE
	touch_move_base.color = Color(0.16, 0.20, 0.24, 0.28)
	touch_move_base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	touch_hud_root.add_child(touch_move_base)

	var move_label: Label = Label.new()
	move_label.text = "MOVE"
	move_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	move_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	move_label.size = TOUCH_PAD_SIZE
	move_label.modulate = Color8(223, 232, 241)
	move_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	touch_move_base.add_child(move_label)

	touch_move_knob = ColorRect.new()
	touch_move_knob.size = TOUCH_KNOB_SIZE
	touch_move_knob.color = Color(0.88, 0.92, 0.98, 0.42)
	touch_move_knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	touch_move_base.add_child(touch_move_knob)

	touch_aim_base = ColorRect.new()
	touch_aim_base.position = Vector2(WORLD_SIZE.x - TOUCH_PAD_SIZE.x - 26.0, 488.0)
	touch_aim_base.size = TOUCH_PAD_SIZE
	touch_aim_base.color = Color(0.30, 0.16, 0.14, 0.30)
	touch_aim_base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	touch_hud_root.add_child(touch_aim_base)

	var aim_label: Label = Label.new()
	aim_label.text = "AIM / FIRE"
	aim_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	aim_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	aim_label.size = TOUCH_PAD_SIZE
	aim_label.modulate = Color8(252, 227, 213)
	aim_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	touch_aim_base.add_child(aim_label)

	touch_aim_knob = ColorRect.new()
	touch_aim_knob.size = TOUCH_KNOB_SIZE
	touch_aim_knob.color = Color(1.0, 0.90, 0.84, 0.44)
	touch_aim_knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	touch_aim_base.add_child(touch_aim_knob)

	touch_coil_button = _make_touch_action_button("Coil", Vector2(1114.0, 118.0))
	touch_coil_button.pressed.connect(_on_touch_build_button_pressed.bind(BUILD_COIL_TURRET))
	touch_hud_root.add_child(touch_coil_button)

	touch_shock_button = _make_touch_action_button("Shock", Vector2(1114.0, 176.0))
	touch_shock_button.pressed.connect(_on_touch_build_button_pressed.bind(BUILD_SHOCK_POST))
	touch_hud_root.add_child(touch_shock_button)

	touch_fence_button = _make_touch_action_button("Fence", Vector2(1114.0, 234.0))
	touch_fence_button.pressed.connect(_on_touch_build_button_pressed.bind(BUILD_BARRICADE))
	touch_hud_root.add_child(touch_fence_button)

	touch_swap_button = _make_touch_action_button("Weapon", Vector2(1114.0, 292.0), Vector2(140.0, 58.0))
	touch_swap_button.pressed.connect(_on_touch_swap_button_pressed)
	touch_hud_root.add_child(touch_swap_button)

	touch_pause_button = _make_touch_action_button("Pause", Vector2(1114.0, 356.0), Vector2(140.0, 52.0))
	touch_pause_button.pressed.connect(_on_touch_pause_button_pressed)
	touch_hud_root.add_child(touch_pause_button)

	_update_touch_pad_visuals()


func _make_touch_action_button(button_text: String, button_position: Vector2, button_size: Vector2 = Vector2(140.0, 52.0)) -> Button:
	var button := Button.new()
	button.position = button_position
	button.size = button_size
	button.text = button_text
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	return button


func _show_title_screen() -> void:
	settings_menu_open = false
	prep_phase_active = false
	current_objective_text = "Choose how to control Eli's defense."
	banner_default = "Miller Farm: set the controls before the first landing."
	title_title_label.text = "ALIEN INVADERS"
	title_body_label.text = "Pick how Eli handles the farm before the first wave.\n\nAuto keeps desktop controls by default and switches to touch if the run sees screen touches. Touch mode puts a movement pad, an aim-and-fire pad, and build buttons directly on the screen for phones and tablets."
	title_footer_label.text = "Desktop is best for keyboard and mouse. Touch is best for phones. Auto is the safest web default."
	title_panel.visible = true
	prep_panel.visible = false
	briefing_panel.visible = false
	upgrade_panel.visible = false
	patch_panel.visible = false
	pause_panel.visible = false
	get_tree().paused = true
	banner_label.text = banner_default
	_apply_control_mode()
	_refresh_support_units()
	queue_redraw()
	_update_hint()
	_update_stats()


func _on_control_mode_selected(selected_mode: int) -> void:
	_ensure_audio_started()
	control_mode_preference = selected_mode
	if selected_mode == ControlMode.DESKTOP:
		auto_touch_detected = false
	elif selected_mode == ControlMode.TOUCH:
		auto_touch_detected = true
	_apply_control_mode()
	title_panel.visible = false
	_show_briefing_for_wave(0, _control_mode_transition_text())


func _control_mode_transition_text() -> String:
	match control_mode_preference:
		ControlMode.DESKTOP:
			return "Control mode: Desktop. Eli uses keyboard movement, mouse aim, and keyboard build hotkeys."
		ControlMode.TOUCH:
			return "Control mode: Touch. Use the left pad to move, the right pad to aim and fire, and the on-screen buttons to swap weapons or pick builds."
		_:
			if touch_controls_active:
				return "Control mode: Auto. Touch input was detected, so the mobile HUD is live for this run."
			return "Control mode: Auto. Desktop controls stay live until the game sees a screen touch, then the touch HUD appears."


func _apply_control_mode() -> void:
	var should_use_touch := control_mode_preference == ControlMode.TOUCH or (control_mode_preference == ControlMode.AUTO and auto_touch_detected)
	if touch_controls_active != should_use_touch:
		touch_controls_active = should_use_touch
		_clear_touch_control_state()
	if player != null and is_instance_valid(player):
		player.set_touch_controls_enabled(touch_controls_active)
	_refresh_pause_panel()
	_refresh_touch_hud()
	_update_hint()


func _control_mode_label(selected_mode: int = control_mode_preference) -> String:
	match selected_mode:
		ControlMode.DESKTOP:
			return "Desktop"
		ControlMode.TOUCH:
			return "Touch"
		_:
			return "Auto"


func _pause_menu_allowed() -> bool:
	if title_panel.visible or briefing_panel.visible or upgrade_panel.visible or patch_panel.visible:
		return false
	if game_over or mission_complete:
		return false
	return true


func _toggle_pause_menu() -> void:
	if settings_menu_open:
		_hide_pause_menu()
		return
	if not _pause_menu_allowed():
		return
	_show_pause_menu()


func _show_pause_menu() -> void:
	pause_restore_banner = banner_default
	pause_restore_objective = current_objective_text
	settings_menu_open = true
	pause_panel.visible = true
	get_tree().paused = true
	banner_default = "Defense paused. Tune the field settings and resume when ready."
	banner_label.text = banner_default
	current_objective_text = "Defense paused. Adjust controls and audio or resume the run."
	_refresh_pause_panel()
	_update_hint()
	_update_stats()


func _hide_pause_menu() -> void:
	settings_menu_open = false
	pause_panel.visible = false
	get_tree().paused = false
	banner_default = pause_restore_banner
	current_objective_text = pause_restore_objective
	if wave_active:
		_refresh_current_objective_text()
	elif prep_phase_active:
		_refresh_prep_panel()
	banner_label.text = banner_default
	_update_hint()
	_update_stats()


func _refresh_pause_panel() -> void:
	if pause_panel == null:
		return

	var active_mode_label := _control_mode_label()
	var auto_note := ""
	if control_mode_preference == ControlMode.AUTO:
		auto_note = " Touch has %sbeen detected for this run." % ["" if auto_touch_detected else "not "]
	pause_body_label.text = "Current control mode: %s.%s\nSwitching here updates the current run immediately." % [active_mode_label, auto_note]
	pause_music_slider.value = roundi(music_volume_level * 100.0)
	pause_music_value_label.text = "%d%%" % int(roundi(music_volume_level * 100.0))
	pause_sfx_slider.value = roundi(sfx_volume_level * 100.0)
	pause_sfx_value_label.text = "%d%%" % int(roundi(sfx_volume_level * 100.0))
	_update_touch_button_state(pause_auto_button, control_mode_preference == ControlMode.AUTO)
	_update_touch_button_state(pause_desktop_button, control_mode_preference == ControlMode.DESKTOP)
	_update_touch_button_state(pause_touch_button, control_mode_preference == ControlMode.TOUCH)


func _clear_touch_control_state() -> void:
	touch_move_touch_id = -1
	touch_aim_touch_id = -1
	touch_move_knob_offset = Vector2.ZERO
	touch_aim_knob_offset = Vector2.ZERO
	if player != null and is_instance_valid(player):
		player.clear_touch_movement()
		player.stop_touch_aim()
	_update_touch_pad_visuals()


func _touch_gameplay_enabled() -> bool:
	if not touch_controls_active:
		return false
	if title_panel.visible or briefing_panel.visible or upgrade_panel.visible or patch_panel.visible:
		return false
	if get_tree().paused or game_over or mission_complete:
		return false
	return true


func _refresh_touch_hud() -> void:
	if touch_hud_root == null:
		return

	touch_hud_root.visible = _touch_gameplay_enabled()
	var build_controls_visible := touch_hud_root.visible and prep_phase_active
	touch_coil_button.text = "Coil\n%d" % turret_cost
	touch_shock_button.text = "Shock\n%d" % shock_post_cost
	touch_fence_button.text = "Fence\n%d" % barricade_cost
	touch_swap_button.text = "Weapon\n%s" % _current_weapon_name()
	touch_swap_button.visible = touch_hud_root.visible and _weapon_swap_available()
	touch_pause_button.visible = touch_hud_root.visible
	touch_coil_button.visible = build_controls_visible
	touch_shock_button.visible = build_controls_visible and shock_post_unlocked
	touch_fence_button.visible = build_controls_visible and barricade_unlocked
	_update_touch_button_state(touch_coil_button, selected_build_type == BUILD_COIL_TURRET)
	_update_touch_button_state(touch_shock_button, selected_build_type == BUILD_SHOCK_POST)
	_update_touch_button_state(touch_fence_button, selected_build_type == BUILD_BARRICADE)
	_update_touch_button_state(touch_swap_button, false)
	_update_touch_button_state(touch_pause_button, false)
	_update_touch_pad_visuals()


func _update_touch_button_state(button: Button, is_selected: bool) -> void:
	if button == null:
		return
	button.modulate = Color8(255, 234, 196) if is_selected else Color8(216, 218, 224)


func _touch_pad_center(pad: Control) -> Vector2:
	return pad.global_position + pad.size * 0.5


func _touch_point_hits_button(screen_position: Vector2) -> bool:
	for button in [touch_pause_button, touch_swap_button, touch_coil_button, touch_shock_button, touch_fence_button]:
		if button != null and button.visible and button.get_global_rect().has_point(screen_position):
			return true
	return false


func _touch_pad_contains(pad: Control, screen_position: Vector2) -> bool:
	return _touch_pad_center(pad).distance_to(screen_position) <= TOUCH_PAD_RADIUS + 24.0


func _update_touch_move_from_position(screen_position: Vector2) -> void:
	var center := _touch_pad_center(touch_move_base)
	var offset := screen_position - center
	if offset.length() > TOUCH_PAD_RADIUS:
		offset = offset.normalized() * TOUCH_PAD_RADIUS
	touch_move_knob_offset = offset
	if player != null and is_instance_valid(player):
		player.set_touch_move_vector(offset / TOUCH_PAD_RADIUS)
	_update_touch_pad_visuals()


func _update_touch_aim_from_position(screen_position: Vector2) -> void:
	var center := _touch_pad_center(touch_aim_base)
	var offset := screen_position - center
	if offset.length() > TOUCH_PAD_RADIUS:
		offset = offset.normalized() * TOUCH_PAD_RADIUS
	touch_aim_knob_offset = offset
	if offset.length() > 10.0:
		touch_aim_vector = offset.normalized()
	if player != null and is_instance_valid(player):
		player.set_touch_aim_direction(touch_aim_vector, true)
	_update_touch_pad_visuals()


func _update_touch_pad_visuals() -> void:
	if touch_move_base == null or touch_move_knob == null or touch_aim_base == null or touch_aim_knob == null:
		return
	touch_move_knob.position = (touch_move_base.size - touch_move_knob.size) * 0.5 + touch_move_knob_offset
	touch_aim_knob.position = (touch_aim_base.size - touch_aim_knob.size) * 0.5 + touch_aim_knob_offset


func _handle_touch_pressed(touch_id: int, screen_position: Vector2) -> bool:
	if _touch_point_hits_button(screen_position):
		return false
	if touch_move_touch_id == -1 and _touch_pad_contains(touch_move_base, screen_position):
		touch_move_touch_id = touch_id
		_update_touch_move_from_position(screen_position)
		return true
	if touch_aim_touch_id == -1 and _touch_pad_contains(touch_aim_base, screen_position):
		touch_aim_touch_id = touch_id
		_update_touch_aim_from_position(screen_position)
		return true
	return false


func _handle_touch_drag(touch_id: int, screen_position: Vector2) -> bool:
	if touch_id == touch_move_touch_id:
		_update_touch_move_from_position(screen_position)
		return true
	if touch_id == touch_aim_touch_id:
		_update_touch_aim_from_position(screen_position)
		return true
	return false


func _handle_touch_released(touch_id: int) -> bool:
	if touch_id == touch_move_touch_id:
		touch_move_touch_id = -1
		touch_move_knob_offset = Vector2.ZERO
		if player != null and is_instance_valid(player):
			player.clear_touch_movement()
		_update_touch_pad_visuals()
		return true
	if touch_id == touch_aim_touch_id:
		touch_aim_touch_id = -1
		touch_aim_knob_offset = Vector2.ZERO
		if player != null and is_instance_valid(player):
			player.stop_touch_aim()
		_update_touch_pad_visuals()
		return true
	return false


func _on_touch_build_button_pressed(build_type: String) -> void:
	_ensure_audio_started()
	_select_build_type(build_type)


func _on_touch_swap_button_pressed() -> void:
	_ensure_audio_started()
	_toggle_weapon()


func _on_touch_pause_button_pressed() -> void:
	_ensure_audio_started()
	_toggle_pause_menu()


func _on_pause_resume_pressed() -> void:
	_ensure_audio_started()
	_hide_pause_menu()


func _on_pause_restart_pressed() -> void:
	_ensure_audio_started()
	settings_menu_open = false
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_pause_control_mode_pressed(selected_mode: int) -> void:
	_ensure_audio_started()
	control_mode_preference = selected_mode
	if selected_mode == ControlMode.DESKTOP:
		auto_touch_detected = false
	elif selected_mode == ControlMode.TOUCH:
		auto_touch_detected = true
	_apply_control_mode()
	_refresh_pause_panel()


func _on_pause_music_slider_changed(value: float) -> void:
	music_volume_level = clampf(value / 100.0, 0.0, 1.0)
	if pause_music_value_label != null:
		pause_music_value_label.text = "%d%%" % int(roundi(value))
	_apply_audio_levels()


func _on_pause_sfx_slider_changed(value: float) -> void:
	sfx_volume_level = clampf(value / 100.0, 0.0, 1.0)
	if pause_sfx_value_label != null:
		pause_sfx_value_label.text = "%d%%" % int(roundi(value))


func _setup_timers() -> void:
	spawn_timer = Timer.new()
	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)

	banner_timer = Timer.new()
	banner_timer.one_shot = true
	banner_timer.timeout.connect(_restore_banner)
	add_child(banner_timer)


func _setup_audio() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.stream = MUSIC_FARM_DEFENSE_LOOP
	music_player.volume_db = -14.0
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	music_player.finished.connect(_on_music_player_finished)
	add_child(music_player)

	music_sting_player = AudioStreamPlayer.new()
	music_sting_player.stream = MUSIC_WAVE_WARNING_STING
	music_sting_player.volume_db = -9.0
	music_sting_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(music_sting_player)

	if DisplayServer.get_name() != "headless" and not OS.has_feature("web"):
		music_player.play()
		audio_started = true
	_apply_audio_levels()


func _on_music_player_finished() -> void:
	if music_player != null and is_instance_valid(music_player):
		music_player.play()


func _ensure_audio_started() -> void:
	if audio_started or DisplayServer.get_name() == "headless":
		return
	if music_player == null or not is_instance_valid(music_player):
		return

	audio_started = true
	if not music_player.playing:
		music_player.play()


func _volume_level_to_offset_db(level: float) -> float:
	if level <= 0.001:
		return -80.0
	return linear_to_db(level)


func _apply_audio_levels() -> void:
	var music_offset := _volume_level_to_offset_db(music_volume_level)
	if music_player != null and is_instance_valid(music_player):
		music_player.volume_db = MUSIC_LOOP_BASE_DB + music_offset
	if music_sting_player != null and is_instance_valid(music_sting_player):
		music_sting_player.volume_db = MUSIC_STING_BASE_DB + music_offset


func _on_viewport_size_changed() -> void:
	_layout_ui()
	queue_redraw()


func _layout_ui() -> void:
	var viewport_size := get_viewport_rect().size
	if top_panel != null:
		top_panel.position = Vector2.ZERO
		top_panel.size = Vector2(viewport_size.x, 72.0)
	if bottom_panel != null:
		bottom_panel.position = Vector2(0.0, viewport_size.y - 44.0)
		bottom_panel.size = Vector2(viewport_size.x, 44.0)
	if stats_label != null:
		stats_label.position = Vector2(18.0, 10.0)
		stats_label.size = Vector2(maxf(360.0, viewport_size.x - 460.0), 22.0)
	if farm_status_label != null:
		farm_status_label.position = Vector2(18.0, 38.0)
		farm_status_label.size = Vector2(maxf(360.0, viewport_size.x - 460.0), 22.0)
	if banner_label != null:
		banner_label.position = Vector2(maxf(18.0, viewport_size.x - 406.0), 22.0)
		banner_label.size = Vector2(388.0, 24.0)
	if hint_label != null:
		hint_label.position = Vector2(18.0, 11.0)
		hint_label.size = Vector2(maxf(360.0, viewport_size.x - 36.0), 22.0)
	for panel in [title_panel, briefing_panel, upgrade_panel, patch_panel]:
		if panel != null:
			panel.size.x = minf(panel.size.x, viewport_size.x - 20.0)
			panel.size.y = minf(panel.size.y, viewport_size.y - 20.0)
			panel.position = (viewport_size - panel.size) * 0.5
	if pause_panel != null:
		pause_panel.size.x = minf(pause_panel.size.x, viewport_size.x - 20.0)
		pause_panel.size.y = minf(pause_panel.size.y, viewport_size.y - 20.0)
		pause_panel.position = (viewport_size - pause_panel.size) * 0.5
	if prep_panel != null:
		prep_panel.size.x = minf(prep_panel.size.x, viewport_size.x - 20.0)
		prep_panel.position = Vector2((viewport_size.x - prep_panel.size.x) * 0.5, 86.0)
	if player != null and is_instance_valid(player):
		player.play_bounds = _current_play_bounds()
		player.global_position = player.global_position.clamp(player.play_bounds.position, player.play_bounds.position + player.play_bounds.size)
	_layout_touch_hud(viewport_size)


func _current_play_bounds() -> Rect2:
	var viewport_size := get_viewport_rect().size
	return Rect2(
		Vector2(PLAY_BOUNDS_MARGIN_X, PLAY_BOUNDS_TOP),
		Vector2(
			maxf(240.0, viewport_size.x - PLAY_BOUNDS_MARGIN_X * 2.0),
			maxf(220.0, viewport_size.y - PLAY_BOUNDS_TOP - PLAY_BOUNDS_BOTTOM_MARGIN)
		)
	)


func _layout_touch_hud(viewport_size: Vector2) -> void:
	if touch_move_base == null or touch_aim_base == null:
		return

	var pad_y := maxf(84.0, viewport_size.y - TOUCH_PAD_SIZE.y - 58.0)
	touch_move_base.position = Vector2(26.0, pad_y)
	touch_aim_base.position = Vector2(viewport_size.x - TOUCH_PAD_SIZE.x - 26.0, pad_y)

	var button_x := viewport_size.x - 166.0
	touch_coil_button.position = Vector2(button_x, 118.0)
	touch_shock_button.position = Vector2(button_x, 176.0)
	touch_fence_button.position = Vector2(button_x, 234.0)
	touch_swap_button.position = Vector2(button_x, 292.0)
	touch_pause_button.position = Vector2(button_x, 356.0)
	_update_touch_pad_visuals()


func _play_positional_sfx(stream: AudioStream, world_position: Vector2, volume_db: float = -3.0, pitch_min: float = 0.97, pitch_max: float = 1.03) -> void:
	if stream == null:
		return
	if sfx_volume_level <= 0.001:
		return

	var sfx_player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	sfx_player.stream = stream
	sfx_player.global_position = world_position
	sfx_player.volume_db = volume_db + _volume_level_to_offset_db(sfx_volume_level)
	sfx_player.pitch_scale = randf_range(pitch_min, pitch_max)
	sfx_player.process_mode = Node.PROCESS_MODE_ALWAYS
	sfx_player.finished.connect(sfx_player.queue_free)
	add_child(sfx_player)
	sfx_player.play()


func _spawn_player() -> void:
	player = PLAYER_SCENE.instantiate() as CharacterBody2D
	player.position = Vector2(640.0, 510.0)
	player.play_bounds = _current_play_bounds()
	player.set_move_speed(player_move_speed)
	player.set_touch_controls_enabled(touch_controls_active)
	player.fired.connect(_on_player_fired)
	add_child(player)
	_refresh_player_weapon()


func _spawn_dog() -> void:
	dog = DOG_SCENE.instantiate() as CharacterBody2D
	dog.position = Vector2(596.0, 542.0)
	dog.set_player(player)
	dog.set_main_ref(self)
	dog.barked.connect(_on_dog_barked)
	dog.growled.connect(_on_dog_growled)
	add_child(dog)


func _spawn_field_signal() -> void:
	field_signal = FIELD_SIGNAL_SCENE.instantiate() as Node2D
	field_signal.position = DRILL_SITE_POS
	add_child(field_signal)
	_update_field_signal_state(0, false)


func _spawn_rocket_tractor() -> void:
	if rocket_tractor != null and is_instance_valid(rocket_tractor):
		return

	rocket_tractor = ROCKET_TRACTOR_SCENE.instantiate()
	rocket_tractor.position = Vector2(176.0, 402.0)
	rocket_tractor.configure(BULLET_SCENE, 164.0, 1116.0, rocket_tractor_patrol_speed, rocket_tractor_fire_interval, rocket_tractor_damage, rocket_tractor_rocket_speed)
	rocket_tractor.rocket_launched.connect(_on_rocket_tractor_launched)
	add_child(rocket_tractor)
	_refresh_support_units()


func _spawn_farm_structures() -> void:
	farm_structures.clear()
	for structure_id in FARM_STRUCTURE_ORDER:
		var structure_data: Dictionary = FARM_STRUCTURE_DEFS[structure_id]
		var structure: Node2D = FARM_STRUCTURE_SCENE.instantiate() as Node2D
		structure.position = structure_data["position"]
		structure.configure(structure_id, String(structure_data["name"]), String(structure_data["type"]), int(structure_data["health"]))
		structure.damaged.connect(_on_farm_structure_damaged)
		structure.destroyed.connect(_on_farm_structure_destroyed)
		add_child(structure)
		farm_structures[structure_id] = structure


func _spawn_build_spots() -> void:
	var build_positions: Array[Vector2] = [
		Vector2(430.0, 548.0),
		Vector2(535.0, 582.0),
		Vector2(745.0, 582.0),
		Vector2(850.0, 548.0),
		Vector2(332.0, 566.0),
		Vector2(874.0, 606.0),
		Vector2(974.0, 486.0)
	]

	for build_position in build_positions:
		var build_spot: Area2D = BUILD_SPOT_SCENE.instantiate() as Area2D
		build_spot.position = build_position
		build_spot.build_requested.connect(_on_build_requested)
		add_child(build_spot)


func _spawn_scout_caches_for_wave(wave_index: int) -> void:
	_clear_scout_caches()
	if patch_path != PatchPath.SCOUT or patch_rank <= 0:
		return

	var cache_count := 1
	if patch_rank >= 3:
		cache_count = 2
	elif patch_rank >= 2 and wave_index >= 3:
		cache_count = 2

	var reward_pool: Array[Dictionary] = []
	match patch_rank:
		1:
			reward_pool = [
				{"type":"scrap", "value":2},
				{"type":"scrap", "value":3},
			]
		2:
			reward_pool = [
				{"type":"scrap", "value":3},
				{"type":"fire_rate", "value":1},
				{"type":"scrap", "value":2},
			]
		3:
			reward_pool = [
				{"type":"scrap", "value":4},
				{"type":"fire_rate", "value":1},
				{"type":"repair", "value":1},
				{"type":"scrap", "value":3},
			]

	for _i in range(cache_count):
		var cache_position := Vector2(
			randf_range(180.0, 1100.0),
			randf_range(290.0, 430.0)
		)
		if cache_position.distance_to(FARMHOUSE_POS) < 120.0:
			cache_position.y -= 80.0
		if cache_position.distance_to(DRILL_SITE_POS) < 100.0:
			cache_position.x += 120.0

		var reward: Dictionary = reward_pool[randi() % reward_pool.size()]
		var cache: Node2D = SCOUT_CACHE_SCENE.instantiate() as Node2D
		cache.position = cache_position
		cache.configure(String(reward["type"]), int(reward["value"]))
		cache.discovered.connect(_on_scout_cache_discovered)
		add_child(cache)
		active_scout_caches.append(cache)


func _clear_scout_caches() -> void:
	for cache in active_scout_caches:
		if cache != null and is_instance_valid(cache):
			cache.queue_free()
	active_scout_caches.clear()


func _on_scout_cache_discovered(reward_type: String, reward_value: int, world_position: Vector2) -> void:
	if game_over:
		return

	match reward_type:
		"scrap":
			scrap += reward_value
			_set_banner("Patch digs up a buried stash. +%d scrap." % reward_value, 2.0)
		"fire_rate":
			_apply_player_fire_rate_boost(0.02, 0.03)
			_set_banner("Patch uncovers an alien power cell. Eli fires faster for a moment.", 2.2)
		"repair":
			var structure_id := _priority_structure_to_repair()
			if structure_id != "":
				_restore_farm_structure(structure_id)
				_set_banner("Patch finds repair parts. The %s gets patched up." % _structure_display_name(structure_id), 2.4)
			else:
				base_health += 1
				_set_banner("Patch finds sealed plating. Farmhouse gains 1 base.", 2.0)
	_play_positional_sfx(SFX_DOG_BARK_ALERT, world_position, -11.0, 1.02, 1.10)
	_update_stats()


func _current_weapon_fire_interval() -> float:
	if current_weapon_id == WEAPON_SCRAP_BLASTER:
		return scrap_blaster_fire_interval
	if current_weapon_id == WEAPON_TRACTOR_CANNON:
		return tractor_cannon_fire_interval
	return player_fire_interval


func _current_weapon_name() -> String:
	if current_weapon_id == WEAPON_SCRAP_BLASTER:
		return "Scrap Blaster"
	if current_weapon_id == WEAPON_TRACTOR_CANNON:
		return "Tractor Cannon"
	return "Nailgun"


func _weapon_swap_available() -> bool:
	return _available_weapon_ids().size() > 1


func _farm_structure_by_id(structure_id: String) -> Node2D:
	if not farm_structures.has(structure_id):
		return null

	var structure: Node2D = farm_structures[structure_id]
	if structure == null or not is_instance_valid(structure):
		return null
	return structure


func _has_intact_structure(structure_id: String) -> bool:
	var structure: Node2D = _farm_structure_by_id(structure_id)
	return structure != null and not structure.is_destroyed()


func _structure_target_position(structure_id: String) -> Vector2:
	var structure: Node2D = _farm_structure_by_id(structure_id)
	if structure != null:
		return structure.global_position
	if FARM_STRUCTURE_DEFS.has(structure_id):
		return FARM_STRUCTURE_DEFS[structure_id]["position"]
	return FARMHOUSE_POS


func _structure_display_name(structure_id: String) -> String:
	if FARM_STRUCTURE_DEFS.has(structure_id):
		return String(FARM_STRUCTURE_DEFS[structure_id]["name"])
	return "farm structure"


func _effective_turret_fire_interval() -> float:
	var effective_interval := turret_fire_interval
	if not _has_intact_structure("power_shed"):
		effective_interval *= POWER_SHED_FIRE_PENALTY
	return effective_interval


func _effective_shock_post_fire_interval() -> float:
	var effective_interval := shock_post_fire_interval
	if not _has_intact_structure("power_shed"):
		effective_interval *= POWER_SHED_FIRE_PENALTY
	return effective_interval


func _farmhouse_damage_bonus() -> int:
	if not _has_intact_structure("silo"):
		return SILO_DAMAGE_PENALTY
	return 0


func _refresh_player_weapon() -> void:
	if player == null or not is_instance_valid(player):
		return

	player.set_fire_interval(_current_weapon_fire_interval())
	player.set_weapon_style(current_weapon_id)


func _refresh_rocket_tractor_stats() -> void:
	if rocket_tractor != null and is_instance_valid(rocket_tractor):
		rocket_tractor.set_stats(rocket_tractor_patrol_speed, rocket_tractor_fire_interval, rocket_tractor_damage, rocket_tractor_rocket_speed)


func _refresh_support_units() -> void:
	if rocket_tractor != null and is_instance_valid(rocket_tractor):
		rocket_tractor.set_support_active(rocket_tractor_unlocked and wave_active and not game_over and not mission_complete)


func _apply_player_fire_rate_boost(nailgun_delta: float, scrap_blaster_delta: float = -1.0) -> void:
	player_fire_interval = maxf(0.08, player_fire_interval - nailgun_delta)
	if scrap_blaster_delta < 0.0:
		scrap_blaster_delta = nailgun_delta
	scrap_blaster_fire_interval = maxf(0.30, scrap_blaster_fire_interval - scrap_blaster_delta)
	_refresh_player_weapon()


func _build_cost_for_type(build_type: String) -> int:
	if build_type == BUILD_SHOCK_POST:
		return shock_post_cost
	if build_type == BUILD_BARRICADE:
		return barricade_cost
	return turret_cost


func _build_name_for_type(build_type: String) -> String:
	if build_type == BUILD_SHOCK_POST:
		return "shock post"
	if build_type == BUILD_BARRICADE:
		return "barbed barricade"
	return "coil turret"


func _select_build_type(build_type: String, announce: bool = true) -> void:
	if build_type == BUILD_SHOCK_POST and not shock_post_unlocked:
		return
	if build_type == BUILD_BARRICADE and not barricade_unlocked:
		return

	selected_build_type = build_type
	if announce:
		_set_banner("%s selected for the next build pad." % _build_name_for_type(build_type).capitalize(), 1.5)
	_update_hint()
	_update_stats()


func _toggle_weapon() -> void:
	var available_weapons := _available_weapon_ids()
	if available_weapons.size() <= 1:
		return

	var current_index := available_weapons.find(current_weapon_id)
	if current_index == -1:
		current_index = 0
	current_weapon_id = available_weapons[(current_index + 1) % available_weapons.size()]
	_refresh_player_weapon()
	_set_banner("%s ready." % _current_weapon_name(), 1.4)
	_update_stats()
	_update_hint()


func _available_weapon_ids() -> Array[String]:
	var weapons: Array[String] = [WEAPON_NAILGUN]
	if scrap_blaster_unlocked:
		weapons.append(WEAPON_SCRAP_BLASTER)
	if tractor_cannon_unlocked:
		weapons.append(WEAPON_TRACTOR_CANNON)
	return weapons


func _update_field_signal_state(signal_wave: int, highlight_active: bool) -> void:
	if field_signal == null or not is_instance_valid(field_signal):
		return

	var signal_stage := maxi(0, signal_wave - 2)
	field_signal.set_signal_state(signal_stage, highlight_active)


func _show_briefing_for_wave(wave_index: int, transition_text: String = "") -> void:
	var wave_data: Dictionary = ACT_ONE_WAVES[wave_index]
	settings_menu_open = false
	prep_phase_active = false
	pending_wave_index = wave_index
	wave = wave_index + 1
	wave_active = false
	current_objective_text = "Review the plan for wave %d." % wave
	banner_default = String(wave_data["title"])
	briefing_title_label.text = String(wave_data["title"])
	briefing_body_label.text = _compose_briefing_text(wave_data, transition_text)
	briefing_footer_label.text = "Review the plan, then take a setup break to place defenses before Eli starts the next wave."
	briefing_continue_button.text = "Open Setup For Wave %d" % wave
	if wave_index == 0:
		briefing_continue_button.text = "Open First Setup"
	briefing_panel.visible = true
	prep_panel.visible = false
	upgrade_panel.visible = false
	patch_panel.visible = false
	pause_panel.visible = false
	get_tree().paused = true
	banner_label.text = banner_default
	_update_field_signal_state(wave, bool(wave_data.get("drill_site", false)) or wave_data.has("relay_trigger_spawned") or wave_data.has("act_two_nodes"))
	_refresh_support_units()
	queue_redraw()
	_update_hint()
	_update_stats()


func _compose_briefing_text(wave_data: Dictionary, transition_text: String) -> String:
	var briefing_text: String = String(wave_data["story"])
	if transition_text != "":
		briefing_text = transition_text + "\n\n" + briefing_text
	briefing_text += "\n\nObjective: %s" % String(wave_data["objective"])

	var roster_bits: Array[String] = []
	var scout_count: int = int(wave_data["spawn_count"]) - int(wave_data["driller_count"]) - int(wave_data["harrier_count"]) - int(wave_data.get("shield_count", 0)) - int(wave_data.get("burrower_count", 0))
	if scout_count > 0:
		roster_bits.append("%d Scouts" % scout_count)
	if int(wave_data["driller_count"]) > 0:
		roster_bits.append("%d Drillers (heavy, feed rigs)" % int(wave_data["driller_count"]))
	if int(wave_data["harrier_count"]) > 0:
		roster_bits.append("%d Harriers (ranged flyers)" % int(wave_data["harrier_count"]))
	if int(wave_data.get("shield_count", 0)) > 0:
		roster_bits.append("%d Shield Drones (block frontal shots)" % int(wave_data.get("shield_count", 0)))
	if int(wave_data.get("burrower_count", 0)) > 0:
		roster_bits.append("%d Burrowers (ignore barricades)" % int(wave_data.get("burrower_count", 0)))

	var extras: Array[String] = []
	if wave_data.get("drill_site", false):
		extras.append("Drill Rig (destroy before breach)")
	if wave_data.has("relay_trigger_spawned"):
		extras.append("Signal Relay (boosts all aliens)")
	if wave_data.has("boss"):
		extras.append("BOSS: %s" % String(wave_data["boss"].get("name", "Unknown")))
	for obj in wave_data.get("act_two_nodes", []):
		extras.append("%s (%s)" % [String(obj.get("name", "")), String(obj.get("kind", "")).replace("_", " ")])

	briefing_text += "\n\nThreat Roster: %s." % ", ".join(roster_bits)
	if not extras.is_empty():
		briefing_text += "\nObjectives: %s." % ", ".join(extras)

	return briefing_text


func _on_briefing_continue_pressed() -> void:
	_ensure_audio_started()
	if mission_complete or game_over:
		get_tree().paused = false
		get_tree().reload_current_scene()
		return

	if wave_clear_pending:
		wave_clear_pending = false
		briefing_panel.visible = false

		if current_wave_index == 0 and patch_path == PatchPath.NONE:
			_show_patch_choice()
			return

		var next_wave_index: int = current_wave_index + 1
		var transition_text: String = _prepare_transition_for_wave(next_wave_index + 1)
		if wave_clear_farm_text != "":
			if transition_text != "":
				transition_text = wave_clear_farm_text + "\n\n" + transition_text
			else:
				transition_text = wave_clear_farm_text
		_show_upgrade_panel(next_wave_index, transition_text)
		return

	briefing_panel.visible = false
	get_tree().paused = false
	_enter_prep_phase(pending_wave_index)


func _enter_prep_phase(wave_index: int) -> void:
	if wave_index < 0 or wave_index >= ACT_ONE_WAVES.size():
		return

	prep_phase_active = true
	pending_wave_index = wave_index
	wave = wave_index + 1
	wave_active = false
	settings_menu_open = false
	current_objective_text = "Setup for wave %d. Move Eli, place defenses, and press Start Wave when ready." % wave
	banner_default = "The field is quiet. Build the line, then start wave %d." % wave
	prep_panel.visible = true
	pause_panel.visible = false
	_refresh_prep_panel()
	banner_label.text = banner_default
	_refresh_support_units()
	queue_redraw()
	_update_hint()
	_update_stats()


func _refresh_prep_panel() -> void:
	if prep_panel == null or pending_wave_index < 0 or pending_wave_index >= ACT_ONE_WAVES.size():
		return

	var build_bits := ["Coil %d" % turret_cost]
	if shock_post_unlocked:
		build_bits.append("Shock %d" % shock_post_cost)
	if barricade_unlocked:
		build_bits.append("Fence %d" % barricade_cost)
	var weapon_bits := _available_weapon_ids()
	var control_hint := "Swap with Q." if _weapon_swap_available() else "No alternate weapon unlocked yet."
	if touch_controls_active:
		control_hint = "Use the Weapon button to swap guns." if _weapon_swap_available() else "No alternate weapon unlocked yet."

	prep_title_label.text = "Setup Break: Wave %d" % (pending_wave_index + 1)
	prep_body_label.text = "The next rush waits on Eli. Spend scrap, place defenses, and line up the farm before the wave begins.\nScrap on hand: %d. Weapons: %s. Current gun: %s. %s Build kit: %s. Selected build: %s." % [
		scrap,
		", ".join(weapon_bits),
		_current_weapon_name(),
		control_hint,
		", ".join(build_bits),
		_build_name_for_type(selected_build_type).capitalize()
	]
	prep_start_button.text = "Start Wave %d" % (pending_wave_index + 1)
	prep_footer_label.text = "Nothing spawns until you press Start Wave, so this is the safe window to set turrets, posts, and fences."


func _on_prep_start_pressed() -> void:
	_ensure_audio_started()
	if pending_wave_index < 0 or pending_wave_index >= ACT_ONE_WAVES.size():
		return

	prep_phase_active = false
	prep_panel.visible = false
	_start_wave(pending_wave_index)


func _start_wave(wave_index: int) -> void:
	var wave_data: Dictionary = ACT_ONE_WAVES[wave_index]
	current_wave_index = wave_index
	wave = wave_index + 1
	wave_active = true
	current_wave_spawn_interval = float(wave_data["spawn_interval"])
	current_wave_start_delay = float(wave_data["start_delay"])
	current_wave_spawn_mode = String(wave_data["spawn_mode"])
	base_wave_objective_text = String(wave_data["objective"])
	current_objective_text = base_wave_objective_text
	wave_total_spawns = int(wave_data["spawn_count"])
	wave_drillers_remaining = int(wave_data["driller_count"])
	wave_harriers_remaining = int(wave_data["harrier_count"])
	wave_shields_remaining = int(wave_data.get("shield_count", 0))
	wave_burrowers_remaining = int(wave_data.get("burrower_count", 0))
	wave_spawned = 0
	active_aliens = 0
	combo_count = 0
	combo_timer = 0.0
	prep_phase_active = false
	relay_spawned_for_wave = false
	boss_spawned_for_wave = false
	boss_target_cycle = 0
	shield_warning_sent = false
	burrower_warning_sent = false
	driller_warning_sent = false
	harrier_warning_sent = false
	structure_raid_pool = _build_structure_raid_pool(wave_data)
	structure_raid_notice_sent = false
	_spawn_wave_objectives(wave_data)
	_refresh_current_objective_text()
	banner_default = _story_text_for_wave(wave)
	_set_banner(banner_default, 3.0)
	if music_sting_player != null and is_instance_valid(music_sting_player):
		music_sting_player.play()
	_update_field_signal_state(wave, _has_live_drill_site() or wave >= 4)
	_refresh_support_units()
	queue_redraw()
	_update_hint()
	_update_stats()
	_spawn_scout_caches_for_wave(wave_index)
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
	var target_structure_id := ""
	if enemy_kind != "driller":
		target_structure_id = _dequeue_structure_raid_target()
		if target_structure_id != "":
			goal_position = _structure_target_position(target_structure_id)
			_announce_structure_raid(target_structure_id)
	elif enemy_kind == "driller" and _has_live_drill_site():
		goal_position = current_drill_site.global_position
		targets_drill_site = true
	alien.configure(spawn_position, goal_position, wave, enemy_kind, targets_drill_site, target_structure_id)
	alien.destroyed.connect(_on_alien_destroyed)
	alien.farmhouse_hit.connect(_on_alien_farmhouse_hit)
	alien.structure_hit.connect(_on_alien_structure_hit)
	alien.drill_site_reached.connect(_on_alien_drill_site_reached)
	alien.ranged_attack.connect(_on_alien_ranged_attack)
	alien.damaged.connect(_on_alien_damaged)
	add_child(alien)
	match enemy_kind:
		"driller":
			_play_positional_sfx(SFX_ALIEN_BRUTE_ROAR, spawn_position, -11.0, 0.94, 1.02)
			if not driller_warning_sent:
				driller_warning_sent = true
				_set_banner("DRILLER: Heavy brute that feeds the drill rig. Kill it before it reaches the rig or it powers up the extraction.", 3.2)
		"harrier":
			_play_positional_sfx(SFX_ALIEN_CHITTER_IDLE, spawn_position, -18.0, 1.04, 1.10)
			if not harrier_warning_sent:
				harrier_warning_sent = true
				_set_banner("HARRIER: Ranged flyer that shoots the farmhouse and structures from a distance. Move Eli to dodge its bolts.", 3.2)
		"shield_drone":
			_play_positional_sfx(SFX_ALIEN_CHITTER_IDLE, spawn_position, -16.0, 0.90, 0.98)
			if not shield_warning_sent:
				shield_warning_sent = true
				_set_banner("SHIELD DRONE: Blocks shots from the front. Flank it from the side, or use shock posts to strip the shield with EMP.", 3.2)
		"burrower":
			_play_positional_sfx(SFX_ALIEN_CHITTER_IDLE, spawn_position, -17.0, 0.82, 0.92)
			if not burrower_warning_sent:
				burrower_warning_sent = true
				_set_banner("BURROWER: Tunnels under barricades and heads straight for the farm. Must be shot directly.", 3.2)
		_:
			if randf() <= 0.22:
				_play_positional_sfx(SFX_ALIEN_CHITTER_IDLE, spawn_position, -20.0, 0.98, 1.08)
	wave_spawned += 1
	active_aliens += 1
	mark_aliens_dirty()
	_maybe_spawn_midwave_objective()
	_update_stats()


func _spawn_wave_objectives(wave_data: Dictionary) -> void:
	current_drill_site = null
	current_signal_relay = null
	current_act_two_objectives.clear()
	current_wave_boss = null
	if bool(wave_data.get("drill_site", false)):
		var drill_rig: StaticBody2D = DRILL_RIG_SCENE.instantiate() as StaticBody2D
		drill_rig.position = DRILL_SITE_POS
		drill_rig.configure(int(wave_data["drill_health"]), float(wave_data["drill_rate"]), 4 + wave)
		drill_rig.destroyed.connect(_on_drill_site_destroyed)
		drill_rig.breached.connect(_on_drill_site_breached)
		drill_rig.damaged.connect(_on_objective_damaged)
		add_child(drill_rig)
		current_drill_site = drill_rig
		active_aliens += 1
		mark_aliens_dirty()
		_set_banner("DRILL RIG deployed. Drillers will feed it power. Destroy the rig before it breaches the field or you lose.", 3.5)

	for objective_data in wave_data.get("act_two_nodes", []):
		var act_two_objective: StaticBody2D = ACT2_OBJECTIVE_SCENE.instantiate() as StaticBody2D
		act_two_objective.position = objective_data.get("position", DRILL_SITE_POS)
		act_two_objective.configure(objective_data)
		act_two_objective.destroyed.connect(_on_act_two_objective_destroyed)
		act_two_objective.pulsed.connect(_on_act_two_objective_pulsed)
		act_two_objective.damaged.connect(_on_objective_damaged)
		add_child(act_two_objective)
		current_act_two_objectives.append(act_two_objective)
		active_aliens += 1
		mark_aliens_dirty()


func _build_structure_raid_pool(wave_data: Dictionary) -> Array[String]:
	var raid_pool: Array[String] = []
	for raid_entry in wave_data.get("structure_raids", []):
		var structure_id: String = String(raid_entry.get("id", ""))
		var raid_count: int = int(raid_entry.get("count", 0))
		for _raid_index in range(raid_count):
			raid_pool.append(structure_id)
	return raid_pool


func _dequeue_structure_raid_target() -> String:
	while not structure_raid_pool.is_empty():
		var structure_id: String = structure_raid_pool.pop_front()
		if _has_intact_structure(structure_id):
			return structure_id
	return ""


func _announce_structure_raid(structure_id: String) -> void:
	if structure_raid_notice_sent:
		return

	structure_raid_notice_sent = true
	var consequence := ""
	match structure_id:
		"power_shed":
			consequence = " If it falls, all turrets and shock posts fire slower."
		"silo":
			consequence = " If it falls, the farmhouse takes extra damage from every hit."
		"barn":
			consequence = " If it falls, you lose scrap and the end-of-wave bonus."
	_set_banner("Raiders angle toward the %s.%s" % [_structure_display_name(structure_id), consequence], 3.0)


func _maybe_spawn_midwave_objective() -> void:
	if relay_spawned_for_wave or _has_live_signal_relay():
		return
	if current_wave_index < 0 or current_wave_index >= ACT_ONE_WAVES.size():
		return

	var wave_data: Dictionary = ACT_ONE_WAVES[current_wave_index]
	if not wave_data.has("relay_trigger_spawned"):
		return
	if wave_spawned < int(wave_data["relay_trigger_spawned"]):
		return

	relay_spawned_for_wave = true
	var relay: StaticBody2D = SIGNAL_RELAY_SCENE.instantiate() as StaticBody2D
	relay.position = wave_data.get("relay_position", DRILL_SITE_POS + Vector2(0.0, -92.0))
	relay.configure(
		int(wave_data.get("relay_health", 8)),
		float(wave_data.get("relay_interval", 5.2)),
		float(wave_data.get("relay_boost_multiplier", 1.3)),
		float(wave_data.get("relay_boost_duration", 3.2)),
		float(wave_data.get("relay_drill_boost", 0.0)),
		int(wave_data.get("relay_scrap", 5))
	)
	relay.destroyed.connect(_on_signal_relay_destroyed)
	relay.pulsed.connect(_on_signal_relay_pulsed)
	relay.damaged.connect(_on_objective_damaged)
	add_child(relay)
	current_signal_relay = relay
	active_aliens += 1
	mark_aliens_dirty()
	_refresh_current_objective_text()
	_set_banner("SIGNAL RELAY: Periodically boosts all alien speed and feeds the drill rig. Destroy it to stop the pulses.", 3.5)
	_update_field_signal_state(wave, true)
	_update_hint()


func _pick_enemy_kind() -> String:
	var remaining_slots: int = wave_total_spawns - wave_spawned
	var specialists_remaining: int = wave_drillers_remaining + wave_harriers_remaining + wave_shields_remaining + wave_burrowers_remaining
	if specialists_remaining <= 0:
		return "scout"

	if remaining_slots <= specialists_remaining:
		if wave_harriers_remaining > 0:
			return _consume_specialist_kind("harrier")
		if wave_shields_remaining > 0:
			return _consume_specialist_kind("shield_drone")
		if wave_burrowers_remaining > 0:
			return _consume_specialist_kind("burrower")
		return _consume_specialist_kind("driller")

	var available_specialists: Array[String] = []
	if wave_harriers_remaining > 0 and wave_spawned >= int(floor(float(wave_total_spawns) * 0.25)):
		available_specialists.append("harrier")
	if wave_shields_remaining > 0 and wave_spawned >= int(floor(float(wave_total_spawns) * 0.33)):
		available_specialists.append("shield_drone")
	if wave_burrowers_remaining > 0 and wave_spawned >= int(floor(float(wave_total_spawns) * 0.40)):
		available_specialists.append("burrower")
	if wave_drillers_remaining > 0 and wave_spawned >= int(floor(float(wave_total_spawns) * 0.45)):
		available_specialists.append("driller")

	if available_specialists.is_empty():
		return "scout"

	var selected_kind: String = available_specialists[randi() % available_specialists.size()]
	return _consume_specialist_kind(selected_kind)


func _consume_specialist_kind(selected_kind: String) -> String:
	match selected_kind:
		"harrier":
			wave_harriers_remaining = maxi(0, wave_harriers_remaining - 1)
		"shield_drone":
			wave_shields_remaining = maxi(0, wave_shields_remaining - 1)
		"burrower":
			wave_burrowers_remaining = maxi(0, wave_burrowers_remaining - 1)
		_:
			wave_drillers_remaining = maxi(0, wave_drillers_remaining - 1)
	return selected_kind


func _has_live_drill_site() -> bool:
	return current_drill_site != null and is_instance_valid(current_drill_site)


func _has_live_signal_relay() -> bool:
	return current_signal_relay != null and is_instance_valid(current_signal_relay)


func _has_live_wave_boss() -> bool:
	return current_wave_boss != null and is_instance_valid(current_wave_boss)


func _wave_boss_data() -> Dictionary:
	if current_wave_index < 0 or current_wave_index >= ACT_ONE_WAVES.size():
		return {}

	var wave_data: Dictionary = ACT_ONE_WAVES[current_wave_index]
	if not wave_data.has("boss"):
		return {}
	return wave_data["boss"]


func _live_act_two_objectives() -> Array[StaticBody2D]:
	var live_objectives: Array[StaticBody2D] = []
	for objective in current_act_two_objectives:
		if objective == null or not is_instance_valid(objective):
			continue
		if objective.is_queued_for_deletion():
			continue
		live_objectives.append(objective)
	current_act_two_objectives = live_objectives
	return live_objectives


func _act_two_objective_focus_text() -> String:
	var live_objectives := _live_act_two_objectives()
	if live_objectives.is_empty():
		return ""

	var objective_kind := ""
	if live_objectives[0].has_method("get_objective_kind"):
		objective_kind = live_objectives[0].get_objective_kind()

	match objective_kind:
		"excavation_pylon":
			return "Destroy the excavation pylons before they keep feeding the rig."
		"breach_beacon":
			return "Destroy the breach beacons before they keep lashing the farm."
		"lift_anchor":
			return "Destroy the lift anchors before they patch the rig and relay."
		"command_beacon":
			return "Destroy the command beacons before they drive the breach column harder."
		_:
			return "Destroy the remaining excavation nodes."


func _maybe_spawn_wave_boss() -> void:
	if boss_spawned_for_wave or _has_live_wave_boss():
		return

	var boss_data := _wave_boss_data()
	if boss_data.is_empty():
		return
	if not _live_act_two_objectives().is_empty():
		return

	var wave_boss: CharacterBody2D = BOSS_OVERSEER_SCENE.instantiate() as CharacterBody2D
	wave_boss.position = boss_data.get("position", Vector2(640.0, 188.0))
	if wave_boss.has_method("configure"):
		wave_boss.configure(boss_data)
	wave_boss.destroyed.connect(_on_wave_boss_destroyed)
	wave_boss.damaged.connect(_on_wave_boss_damaged)
	wave_boss.attack_volley.connect(_on_wave_boss_attack_volley)
	wave_boss.command_pulse.connect(_on_wave_boss_command_pulse)
	wave_boss.phase_changed.connect(_on_wave_boss_phase_changed)
	add_child(wave_boss)
	current_wave_boss = wave_boss
	boss_spawned_for_wave = true
	active_aliens += 1
	mark_aliens_dirty()
	_play_positional_sfx(SFX_ALIEN_BRUTE_ROAR, wave_boss.global_position, -8.0, 0.72, 0.82)
	_set_banner("%s drops out of the crater haze. Bring it down before dawn." % String(boss_data.get("name", "Overseer")), 2.5)
	_refresh_current_objective_text()
	_update_hint()
	_update_stats()


func _refresh_current_objective_text() -> void:
	if not wave_active:
		return
	var act_two_focus_text := _act_two_objective_focus_text()
	if act_two_focus_text != "":
		current_objective_text = act_two_focus_text
		return
	if _has_live_wave_boss():
		current_objective_text = "Destroy the Overseer before it tears the farm apart."
		return
	if _has_live_signal_relay():
		if _has_live_drill_site():
			current_objective_text = "Destroy the signal relay before it accelerates the command rig."
		else:
			current_objective_text = "Destroy the signal relay before it boosts the whole lane again."
		return
	if _has_live_drill_site():
		current_objective_text = "Destroy the excavation rig before it breaches the field."
		return
	current_objective_text = base_wave_objective_text


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
	settings_menu_open = false
	prep_phase_active = false
	wave = 2
	current_objective_text = "Choose how Patch helps hold the farm."
	banner_default = "Patch needs a job before the second rush."
	patch_title_label.text = "Choose how Patch grows into the fight"
	patch_body_label.text = "Scrap Hound turns wrecks into bonus salvage. Guard Dog learns stun barks and doubles down on crowd control. Scout Nose uncovers buried stashes, schematics, and upgrades Eli would never find on his own."
	patch_panel.visible = true
	prep_panel.visible = false
	briefing_panel.visible = false
	upgrade_panel.visible = false
	pause_panel.visible = false
	get_tree().paused = true
	banner_label.text = banner_default
	_refresh_support_units()
	queue_redraw()
	_update_hint()
	_update_stats()


func _on_patch_path_selected(selected_path: int) -> void:
	_ensure_audio_started()
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
	prep_phase_active = false
	prep_panel.visible = false
	briefing_panel.visible = false
	patch_panel.visible = false
	pause_panel.visible = false
	get_tree().paused = true
	banner_label.text = banner_default
	_refresh_support_units()
	queue_redraw()
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
				{"id":"scrap_blaster_rig","name":"Scrap Blaster Rig","description":"Build a spread-shot farm blaster. Press Q to swap weapons."},
				{"id":"fence_spools","name":"Fence Spools","description":"Unlock barbed barricades. Press 3 to build them on open pads."}
			]
		4:
			options = [
				{"id":"boot_springs","name":"Boot Springs","description":"Give Eli a faster strafe and retreat pace."},
				{"id":"tractor_cannon_frame","name":"Tractor Cannon Frame","description":"Rig a heavy slug thrower. Press Q to cycle to Eli's heavy gun."},
				_path_upgrade_option_for_wave_four()
			]
		5:
			options = [
				{"id":"redline_tractor","name":"Redline Tractor","description":"Roll a red farm tractor onto the rows. It patrols the field and fires heavy rockets during waves."},
				{"id":"shock_post_kit","name":"Shock Post Kit","description":"Unlock a stun post that cracks shield drones. Press 2 to build it on a pad."},
				{"id":"shock_braid","name":"Shock Braid","description":"Wrap the farm emitters. Built defenses deal more damage."}
			]
		6:
			options = [
				{"id":"storm_dynamo","name":"Storm Dynamo","description":"Turn the whole defense grid up for the final rush."},
				{"id":"hotshot_feed","name":"Hotshot Feed","description":"Make Eli's weapon faster and meaner."},
				_path_upgrade_option_for_wave_six()
			]
		7:
			var wave_seven_option := {"id":"breach_plating","name":"Breach Plating","description":"Brace the farmhouse and harden the defense grid for the excavation front."}
			if rocket_tractor_unlocked:
				wave_seven_option = {"id":"tractor_overdrive","name":"Tractor Overdrive","description":"Tune the red tractor hotter so it patrols faster and fires rockets more often."}
			options = [
				wave_seven_option,
				{"id":"alien_battery_tap","name":"Alien Battery Tap","description":"Steal excavator current for faster shots across Eli and the farm grid."},
				{"id":"barricade_spikes","name":"Barricade Spikes","description":"Rework the fence stock into tougher, meaner barricades."}
			]
		8:
			var wave_eight_option := {"id":"deepcore_slugs","name":"Deepcore Slugs","description":"Load denser scrap into Eli's guns for harder hits in the breach."}
			if rocket_tractor_unlocked:
				wave_eight_option = {"id":"redline_payload","name":"Redline Payload","description":"Pack a heavier rocket into the red tractor's launcher."}
			options = [
				wave_eight_option,
				{"id":"hardline_grid","name":"Hardline Grid","description":"Push the coil and shock network harder for faster, stronger defense fire."},
				{"id":"rebuild_cache","name":"Rebuild Cache","description":"Crack a hidden stockpile for scrap, repairs, and one more round of bracing."}
			]
		9:
			options = [
				{"id":"relay_scrambler","name":"Relay Scrambler","description":"Tune the field against alien signals so Eli and the turrets bite harder."},
				{"id":"heavy_shell_press","name":"Heavy Shell Press","description":"Rework the tractor cannon into a faster, nastier siege gun."},
				{"id":"shock_lattice","name":"Shock Lattice","description":"Stretch the farm shock mesh so posts hit harder and hold aliens longer."}
			]
		10:
			var wave_ten_option := {"id":"mothlight_scope","name":"Mothlight Scope","description":"Line Eli's guns up on the dawn silhouettes for brutal final-shot accuracy."}
			if rocket_tractor_unlocked:
				wave_ten_option = {"id":"tractor_salvo","name":"Tractor Salvo","description":"Rig the red tractor for faster rockets and a heavier final barrage."}
			options = [
				{"id":"dawn_charge","name":"Dawn Charge","description":"Dump every last battery into the farm for the final stand."},
				{"id":"last_siding","name":"Last Siding","description":"Throw every spare board and sheet onto the farm before sunrise hits."},
				wave_ten_option
			]
	if next_wave_number >= 3:
		var structure_option: Dictionary = _structure_repair_option()
		if not structure_option.is_empty() and options.size() >= 3:
			var replace_index := 1
			if next_wave_number == 3:
				replace_index = 0
			elif next_wave_number == 4 and not tractor_cannon_unlocked:
				replace_index = 0
			elif next_wave_number == 5 and not shock_post_unlocked:
				replace_index = 2
			options[replace_index] = structure_option
	return options


func _structure_repair_option() -> Dictionary:
	var structure_id := _priority_structure_to_repair()
	if structure_id == "":
		return {}

	var structure: Node2D = _farm_structure_by_id(structure_id)
	var rebuild: bool = structure != null and structure.is_destroyed()
	match structure_id:
		"power_shed":
			if rebuild:
				return {"id":"repair_power_shed","name":"Spare Generator","description":"Rebuild the power shed and restore defense speed."}
			return {"id":"repair_power_shed","name":"Shed Repairs","description":"Repair the power shed back to full output."}
		"silo":
			if rebuild:
				return {"id":"repair_silo","name":"Silo Rebuild","description":"Raise the silo again so the farmhouse stops taking bonus damage."}
			return {"id":"repair_silo","name":"Silo Bracing","description":"Patch the silo back to full strength before the next hit lands."}
		"barn":
			if rebuild:
				return {"id":"repair_barn","name":"Barn Repair Crew","description":"Rebuild the barn workshop and restore the scrap reserve."}
			return {"id":"repair_barn","name":"Barn Repairs","description":"Fix the barn workshop before the reserve takes more damage."}
		_:
			return {}


func _priority_structure_to_repair() -> String:
	for structure_id in FARM_STRUCTURE_REPAIR_PRIORITY:
		var structure: Node2D = _farm_structure_by_id(structure_id)
		if structure == null:
			continue
		if structure.is_destroyed():
			return structure_id

	var chosen_structure_id := ""
	var lowest_health_ratio := 1.01
	for structure_id in FARM_STRUCTURE_REPAIR_PRIORITY:
		var structure: Node2D = _farm_structure_by_id(structure_id)
		if structure == null:
			continue
		var health_ratio: float = structure.get_health_ratio()
		if health_ratio < 1.0 and health_ratio < lowest_health_ratio:
			lowest_health_ratio = health_ratio
			chosen_structure_id = structure_id
	return chosen_structure_id


func _restore_farm_structure(structure_id: String) -> void:
	var structure: Node2D = _farm_structure_by_id(structure_id)
	if structure == null:
		return

	structure.restore_full()
	if structure_id == "power_shed" or structure_id == "silo":
		_refresh_turret_stats()
	_update_stats()
	queue_redraw()


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
	_ensure_audio_started()
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
			_apply_player_fire_rate_boost(0.03, 0.04)
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
			_apply_player_fire_rate_boost(0.02, 0.02)
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
		"scrap_blaster_rig":
			scrap_blaster_unlocked = true
			current_weapon_id = WEAPON_SCRAP_BLASTER
			_refresh_player_weapon()
			return "Scrap Blaster rigged together. Eli can swap weapons with Q and opens on the lane with a spread shot."
		"fence_spools":
			barricade_unlocked = true
			selected_build_type = BUILD_BARRICADE
			return "Fence Spools unpacked. Press 3 to build barbed barricades that intercept raiders near the farm."
		"coil_molds":
			turret_cost = maxi(4, turret_cost - 1)
			return "Coil Molds finished. New turrets cost %d scrap." % turret_cost
		"repair_barn":
			_restore_farm_structure("barn")
			return "Barn repair crew finishes the workshop. The scrap reserve is back online."
		"repair_power_shed":
			_restore_farm_structure("power_shed")
			return "Spare dynamos are wired in. The power shed is back at full output."
		"repair_silo":
			_restore_farm_structure("silo")
			return "The silo is braced and standing again. The farmhouse loses the bonus damage risk."
		"boot_springs":
			player_move_speed += 24.0
			player.set_move_speed(player_move_speed)
			return "Boot Springs locked in. Eli moves faster between lanes."
		"tractor_cannon_frame":
			tractor_cannon_unlocked = true
			current_weapon_id = WEAPON_TRACTOR_CANNON
			_refresh_player_weapon()
			return "Tractor Cannon frame bolted together. Eli can cycle to a heavy slug thrower with Q."
		"redline_tractor":
			rocket_tractor_unlocked = true
			_spawn_rocket_tractor()
			return "Redline Tractor rolls out onto the field. The red machine patrols the rows and launches heavy rockets each wave."
		"breach_plating":
			base_health += 2
			turret_damage += 1
			_refresh_turret_stats()
			return "Breach Plating locked in. The farmhouse gains 2 base and the defense grid hits harder."
		"tractor_overdrive":
			rocket_tractor_patrol_speed += 18.0
			rocket_tractor_fire_interval = maxf(1.85, rocket_tractor_fire_interval - 0.45)
			_refresh_rocket_tractor_stats()
			return "The red tractor tears up the rows faster now and its rocket rack cycles harder."
		"alien_battery_tap":
			_apply_player_fire_rate_boost(0.02, 0.05)
			turret_fire_interval = maxf(0.36, turret_fire_interval - 0.05)
			shock_post_fire_interval = maxf(0.66, shock_post_fire_interval - 0.08)
			_refresh_turret_stats()
			return "Alien Battery Tap wired in. Eli, the turrets, and the shock posts all fire faster."
		"barricade_spikes":
			barricade_health += 3
			barricade_cost = maxi(4, barricade_cost - 1)
			return "Breach spikes hammered in. Barricades hold longer and now cost %d scrap." % barricade_cost
		"redline_payload":
			rocket_tractor_damage += 2
			rocket_tractor_rocket_speed += 50.0
			_refresh_rocket_tractor_stats()
			return "Redline Payload loaded. The tractor's rockets now hit harder and scream in faster."
		"deepcore_slugs":
			player_bullet_damage += 1
			tractor_cannon_fire_interval = maxf(0.58, tractor_cannon_fire_interval - 0.08)
			_refresh_player_weapon()
			return "Deepcore Slugs pressed. Eli hits harder and the tractor cannon cycles faster."
		"hardline_grid":
			turret_damage += 1
			shock_post_damage += 1
			turret_fire_interval = maxf(0.34, turret_fire_interval - 0.04)
			shock_post_fire_interval = maxf(0.62, shock_post_fire_interval - 0.06)
			_refresh_turret_stats()
			return "Hardline Grid energized. Coil turrets and shock posts both fire faster and hit harder."
		"rebuild_cache":
			scrap += 8
			base_health += 1
			var structure_id := _priority_structure_to_repair()
			if structure_id != "":
				_restore_farm_structure(structure_id)
				return "Rebuild Cache opened. Eli banks 8 scrap, gains 1 base, and patches the %s." % _structure_display_name(structure_id)
			return "Rebuild Cache opened. Eli banks 8 scrap and throws one more layer onto the farmhouse."
		"relay_scrambler":
			player_bullet_damage += 1
			turret_damage += 1
			_refresh_turret_stats()
			return "Relay Scrambler tuned. Eli and the defense grid cut through alien signal shielding harder."
		"heavy_shell_press":
			player_bullet_damage += 1
			tractor_cannon_fire_interval = maxf(0.48, tractor_cannon_fire_interval - 0.10)
			_refresh_player_weapon()
			return "Heavy Shell Press finished. Eli's heavy gun cycles faster and every shot bites deeper."
		"shock_lattice":
			shock_post_damage += 1
			shock_post_stun_duration += 0.15
			_refresh_turret_stats()
			return "Shock Lattice stretched across the farm. Shock posts hold targets longer and hit harder."
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
			shock_post_damage += 1
			_refresh_turret_stats()
			return "Shock Braid wrapped across the farm emitters. Built defenses hit harder."
		"shock_post_kit":
			shock_post_unlocked = true
			selected_build_type = BUILD_SHOCK_POST
			return "Shock Post Kit assembled. Press 2 to build stun posts that strip shield drones and lock the lane down."
		"windmill_dynamo":
			_apply_player_fire_rate_boost(0.015, 0.04)
			turret_fire_interval = maxf(0.44, turret_fire_interval - 0.06)
			shock_post_fire_interval = maxf(0.78, shock_post_fire_interval - 0.10)
			_refresh_turret_stats()
			return "Windmill Dynamo spins up the whole farm grid. Eli and the built defenses fire faster."
		"storm_dynamo":
			turret_fire_interval = maxf(0.38, turret_fire_interval - 0.08)
			turret_damage += 1
			shock_post_fire_interval = maxf(0.70, shock_post_fire_interval - 0.12)
			shock_post_damage += 1
			_refresh_turret_stats()
			return "Storm Dynamo armed. The final defense grid fires faster and harder."
		"dawn_charge":
			base_health += 2
			_apply_player_fire_rate_boost(0.02, 0.05)
			turret_damage += 1
			shock_post_damage += 1
			_refresh_turret_stats()
			return "Dawn Charge dumped into the farm. Eli fires faster, the house holds harder, and the whole grid hits meaner."
		"last_siding":
			base_health += 2
			for structure_id in FARM_STRUCTURE_ORDER:
				_restore_farm_structure(structure_id)
			return "Last Siding nailed in. The farmhouse gains 2 base and the standing structures get rebuilt for dawn."
		"tractor_salvo":
			rocket_tractor_fire_interval = maxf(1.50, rocket_tractor_fire_interval - 0.35)
			rocket_tractor_damage += 1
			_refresh_rocket_tractor_stats()
			return "The red tractor is rigged for a dawn salvo. Rockets cycle faster and hit even harder."
		"mothlight_scope":
			player_bullet_damage += 2
			tractor_cannon_fire_interval = maxf(0.46, tractor_cannon_fire_interval - 0.08)
			_refresh_player_weapon()
			return "Mothlight Scope dialed in. Eli's shots hit much harder and the heavy gun tracks faster."
		"hotshot_feed":
			_apply_player_fire_rate_boost(0.02, 0.05)
			player_bullet_damage += 1
			return "Hotshot Feed loaded. Eli shoots faster and every round bites deeper."
		"forge_crates":
			scrap += 10
			turret_damage += 1
			_refresh_turret_stats()
			return "Forge Crates cracked open. Eli banks 10 scrap and the turret line gets meaner."
		"shock_harness":
			base_health += 2
			_apply_player_fire_rate_boost(0.02, 0.04)
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
			return "Eli kicks apart the first saucer hulls, checks the power shed wiring, then crouches beside Patch to decide what the dog should become."
		3:
			return "The barn lights burn hot while Eli rewires farm junk into weapons. Out in the dark, the aliens start sending real drill teams."
		4:
			match patch_path:
				PatchPath.SCRAP:
					return "Patch starts dragging cleaner cores out of the wreck pile while the buried signal starts pulsing under the north field and scouts start feeling out the barn workshop."
				PatchPath.GUARD:
					return "Patch keeps pacing the lane, waiting to cut off the next rush while harriers start firing from above the rows and raiders edge toward the barn."
				PatchPath.SCOUT:
					return "Patch keeps circling one patch of trampled corn until Eli notices the field markers lining up under the first harrier screen and the barn coming into the attack lane."
				_:
					return "Fresh crop circles point to something buried under the north field while harriers rise over the corn and the barn workshop comes into range."
		5:
			return "The buried signal is fully awake now. Another relay drops near the silo while shield drones screen the lane, burrowers cut under the fence, harriers range the farmhouse, and split raiders push toward the silo and power shed."
		6:
			match patch_path:
				PatchPath.SCRAP:
					return "The salvage pile behind the barn has become a real workshop, and Patch is still dragging in usable alloy while shield drones, burrowers, the final relay, the command rig, and structure raids line up over the field."
				PatchPath.GUARD:
					return "Patch's bark rolls across the lane like thunder. Even the shield drones and burrowers hesitate when he squares up against the final relay, command rig, and the last structure raid."
				PatchPath.SCOUT:
					return "Patch digs up one last sealed cache near the tractor shed, and Eli folds it into the farm's last defenses while shield drones screen the final relay, burrowers tunnel in, and raiders break for every standing building."
				_:
					return "The silo throws long shadows over the field while shield drones, burrowers, a final relay, a command rig, and a structure raid line up the last rush in the sky."
		7:
			var act2_recap := _act_two_interlude_recap()
			return "The command rig blows a trench into the north field and the whole fight changes shape.\n\n%s\n\nThe excavation depth meter now tracks how close the aliens are to extracting what is buried. Every rig pulse, driller feed, and pylon boost pushes it higher. If Eli destroys objectives fast, the meter stays low." % act2_recap
		8:
			return "The breach stays open all night now. Alien columns are marching straight out of the excavation scar, and every rebuild choice starts feeling temporary."
		9:
			return "Patch can smell hot metal and opened earth over the whole north field. Whatever the aliens are lifting is close enough now that the whole farm hums when the relay stacks pulse."
		10:
			return "The last workshop break lands under a sky that is starting to gray. Eli throws every spare board, coil, battery, and shell into one final defense before dawn."
		_:
			return ""


func _refresh_turret_stats() -> void:
	var penalty := not _has_intact_structure("power_shed")
	power_penalty_visual_active = penalty
	silo_penalty_visual_active = not _has_intact_structure("silo")
	for node in get_tree().get_nodes_in_group("turrets"):
		if node.has_method("set_stats"):
			node.set_stats(_effective_turret_fire_interval(), turret_damage)
		if node.has_method("set_power_penalty"):
			node.set_power_penalty(penalty)
	for node in get_tree().get_nodes_in_group("shock_posts"):
		if node.has_method("set_stats"):
			node.set_stats(_effective_shock_post_fire_interval(), shock_post_damage, shock_post_stun_duration)
		if node.has_method("set_power_penalty"):
			node.set_power_penalty(penalty)


func _spawn_bullet(origin: Vector2, direction: Vector2, speed: float, damage: int, lifetime: float = 1.6, radius: float = 6.0, core_color: Color = Color8(255, 241, 196), tail_color: Color = Color8(255, 185, 71), damage_falloff_start: float = -1.0, damage_falloff_end: float = -1.0, minimum_damage: int = 1) -> void:
	var bullet: Area2D = BULLET_SCENE.instantiate() as Area2D
	bullet.global_position = origin
	bullet.configure(direction, speed, damage, lifetime, radius, core_color, tail_color, damage_falloff_start, damage_falloff_end, minimum_damage)
	add_child(bullet)


func _spawn_death_burst(world_position: Vector2, core_color: Color, spark_color: Color, burst_scale: float = 1.0, burst_style: int = 0) -> void:
	var death_burst: Node2D = DEATH_BURST_SCENE.instantiate() as Node2D
	death_burst.global_position = world_position
	if death_burst.has_method("configure"):
		death_burst.configure(core_color, spark_color, burst_scale, burst_style)
	add_child(death_burst)


func _on_player_fired(origin: Vector2, direction: Vector2) -> void:
	if game_over or mission_complete:
		return

	if current_weapon_id == WEAPON_TRACTOR_CANNON:
		_play_positional_sfx(SFX_WEAPON_ROCKET_LAUNCH, origin, -10.0, 0.78, 0.86)
		_spawn_bullet(origin, direction, 520.0, player_bullet_damage + 2, 1.00, 8.0, Color8(255, 215, 132), Color8(208, 112, 62))
		return

	if current_weapon_id == WEAPON_SCRAP_BLASTER:
		_play_positional_sfx(SFX_WEAPON_HEAVY_BLAST, origin, -8.0, 0.90, 0.98)
		for pellet_index in range(SCRAP_BLASTER_PELLET_COUNT):
			var pellet_ratio := 0.0
			if SCRAP_BLASTER_PELLET_COUNT > 1:
				pellet_ratio = float(pellet_index) / float(SCRAP_BLASTER_PELLET_COUNT - 1)
			var pellet_offset := lerpf(-SCRAP_BLASTER_SPREAD, SCRAP_BLASTER_SPREAD, pellet_ratio)
			var pellet_direction: Vector2 = direction.rotated(pellet_offset)
			_spawn_bullet(origin, pellet_direction, 760.0, player_bullet_damage, 0.50, 4.0, Color8(255, 228, 186), Color8(255, 150, 94))
		return

	_play_positional_sfx(SFX_WEAPON_LASER_PEW, origin, -14.0, 0.97, 1.05)
	_spawn_bullet(origin, direction, 860.0, player_bullet_damage, 1.2, 6.0, Color8(255, 241, 196), Color8(255, 185, 71), NAILGUN_FALLOFF_START, NAILGUN_FALLOFF_END, 0)


func _on_build_requested(spot) -> void:
	if game_over or mission_complete:
		return

	if not prep_phase_active:
		_set_banner("Build pads only work during setup breaks between waves.", 1.8)
		return

	if spot.occupied:
		return

	var build_cost: int = _build_cost_for_type(selected_build_type)
	if scrap < build_cost:
		_set_banner("Need %d scrap to wire up a %s." % [build_cost, _build_name_for_type(selected_build_type)], 1.8)
		return

	scrap -= build_cost
	spot.mark_built()

	if selected_build_type == BUILD_SHOCK_POST:
		var shock_post: Node2D = SHOCK_POST_SCENE.instantiate() as Node2D
		shock_post.position = spot.position
		shock_post.configure(_effective_shock_post_fire_interval(), shock_post_damage, shock_post_stun_duration, self)
		shock_post.discharged.connect(_on_shock_post_discharged)
		add_child(shock_post)
		_play_positional_sfx(SFX_WEAPON_HEAVY_BLAST, spot.global_position, -10.0, 0.88, 0.96)
		_set_banner("Shock post online. The lane is going to spark.", 1.8)
	elif selected_build_type == BUILD_BARRICADE:
		var barricade: Node2D = BARRICADE_SCENE.instantiate() as Node2D
		barricade.position = spot.position
		barricade.configure(barricade_health)
		add_child(barricade)
		_play_positional_sfx(SFX_WEAPON_HEAVY_BLAST, spot.global_position, -12.0, 0.84, 0.92)
		_set_banner("Barbed barricade hammered in. Raiders will have to chew through it first.", 1.9)
	else:
		var turret: Node2D = TURRET_SCENE.instantiate() as Node2D
		turret.position = spot.position
		turret.configure(BULLET_SCENE, _effective_turret_fire_interval(), turret_damage, self)
		turret.fired_shot.connect(_on_turret_fired)
		add_child(turret)
		_play_positional_sfx(SFX_WEAPON_HEAVY_BLAST, spot.global_position, -12.0, 1.00, 1.06)
		_set_banner("Coil turret online. Keep the lane clear.", 1.8)

	_update_hint()
	_update_stats()


func _on_alien_destroyed(scrap_value: int, world_position: Vector2) -> void:
	if game_over:
		return

	active_aliens = maxi(0, active_aliens - 1)
	mark_aliens_dirty()
	_spawn_death_burst(world_position, Color8(255, 222, 170), Color8(124, 255, 188), 1.0)
	_play_positional_sfx(SFX_ALIEN_DEATH, world_position, -10.0, 0.94, 1.04)

	var total_scrap: int = scrap_value
	var salvage_bonus := 0
	if patch_path == PatchPath.SCRAP and dog != null and is_instance_valid(dog):
		salvage_bonus = dog.claim_salvage_bonus()
		total_scrap += salvage_bonus

	scrap += total_scrap
	kills += 1
	_spawn_damage_number(world_position, "+%d" % total_scrap, Color8(255, 222, 120))
	combo_count += 1
	combo_timer = COMBO_WINDOW
	if combo_count == 3:
		scrap += 2
		_set_banner("TRIPLE KILL! +2 bonus scrap.", 2.0)
	elif combo_count == 5:
		scrap += 3
		_set_banner("5x STREAK! +3 bonus scrap.", 2.0)
	elif combo_count == 8:
		scrap += 5
		_set_banner("8x RAMPAGE! +5 bonus scrap.", 2.2)
	elif combo_count > 8 and combo_count % 4 == 0:
		scrap += 4
		_set_banner("%dx MASSACRE! +4 bonus scrap." % combo_count, 2.2)
	elif salvage_bonus > 0 and kills % 4 == 0:
		_set_banner("Patch strips extra alloy from the crash site.", 1.5)
	elif patch_path == PatchPath.SCOUT and kills % 8 == 0:
		_set_banner("Patch sniffs the field for buried stashes.", 1.5)
	elif kills % 6 == 0:
		_set_banner("Patch drags another chunk of saucer junk into the dirt.", 1.8)
	_update_stats()
	_queue_wave_completion_check()


func _on_alien_drill_site_reached(progress_boost: float) -> void:
	if game_over:
		return

	active_aliens = maxi(0, active_aliens - 1)
	mark_aliens_dirty()
	if _has_live_drill_site():
		current_drill_site.boost_progress(progress_boost)
		if game_over:
			return
		if _act_two_active():
			excavation_depth = minf(EXCAVATION_MAX, excavation_depth + progress_boost * 0.15)
			queue_redraw()
		_set_banner("A driller fed the north-field rig.", 1.6)
	_update_stats()
	_queue_wave_completion_check()


func _on_alien_structure_hit(structure_id: String, damage: int) -> void:
	if game_over:
		return

	active_aliens = maxi(0, active_aliens - 1)
	mark_aliens_dirty()
	_damage_farm_structure(structure_id, damage)
	_update_stats()
	_queue_wave_completion_check()


func _on_alien_damaged(world_position: Vector2, enemy_kind: String) -> void:
	var volume_db := -14.0
	var pitch_min := 0.96
	var pitch_max := 1.05
	if enemy_kind == "driller":
		volume_db = -10.0
		pitch_min = 0.88
		pitch_max = 0.96
	_play_positional_sfx(SFX_ALIEN_HURT, world_position, volume_db, pitch_min, pitch_max)


func _on_alien_ranged_attack(origin: Vector2, target_position: Vector2, damage: int, projectile_speed: float, target_structure_id: String) -> void:
	if game_over or mission_complete:
		return

	_spawn_enemy_bolt(origin, target_position, projectile_speed, damage, target_structure_id)
	_play_positional_sfx(SFX_WEAPON_ROCKET_LAUNCH, origin, -13.0, 0.92, 1.00)


func _spawn_enemy_bolt(origin: Vector2, target_position: Vector2, projectile_speed: float, damage: int, target_structure_id: String) -> void:
	var enemy_bolt: Area2D = ENEMY_BOLT_SCENE.instantiate() as Area2D
	enemy_bolt.configure(origin, target_position, projectile_speed, damage, target_structure_id)
	enemy_bolt.impacted.connect(_on_enemy_bolt_impacted)
	add_child(enemy_bolt)


func _on_turret_fired(origin: Vector2) -> void:
	_play_positional_sfx(SFX_WEAPON_LASER_PEW, origin, -20.0, 1.02, 1.08)


func _on_rocket_tractor_launched(origin: Vector2) -> void:
	_play_positional_sfx(SFX_WEAPON_ROCKET_LAUNCH, origin, -9.0, 0.86, 0.94)


func _on_shock_post_discharged(origin: Vector2) -> void:
	_play_positional_sfx(SFX_WEAPON_HEAVY_BLAST, origin, -16.0, 0.94, 1.02)


func _on_dog_barked(world_position: Vector2) -> void:
	_play_positional_sfx(SFX_DOG_BARK_ALERT, world_position, -13.0, 0.98, 1.05)


func _on_dog_growled(world_position: Vector2) -> void:
	_play_positional_sfx(SFX_DOG_GROWL_GUARD, world_position, -18.0, 0.94, 1.02)


func _on_alien_farmhouse_hit(damage: int) -> void:
	if game_over:
		return

	active_aliens = maxi(0, active_aliens - 1)
	mark_aliens_dirty()
	base_health -= damage + _farmhouse_damage_bonus()
	if base_health <= 0:
		_trigger_game_over("The farmhouse is gone. Reset and hold the line again.")
	else:
		_play_positional_sfx(SFX_WEAPON_HEAVY_BLAST, FARMHOUSE_POS, -18.0, 0.88, 0.96)
		_set_banner("The farmhouse took a hit!", 1.4)
		_spawn_damage_number(FARMHOUSE_POS, "-%d" % (damage + _farmhouse_damage_bonus()), Color8(255, 92, 72), 18)
		_trigger_shake(3.0)
		_update_stats()
		_queue_wave_completion_check()


func _on_enemy_bolt_impacted(damage: int, target_structure_id: String) -> void:
	if game_over:
		return

	if target_structure_id != "":
		_damage_farm_structure(target_structure_id, damage, true)
		return

	base_health -= damage + _farmhouse_damage_bonus()
	if base_health <= 0:
		_trigger_game_over("Harrier fire tore the farmhouse apart. Reset and hold the line again.")
	else:
		_play_positional_sfx(SFX_WEAPON_HEAVY_BLAST, FARMHOUSE_POS, -16.0, 0.90, 0.98)
		_set_banner("A harrier bolt slammed into the farmhouse.", 1.4)
		_update_stats()


func _damage_farm_structure(structure_id: String, damage: int, _ranged_hit: bool = false) -> void:
	var structure: Node2D = _farm_structure_by_id(structure_id)
	if structure == null or structure.is_destroyed():
		return

	structure.take_damage(damage)


func _on_farm_structure_damaged(structure_id: String, world_position: Vector2) -> void:
	if game_over:
		return

	_play_positional_sfx(SFX_WEAPON_HEAVY_BLAST, world_position, -18.0, 0.92, 1.00)
	_set_banner("%s takes a hit." % _structure_display_name(structure_id), 1.3)
	_spawn_damage_number(world_position, "-1", Color8(255, 142, 82))
	_update_stats()


func _on_farm_structure_destroyed(structure_id: String, world_position: Vector2) -> void:
	if game_over:
		return

	_play_positional_sfx(SFX_WEAPON_HEAVY_BLAST, world_position, -12.0, 0.84, 0.94)
	match structure_id:
		"barn":
			var lost_scrap := mini(scrap, 4)
			scrap = maxi(0, scrap - lost_scrap)
			_set_banner("Barn workshop lost. Eli drops %d scrap and the reserve is gone." % lost_scrap, 2.2)
		"power_shed":
			_refresh_turret_stats()
			_set_banner("Power shed wrecked. Farm defenses cycle slower now.", 2.2)
		"silo":
			silo_penalty_visual_active = true
			_set_banner("Silo shattered. Every farmhouse hit will land harder.", 2.2)
		_:
			_set_banner("%s lost." % _structure_display_name(structure_id), 2.0)
	_trigger_shake(5.0, 6.0)
	if audio_manager != null:
		audio_manager.pulse_intensity(0.4)
	_update_hint()
	_update_stats()


func _on_objective_damaged(_world_position: Vector2) -> void:
	if game_over:
		return
	_update_stats()


func _apply_enemy_frenzy(source_name: String, boost_multiplier: float, boost_duration: float, drill_boost: float) -> bool:
	var boosted_enemies := 0
	for node in get_tree().get_nodes_in_group("aliens"):
		if node == current_signal_relay or node == current_wave_boss:
			continue
		if node.has_method("apply_signal_boost"):
			node.apply_signal_boost(boost_duration, boost_multiplier)
			boosted_enemies += 1

	var boosted_drill := false
	if drill_boost > 0.0 and _has_live_drill_site():
		current_drill_site.boost_progress(drill_boost)
		if game_over:
			return true
		boosted_drill = true
		if _act_two_active():
			excavation_depth = minf(EXCAVATION_MAX, excavation_depth + drill_boost * 0.1)
			queue_redraw()

	if boosted_enemies > 0 and boosted_drill:
		_set_banner("%s drives the breach column and the rig together." % source_name, 1.8)
		return true
	if boosted_enemies > 0:
		_set_banner("%s drives the whole lane into a frenzy." % source_name, 1.8)
		return true
	if boosted_drill:
		_set_banner("%s feeds the final excavation push." % source_name, 1.8)
		return true
	return false


func _on_act_two_objective_destroyed(scrap_value: int, world_position: Vector2, _objective_id: String, display_name: String, objective_kind: String) -> void:
	if game_over:
		return

	active_aliens = maxi(0, active_aliens - 1)
	mark_aliens_dirty()
	scrap += scrap_value

	var burst_core := Color8(255, 214, 132)
	var burst_spark := Color8(255, 118, 74)
	var burst_scale := 1.18
	var burst_style := 1
	match objective_kind:
		"breach_beacon":
			burst_core = Color8(255, 172, 118)
			burst_spark = Color8(255, 98, 86)
			burst_style = 4
		"lift_anchor":
			burst_core = Color8(140, 232, 255)
			burst_spark = Color8(246, 190, 124)
			burst_style = 3
		"command_beacon":
			burst_core = Color8(202, 228, 255)
			burst_spark = Color8(210, 120, 255)
			burst_scale = 1.30
			burst_style = 2
	_spawn_death_burst(world_position, burst_core, burst_spark, burst_scale, burst_style)
	_play_positional_sfx(SFX_WEAPON_HEAVY_BLAST, world_position, -10.0, 0.82, 0.92)
	_set_banner("%s destroyed." % display_name, 1.7)
	_maybe_spawn_wave_boss()
	_refresh_current_objective_text()
	_update_hint()
	_update_stats()
	_queue_wave_completion_check()


func _on_act_two_objective_pulsed(_objective_id: String, display_name: String, objective_kind: String, effect_kind: String, primary_value: float, secondary_value: float, tertiary_value: float, target_structure_id: String, world_position: Vector2) -> void:
	if game_over or mission_complete:
		return

	var effect_triggered := false
	match effect_kind:
		"drill_boost":
			if _has_live_drill_site():
				current_drill_site.boost_progress(primary_value)
				if game_over:
					return
				_set_banner("%s feeds the excavation rig." % display_name, 1.6)
				effect_triggered = true
		"structure_strike":
			var strike_damage := maxi(1, int(round(primary_value)))
			if target_structure_id != "" and _has_intact_structure(target_structure_id):
				_damage_farm_structure(target_structure_id, strike_damage, true)
				_set_banner("%s lashes the %s." % [display_name, _structure_display_name(target_structure_id)], 1.6)
				effect_triggered = true
			else:
				base_health -= strike_damage + _farmhouse_damage_bonus()
				if base_health <= 0:
					_trigger_game_over("%s punched through the ruined line and the farmhouse fell." % display_name)
					return
				_set_banner("%s lashes the farmhouse." % display_name, 1.6)
				effect_triggered = true
		"repair_objectives":
			var repaired_bits: Array[String] = []
			var rig_repair := maxi(0, int(round(primary_value)))
			var relay_repair := maxi(0, int(round(secondary_value)))
			if _has_live_drill_site() and rig_repair > 0:
				current_drill_site.repair(rig_repair)
				repaired_bits.append("rig")
			if _has_live_signal_relay() and relay_repair > 0:
				current_signal_relay.repair(relay_repair)
				repaired_bits.append("relay")
			if not repaired_bits.is_empty():
				_set_banner("%s patches the %s." % [display_name, " and ".join(repaired_bits)], 1.7)
				effect_triggered = true
		"frenzy":
			effect_triggered = _apply_enemy_frenzy(display_name, primary_value, secondary_value, tertiary_value)

	if effect_triggered:
		var pulse_volume := -14.0
		if objective_kind == "command_beacon":
			pulse_volume = -11.5
		_play_positional_sfx(SFX_ALIEN_CHITTER_IDLE, world_position, pulse_volume, 0.80, 0.90)
		_update_stats()


func _next_wave_boss_target() -> Dictionary:
	var target_order: Array[String] = ["power_shed", "barn", "silo", ""]
	var target_count := target_order.size()
	for offset in range(target_count):
		var target_id: String = target_order[(boss_target_cycle + offset) % target_count]
		if target_id == "":
			boss_target_cycle = (boss_target_cycle + offset + 1) % target_count
			return {
				"position": FARMHOUSE_POS + Vector2(randf_range(-42.0, 42.0), randf_range(-20.0, 16.0)),
				"target_structure_id": "",
			}
		if _has_intact_structure(target_id):
			boss_target_cycle = (boss_target_cycle + offset + 1) % target_count
			return {
				"position": _structure_target_position(target_id) + Vector2(randf_range(-22.0, 22.0), randf_range(-18.0, 18.0)),
				"target_structure_id": target_id,
			}

	return {
		"position": FARMHOUSE_POS,
		"target_structure_id": "",
	}


func _on_wave_boss_attack_volley(_display_name: String, origin: Vector2, shot_count: int, damage: int, projectile_speed: float) -> void:
	if game_over or mission_complete:
		return

	for shot_index in range(shot_count):
		var target_package := _next_wave_boss_target()
		var muzzle_offset := Vector2(lerpf(-18.0, 18.0, float(shot_index) / float(maxi(1, shot_count - 1))), randf_range(-4.0, 6.0))
		_spawn_enemy_bolt(origin + muzzle_offset, target_package["position"], projectile_speed, damage, target_package["target_structure_id"])
	_play_positional_sfx(SFX_WEAPON_ROCKET_LAUNCH, origin, -7.0, 0.74, 0.82)


func _on_wave_boss_command_pulse(display_name: String, world_position: Vector2, boost_multiplier: float, boost_duration: float, drill_boost: float) -> void:
	if game_over or mission_complete:
		return
	if _apply_enemy_frenzy(display_name, boost_multiplier, boost_duration, drill_boost):
		_play_positional_sfx(SFX_ALIEN_CHITTER_IDLE, world_position, -11.0, 0.72, 0.82)
		_update_stats()


func _on_wave_boss_phase_changed(display_name: String, world_position: Vector2) -> void:
	if game_over:
		return

	_play_positional_sfx(SFX_ALIEN_BRUTE_ROAR, world_position, -7.0, 0.82, 0.90)
	_set_banner("%s armor cracks open. Its fire pattern gets nastier." % display_name, 2.1)


func _on_wave_boss_damaged(world_position: Vector2) -> void:
	_play_positional_sfx(SFX_ALIEN_HURT, world_position, -8.0, 0.76, 0.86)


func _on_wave_boss_destroyed(scrap_value: int, world_position: Vector2) -> void:
	if game_over:
		return

	active_aliens = maxi(0, active_aliens - 1)
	mark_aliens_dirty()
	current_wave_boss = null
	scrap += scrap_value
	_spawn_death_burst(world_position, Color8(255, 214, 168), Color8(196, 132, 255), 1.75, 2)
	_play_positional_sfx(SFX_ALIEN_DEATH, world_position, -6.0, 0.70, 0.80)
	_play_positional_sfx(SFX_WEAPON_HEAVY_BLAST, world_position, -5.0, 0.76, 0.84)
	_set_banner("The Overseer drops into the crater in pieces.", 2.4)
	_refresh_current_objective_text()
	_update_hint()
	_update_stats()
	_queue_wave_completion_check()


func _on_drill_site_destroyed(scrap_value: int, world_position: Vector2) -> void:
	if game_over:
		return

	active_aliens = maxi(0, active_aliens - 1)
	mark_aliens_dirty()
	current_drill_site = null
	scrap += scrap_value
	_spawn_death_burst(world_position, Color8(255, 188, 122), Color8(214, 92, 74), 1.55, 1)
	_play_positional_sfx(SFX_WEAPON_HEAVY_BLAST, world_position, -8.0, 0.84, 0.92)
	_set_banner("North-field drill rig destroyed.", 2.0)
	_refresh_current_objective_text()
	_update_field_signal_state(wave, wave >= 4)
	_update_hint()
	_update_stats()
	_queue_wave_completion_check()


func _on_drill_site_breached() -> void:
	if game_over:
		return

	active_aliens = maxi(0, active_aliens - 1)
	mark_aliens_dirty()
	current_drill_site = null
	_update_field_signal_state(wave, true)
	_trigger_shake(8.0, 4.0)
	_trigger_game_over("North field breached. The aliens drilled into what was buried below.")


func _on_signal_relay_pulsed(boost_multiplier: float, boost_duration: float, drill_boost: float) -> void:
	if game_over or mission_complete or not _has_live_signal_relay():
		return

	var boosted_enemies := 0
	for node in get_tree().get_nodes_in_group("aliens"):
		if node == current_signal_relay:
			continue
		if node.has_method("apply_signal_boost"):
			node.apply_signal_boost(boost_duration, boost_multiplier)
			boosted_enemies += 1

	var boosted_drill := false
	if drill_boost > 0.0 and _has_live_drill_site():
		current_drill_site.boost_progress(drill_boost)
		if game_over:
			return
		boosted_drill = true

	_play_positional_sfx(SFX_ALIEN_CHITTER_IDLE, current_signal_relay.global_position, -14.0, 0.82, 0.90)
	if boosted_enemies > 0 and boosted_drill:
		_set_banner("Relay pulse! All aliens move faster and the rig gains progress. Destroy the relay to stop this.", 2.2)
	elif boosted_enemies > 0:
		_set_banner("Relay pulse! All aliens speed up. Destroy the relay to stop the boosts.", 2.2)
	elif boosted_drill:
		_set_banner("Relay pulse surges into the north-field rig.", 1.6)


func _on_signal_relay_destroyed(scrap_value: int, world_position: Vector2) -> void:
	if game_over:
		return

	active_aliens = maxi(0, active_aliens - 1)
	mark_aliens_dirty()
	current_signal_relay = null
	scrap += scrap_value
	_spawn_death_burst(world_position, Color8(188, 240, 255), Color8(194, 124, 230), 1.35, 3)
	_play_positional_sfx(SFX_WEAPON_HEAVY_BLAST, world_position, -9.0, 0.82, 0.90)
	_refresh_current_objective_text()
	_set_banner("Signal relay destroyed. The lane drops out of sync.", 1.9)
	_update_field_signal_state(wave, _has_live_drill_site() or wave >= 4)
	_update_hint()
	_update_stats()
	_queue_wave_completion_check()


func _live_threat_count() -> int:
	var live_threats := 0
	for node in get_tree().get_nodes_in_group("aliens"):
		if node == null or not is_instance_valid(node):
			continue
		if node.is_queued_for_deletion():
			continue
		live_threats += 1
	return live_threats


func _queue_wave_completion_check() -> void:
	call_deferred("_check_wave_completion")


func _check_wave_completion() -> void:
	if not wave_active or game_over:
		return
	if wave_spawned < wave_total_spawns or _live_threat_count() > 0:
		return

	active_aliens = 0
	wave_active = false
	spawn_timer.stop()
	current_objective_text = "Wave %d secure. Eli and Patch reset the fence line." % wave
	wave_clear_farm_text = _wave_clear_farm_text()
	_update_hint()
	_update_stats()

	if current_wave_index == ACT_ONE_WAVES.size() - 1:
		_show_mission_complete()
		return

	_show_wave_complete_summary()


func _show_wave_complete_summary() -> void:
	wave_clear_pending = true
	settings_menu_open = false
	prep_phase_active = false
	_clear_scout_caches()

	var summary := "Wave %d cleared." % wave
	var structures_standing := 0
	for structure_id in FARM_STRUCTURE_ORDER:
		if _has_intact_structure(structure_id):
			structures_standing += 1
	summary += " Kills: %d. Scrap: %d. Base: %d. Structures: %d/3." % [kills, scrap, base_health, structures_standing]
	if wave_clear_farm_text != "":
		summary += "\n\n%s" % wave_clear_farm_text

	banner_default = "Wave %d complete." % wave
	briefing_title_label.text = "Wave %d Complete" % wave
	briefing_body_label.text = summary
	briefing_footer_label.text = "Take a moment, then head to the workshop."
	briefing_continue_button.text = "Continue to Workshop"
	briefing_panel.visible = true
	prep_panel.visible = false
	upgrade_panel.visible = false
	patch_panel.visible = false
	pause_panel.visible = false
	get_tree().paused = true
	banner_label.text = banner_default
	_refresh_support_units()
	queue_redraw()
	_update_hint()
	_update_stats()


func _show_mission_complete() -> void:
	mission_complete = true
	settings_menu_open = false
	prep_phase_active = false
	wave_active = false
	spawn_timer.stop()
	banner_timer.stop()
	current_objective_text = "Campaign complete. Eli and Patch hold Miller Farm until dawn."
	banner_default = "Act 2 complete: Miller Farm survives until dawn."
	banner_label.text = banner_default
	briefing_title_label.text = "Act 2 Complete: Dawn Over Miller Farm"
	var rating := _campaign_rating()
	var stats_text := _campaign_stats_text()
	briefing_body_label.text = "The last extraction rig folds into the crater as the first sunlight reaches the barn roof. Eli and Patch keep the farmhouse standing through the whole invasion night, and the field finally goes quiet.\n\n%s\n\n%s\nDefense rating: %s" % [_mission_outro_for_patch(), stats_text, rating]
	briefing_footer_label.text = "Acts 1 and 2 are complete. Restart the campaign to defend Miller Farm again."
	briefing_continue_button.text = "Restart Campaign"
	briefing_panel.visible = true
	prep_panel.visible = false
	upgrade_panel.visible = false
	patch_panel.visible = false
	pause_panel.visible = false
	get_tree().paused = true
	_update_field_signal_state(wave, true)
	_refresh_support_units()
	queue_redraw()
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


func _act_two_interlude_recap() -> String:
	var structures_standing := 0
	for structure_id in FARM_STRUCTURE_ORDER:
		if _has_intact_structure(structure_id):
			structures_standing += 1
	var recap := "Act 1 recap: Eli held the farm through 6 waves with %d kills, %d scrap on hand, and %d/3 structures still standing." % [kills, scrap, structures_standing]
	match patch_path:
		PatchPath.SCRAP:
			recap += " Patch's scrap hound instincts kept the war chest full."
		PatchPath.GUARD:
			recap += " Patch's guard bark kept the lanes locked down."
		PatchPath.SCOUT:
			recap += " Patch's scout nose uncovered buried caches across the field."
	return recap


func _campaign_stats_text() -> String:
	var structures_standing := 0
	for structure_id in FARM_STRUCTURE_ORDER:
		if _has_intact_structure(structure_id):
			structures_standing += 1
	return "Kills: %d. Scrap earned: %d. Base remaining: %d. Structures standing: %d/3. Excavation depth: %d%%." % [
		kills, scrap, base_health, structures_standing, int(round(excavation_depth))
	]


func _campaign_rating() -> String:
	var structures_standing := 0
	for structure_id in FARM_STRUCTURE_ORDER:
		if _has_intact_structure(structure_id):
			structures_standing += 1
	if base_health >= 8 and structures_standing == 3 and excavation_depth < 30.0:
		return "IRONCLAD"
	if base_health >= 5 and structures_standing >= 2:
		return "STEADY"
	if base_health >= 2 and structures_standing >= 1:
		return "BATTERED"
	return "BARELY STANDING"


func _trigger_game_over(reason: String) -> void:
	game_over = true
	_trigger_shake(10.0, 3.0)
	combo_count = 0
	combo_timer = 0.0
	settings_menu_open = false
	prep_phase_active = false
	wave_active = false
	base_health = 0
	spawn_timer.stop()
	banner_timer.stop()
	upgrade_panel.visible = false
	prep_panel.visible = false
	patch_panel.visible = false
	pause_panel.visible = false
	banner_default = "Farm overrun. Miller Farm falls unless Eli starts over."
	banner_label.text = banner_default
	current_objective_text = reason
	briefing_title_label.text = "Farm Overrun"
	briefing_body_label.text = "%s\n\nThe farmhouse is lost. Eli and Patch have to reset the defense and try the night again." % reason
	briefing_footer_label.text = "Use the button below to restart. R also restarts the run."
	briefing_continue_button.text = "Restart Defense"
	briefing_panel.visible = true
	get_tree().paused = true
	_update_field_signal_state(wave, true)
	_refresh_support_units()
	queue_redraw()
	_update_hint()
	_update_stats()


func _set_banner(text: String, duration: float = 2.0) -> void:
	banner_label.text = text
	if duration > 0.0:
		banner_timer.start(duration)


func _restore_banner() -> void:
	banner_label.text = banner_default


func _trigger_shake(intensity: float = 4.0, decay: float = 8.0) -> void:
	shake_intensity = maxf(shake_intensity, intensity)
	shake_decay = decay


func _spawn_damage_number(world_position: Vector2, text: String, color: Color = Color8(255, 255, 255), font_size: int = 16) -> void:
	var number: Node2D = DAMAGE_NUMBER_SCENE.instantiate() as Node2D
	number.global_position = world_position + Vector2(randf_range(-12.0, 12.0), randf_range(-8.0, 4.0))
	number.configure(text, color, 1.0, font_size)
	add_child(number)


func _wave_clear_farm_text() -> String:
	if current_wave_index <= 0 or current_wave_index >= ACT_ONE_WAVES.size() - 1:
		return ""
	if not _has_intact_structure("barn"):
		return ""

	scrap += BARN_SURVIVAL_BONUS
	return "The barn workshop stays intact, so Eli pulls %d scrap from the reserve before the next wave." % BARN_SURVIVAL_BONUS


func _update_stats() -> void:
	var threats_remaining: int = _threats_remaining()
	stats_label.text = "Scrap %02d  Base %02d  Wave %02d/%02d  Threat %02d  Gun %s  Patch %s" % [scrap, base_health, maxi(1, wave), ACT_ONE_WAVES.size(), threats_remaining, _current_weapon_name(), _patch_summary()]
	if combo_count >= 2 and combo_timer > 0.0:
		stats_label.text += "  Combo x%d" % combo_count
	var farm_text := _farm_status_text()
	var objective_status := _objective_status_text()
	if objective_status != "":
		if farm_text != "":
			farm_text += "  |  "
		farm_text += objective_status
	farm_status_label.text = farm_text
	if prep_phase_active:
		_refresh_prep_panel()


func _threats_remaining() -> int:
	if not wave_active:
		return 0
	return _live_threat_count() + maxi(0, wave_total_spawns - wave_spawned)


func _objective_status_text() -> String:
	var status_text := ""
	if _has_live_drill_site():
		status_text = "Rig %02d/%02d %02d%%" % [
			current_drill_site.get_health(),
			current_drill_site.get_max_health(),
			int(round(current_drill_site.get_progress_ratio() * 100.0))
		]
	if _has_live_signal_relay():
		var relay_text := "Relay %02d/%02d" % [
			current_signal_relay.get_health(),
			current_signal_relay.get_max_health()
		]
		if status_text != "":
			status_text += "  "
		status_text += relay_text
	if _has_live_wave_boss():
		var boss_label := "Boss %02d/%02d" % [
			current_wave_boss.get_health(),
			current_wave_boss.get_max_health()
		]
		if status_text != "":
			status_text += "  "
		status_text += boss_label
	var live_act_two_objectives := _live_act_two_objectives()
	if not live_act_two_objectives.is_empty():
		var objective_bits: Array[String] = []
		for objective in live_act_two_objectives:
			if objective.has_method("get_status_text"):
				objective_bits.append(objective.get_status_text())
		if not objective_bits.is_empty():
			if status_text != "":
				status_text += "  "
			status_text += "  ".join(objective_bits)
	return status_text


func _farm_status_text() -> String:
	var status_bits: Array[String] = []
	for structure_id in FARM_STRUCTURE_ORDER:
		var structure: Node2D = _farm_structure_by_id(structure_id)
		if structure == null:
			continue

		var prefix := "Barn"
		match structure_id:
			"power_shed":
				prefix = "Shed"
			"silo":
				prefix = "Silo"
		if structure.is_destroyed():
			status_bits.append("%s OUT" % prefix)
		else:
			status_bits.append("%s %d/%d" % [prefix, structure.get_health(), structure.get_max_health()])

	if status_bits.is_empty():
		return ""
	var farm_text := "Farm " + "  ".join(status_bits)
	if _act_two_active() and excavation_depth > 0.0:
		farm_text += "  Depth %d%%" % int(round(excavation_depth))
	if power_penalty_visual_active:
		farm_text += "  [SLOW]"
	if silo_penalty_visual_active:
		farm_text += "  [VULN]"
	return farm_text


func _update_hint() -> void:
	if title_panel != null and title_panel.visible:
		hint_label.text = "Choose Auto, Desktop, or Touch before the first wave starts."
		_refresh_touch_hud()
		return

	if settings_menu_open:
		hint_label.text = "Defense paused. Resume, restart, switch control mode, or tune music and SFX."
		_refresh_touch_hud()
		return

	if mission_complete:
		hint_label.text = "Campaign complete. Press R or use the panel to restart the defense."
		_refresh_touch_hud()
		return

	if game_over:
		hint_label.text = "Farm overrun. Restart with R or use the restart panel."
		_refresh_touch_hud()
		return

	var hint_text := "Objective: %s" % current_objective_text
	if touch_controls_active:
		hint_text += "   Left Pad Move   Right Pad Aim/Fire   Tap Build Pad Place"
		if _weapon_swap_available():
			hint_text += "   Weapon Button Swap"
		hint_text += "   Pause Button Menu"
		if prep_phase_active:
			if shock_post_unlocked and barricade_unlocked:
				hint_text += "   Build Buttons: Coil Turret / Shock Post / Fence"
			elif shock_post_unlocked:
				hint_text += "   Build Buttons: Coil Turret / Shock Post"
			elif barricade_unlocked:
				hint_text += "   Build Buttons: Coil Turret / Fence"
			else:
				hint_text += "   Build Button: Coil Turret"
		else:
			hint_text += "   Build During Setup Breaks Only"
	else:
		hint_text += "   WASD/Arrows Move   Mouse/Space Fire"
		if _weapon_swap_available():
			hint_text += "   Q Swap Gun"
		hint_text += "   Esc Menu"
		if prep_phase_active:
			hint_text += "   Click Pad Build"
			if shock_post_unlocked and barricade_unlocked:
				hint_text += "   1 Coil Turret(%d) 2 Shock Post(%d) 3 Fence(%d)" % [turret_cost, shock_post_cost, barricade_cost]
			elif shock_post_unlocked:
				hint_text += "   1 Coil Turret(%d) 2 Shock Post(%d)" % [turret_cost, shock_post_cost]
			elif barricade_unlocked:
				hint_text += "   1 Coil Turret(%d) 3 Fence(%d)" % [turret_cost, barricade_cost]
			else:
				hint_text += "   Coil Turret(%d)" % turret_cost
		else:
			hint_text += "   Build During Setup Breaks Only"
	hint_text += "   R Restart"
	hint_label.text = hint_text
	_refresh_touch_hud()


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


func _act_two_active() -> bool:
	return wave >= 7 or current_wave_index >= 6 or mission_complete


func _background_scale(viewport_size: Vector2) -> Vector2:
	return Vector2(viewport_size.x / WORLD_SIZE.x, viewport_size.y / WORLD_SIZE.y)


func _bg_point(point: Vector2, scale: Vector2) -> Vector2:
	return Vector2(point.x * scale.x, point.y * scale.y)


func _bg_size(size: Vector2, scale: Vector2) -> Vector2:
	return Vector2(size.x * scale.x, size.y * scale.y)


func _bg_rect(rect: Rect2, scale: Vector2) -> Rect2:
	return Rect2(_bg_point(rect.position, scale), _bg_size(rect.size, scale))


func _bg_radius(radius: float, scale: Vector2) -> float:
	return radius * minf(scale.x, scale.y)


func _bg_thickness(width: float, scale: Vector2) -> float:
	return width * ((scale.x + scale.y) * 0.5)


func _story_text_for_wave(current_wave: int) -> String:
	match current_wave:
		1:
			return "Wave 1: Eli and Patch hear the first saucers over Miller Farm."
		2:
			match patch_path:
				PatchPath.SCRAP:
					return "Wave 2: Patch starts pulling clean alloy while raiders angle toward the power shed."
				PatchPath.GUARD:
					return "Wave 2: Patch locks onto the fence line as raiders test the power shed."
				PatchPath.SCOUT:
					return "Wave 2: Patch starts sniffing around the north field markers while a driller brute and power-shed raiders test the lane."
				_:
					return "Wave 2: Eli decides what kind of war dog Patch needs to become while the power shed draws fire."
		3:
			return "Wave 3: The first north-field drill rig locks into the soil."
		4:
			match patch_path:
				PatchPath.SCOUT:
					return "Wave 4: Patch tracks the crop circles while a relay mast and barn raiders screen the buried signal."
				PatchPath.SCRAP:
					return "Wave 4: Eli and Patch turn the wreck pile into a real war chest under the first relay pulse and the raid on the barn."
				PatchPath.GUARD:
					return "Wave 4: Patch starts controlling the lane while a relay mast and barn raiders cut over the rows."
				_:
					return "Wave 4: Fresh crop circles point to a relay beacon while the barn workshop comes under attack."
		5:
			return "Wave 5: Shield drones start screening the rush while burrowers cut under the fence and another relay drives the harriers into the silo lane."
		6:
			match patch_path:
				PatchPath.SCOUT:
					return "Wave 6: Patch turns up sealed alien gear while shield drones, burrowers, the command rig, the final relay, and the structure raid drill for the heart of the farm."
				PatchPath.SCRAP:
					return "Wave 6: The salvage pile grows into a full workshop as shield drones, burrowers, the command rig, the final relay, and the structure raid bore into the farm."
				PatchPath.GUARD:
					return "Wave 6: Patch's bark rolls across the farm while shield drones, burrowers, the command rig, the final relay, and the structure raid pound the field."
				_:
					return "Wave 6: Shield drones, burrowers, a command rig, a final relay, and a structure raid hammer the field while Eli turns the tractor shed into a war workshop."
		7:
			return "Wave 7: Act 2 starts with the north field ripped open and the excavation front rolling straight at Miller Farm."
		8:
			return "Wave 8: A breach column marches out of the crater while shield drones and burrowers split the pressure across the barn and silo."
		9:
			return "Wave 9: The aliens start lifting glowing machinery out of the pit while harriers, relays, and rig crews pull the whole farm apart."
		10:
			return "Wave 10: Dawn starts to break while the Overseer command craft comes in behind the final extraction push."
		_:
			return "The field stays loud with engines and falling metal."


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		_ensure_audio_started()
	elif event is InputEventMouseButton and event.pressed:
		_ensure_audio_started()
	elif event is InputEventScreenTouch and event.pressed:
		_ensure_audio_started()

	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		if control_mode_preference == ControlMode.AUTO and not auto_touch_detected:
			auto_touch_detected = true
			_apply_control_mode()

	if not _touch_gameplay_enabled():
		return

	if event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		var handled := false
		if touch_event.pressed:
			handled = _handle_touch_pressed(touch_event.index, touch_event.position)
		else:
			handled = _handle_touch_released(touch_event.index)
		if handled:
			get_viewport().set_input_as_handled()
		return

	if event is InputEventScreenDrag:
		var drag_event := event as InputEventScreenDrag
		if _handle_touch_drag(drag_event.index, drag_event.position):
			get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_menu"):
		get_viewport().set_input_as_handled()
		_toggle_pause_menu()
		return

	if (game_over or mission_complete) and event.is_action_pressed("restart"):
		get_viewport().set_input_as_handled()
		get_tree().paused = false
		get_tree().reload_current_scene()
		return

	if get_tree().paused or game_over or mission_complete:
		return

	if event.is_action_pressed("swap_weapon"):
		get_viewport().set_input_as_handled()
		_toggle_weapon()
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if dog != null and is_instance_valid(dog) and wave_active and not game_over and not mission_complete:
			get_viewport().set_input_as_handled()
			var click_pos: Vector2 = get_global_mouse_position()
			dog.set_command_point(click_pos)
			_set_banner("Patch! Go check that spot.", 1.2)
			return

	if event.is_action_pressed("build_primary"):
		get_viewport().set_input_as_handled()
		_select_build_type(BUILD_COIL_TURRET)
		return

	if event.is_action_pressed("build_secondary"):
		get_viewport().set_input_as_handled()
		_select_build_type(BUILD_SHOCK_POST)
		return

	if event.is_action_pressed("build_tertiary"):
		get_viewport().set_input_as_handled()
		_select_build_type(BUILD_BARRICADE)


func _draw_threat_indicators(viewport_size: Vector2) -> void:
	if not wave_active or game_over or mission_complete:
		return

	var margin := 24.0
	var arrow_size := 10.0
	var screen_rect := Rect2(Vector2(margin, 80.0), viewport_size - Vector2(margin * 2.0, 80.0 + 50.0))

	for node in cached_aliens:
		if node == null or not is_instance_valid(node):
			continue
		if not (node is Node2D):
			continue
		var alien_pos: Vector2 = (node as Node2D).global_position
		if screen_rect.has_point(alien_pos):
			continue

		var center := screen_rect.get_center()
		var direction := (alien_pos - center).normalized()

		# Clamp to screen edge
		var edge_pos := center
		var t_min := 1000000.0
		# Check intersection with each edge
		if direction.x != 0.0:
			var t_left := (screen_rect.position.x - center.x) / direction.x
			if t_left > 0.0 and t_left < t_min:
				var y := center.y + direction.y * t_left
				if y >= screen_rect.position.y and y <= screen_rect.position.y + screen_rect.size.y:
					t_min = t_left
			var t_right := (screen_rect.position.x + screen_rect.size.x - center.x) / direction.x
			if t_right > 0.0 and t_right < t_min:
				var y := center.y + direction.y * t_right
				if y >= screen_rect.position.y and y <= screen_rect.position.y + screen_rect.size.y:
					t_min = t_right
		if direction.y != 0.0:
			var t_top := (screen_rect.position.y - center.y) / direction.y
			if t_top > 0.0 and t_top < t_min:
				var x := center.x + direction.x * t_top
				if x >= screen_rect.position.x and x <= screen_rect.position.x + screen_rect.size.x:
					t_min = t_top
			var t_bottom := (screen_rect.position.y + screen_rect.size.y - center.y) / direction.y
			if t_bottom > 0.0 and t_bottom < t_min:
				var x := center.x + direction.x * t_bottom
				if x >= screen_rect.position.x and x <= screen_rect.position.x + screen_rect.size.x:
					t_min = t_bottom

		if t_min < 999999.0:
			edge_pos = center + direction * t_min

		var arrow_color := Color8(255, 92, 72, 180)
		var perp := Vector2(-direction.y, direction.x)
		var tip := edge_pos
		var base_left := tip - direction * arrow_size + perp * (arrow_size * 0.5)
		var base_right := tip - direction * arrow_size - perp * (arrow_size * 0.5)
		draw_colored_polygon(PackedVector2Array([tip, base_left, base_right]), arrow_color)


func _draw() -> void:
	var viewport_size := get_viewport_rect().size
	var act_two_active := _act_two_active()
	var bg_scale := _background_scale(viewport_size)
	var base_bottom_y := _bg_point(Vector2(0.0, 464.0), bg_scale).y
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color8(251, 210, 157))
	draw_circle(_bg_point(Vector2(1116.0, 118.0), bg_scale), _bg_radius(76.0, bg_scale), Color8(255, 239, 174))
	draw_rect(Rect2(Vector2(0.0, _bg_point(Vector2(0.0, 248.0), bg_scale).y), Vector2(viewport_size.x, maxf(0.0, viewport_size.y - _bg_point(Vector2(0.0, 248.0), bg_scale).y))), Color8(195, 151, 82))
	draw_rect(Rect2(Vector2(0.0, base_bottom_y), Vector2(viewport_size.x, maxf(0.0, viewport_size.y - base_bottom_y))), Color8(120, 155, 76))

	for row in range(6):
		var y: float = 288.0 + float(row) * 34.0
		var row_start := _bg_point(Vector2(80.0, y), bg_scale)
		var row_end := Vector2(maxf(_bg_point(Vector2(1200.0, 0.0), bg_scale).x, viewport_size.x - 80.0 * bg_scale.x), _bg_point(Vector2(0.0, y + 54.0), bg_scale).y)
		draw_line(row_start, row_end, Color8(147, 110, 58), _bg_thickness(2.0, bg_scale), true)

	if act_two_active:
		var crater_center := _bg_point(DRILL_SITE_POS + Vector2(0.0, -6.0), bg_scale)
		draw_circle(crater_center, _bg_radius(146.0, bg_scale), Color8(83, 62, 53))
		draw_circle(crater_center + _bg_size(Vector2(0.0, 8.0), bg_scale), _bg_radius(104.0, bg_scale), Color8(51, 41, 37))
		draw_circle(crater_center + _bg_size(Vector2(-14.0, -6.0), bg_scale), _bg_radius(52.0, bg_scale), Color8(98, 201, 214, 58))
		draw_line(_bg_point(Vector2(DRILL_SITE_POS.x - 118.0, DRILL_SITE_POS.y - 104.0), bg_scale), _bg_point(Vector2(DRILL_SITE_POS.x + 102.0, DRILL_SITE_POS.y + 82.0), bg_scale), Color8(112, 84, 66), _bg_thickness(4.0, bg_scale), true)
		draw_line(_bg_point(Vector2(DRILL_SITE_POS.x + 126.0, DRILL_SITE_POS.y - 92.0), bg_scale), _bg_point(Vector2(DRILL_SITE_POS.x - 88.0, DRILL_SITE_POS.y + 96.0), bg_scale), Color8(112, 84, 66), _bg_thickness(4.0, bg_scale), true)
		draw_line(_bg_point(Vector2(DRILL_SITE_POS.x - 170.0, DRILL_SITE_POS.y - 22.0), bg_scale), _bg_point(Vector2(DRILL_SITE_POS.x - 84.0, DRILL_SITE_POS.y + 16.0), bg_scale), Color8(67, 55, 46), _bg_thickness(10.0, bg_scale), true)
		draw_line(_bg_point(Vector2(DRILL_SITE_POS.x + 82.0, DRILL_SITE_POS.y - 34.0), bg_scale), _bg_point(Vector2(DRILL_SITE_POS.x + 180.0, DRILL_SITE_POS.y + 12.0), bg_scale), Color8(67, 55, 46), _bg_thickness(10.0, bg_scale), true)

	var fence_post_start := int(round(96.0 * bg_scale.x))
	var fence_post_end := maxi(fence_post_start + 1, int(round(viewport_size.x - 96.0 * bg_scale.x)))
	var fence_step := maxi(24, int(round(48.0 * bg_scale.x)))
	var fence_top_y := _bg_point(Vector2(0.0, 440.0), bg_scale).y
	var fence_bottom_y := _bg_point(Vector2(0.0, 470.0), bg_scale).y
	for x in range(fence_post_start, fence_post_end, fence_step):
		draw_line(Vector2(float(x), fence_top_y), Vector2(float(x), fence_bottom_y), Color8(235, 224, 193), _bg_thickness(3.0, bg_scale), true)
	if act_two_active:
		draw_line(_bg_point(Vector2(72.0, 444.0), bg_scale), _bg_point(Vector2(508.0, 444.0), bg_scale), Color8(235, 224, 193), _bg_thickness(4.0, bg_scale), true)
		draw_line(_bg_point(Vector2(776.0, 444.0), bg_scale), Vector2(maxf(_bg_point(Vector2(1208.0, 0.0), bg_scale).x, viewport_size.x - 72.0 * bg_scale.x), _bg_point(Vector2(0.0, 444.0), bg_scale).y), Color8(235, 224, 193), _bg_thickness(4.0, bg_scale), true)
		draw_line(_bg_point(Vector2(72.0, 470.0), bg_scale), _bg_point(Vector2(492.0, 470.0), bg_scale), Color8(235, 224, 193), _bg_thickness(4.0, bg_scale), true)
		draw_line(_bg_point(Vector2(792.0, 470.0), bg_scale), Vector2(maxf(_bg_point(Vector2(1208.0, 0.0), bg_scale).x, viewport_size.x - 72.0 * bg_scale.x), _bg_point(Vector2(0.0, 470.0), bg_scale).y), Color8(235, 224, 193), _bg_thickness(4.0, bg_scale), true)
	else:
		draw_line(_bg_point(Vector2(72.0, 444.0), bg_scale), Vector2(maxf(_bg_point(Vector2(1208.0, 0.0), bg_scale).x, viewport_size.x - 72.0 * bg_scale.x), _bg_point(Vector2(0.0, 444.0), bg_scale).y), Color8(235, 224, 193), _bg_thickness(4.0, bg_scale), true)
		draw_line(_bg_point(Vector2(72.0, 470.0), bg_scale), Vector2(maxf(_bg_point(Vector2(1208.0, 0.0), bg_scale).x, viewport_size.x - 72.0 * bg_scale.x), _bg_point(Vector2(0.0, 470.0), bg_scale).y), Color8(235, 224, 193), _bg_thickness(4.0, bg_scale), true)

	var lane_rect := _bg_rect(Rect2(Vector2(FARMHOUSE_POS.x - 62.0, 420.0), Vector2(124.0, 180.0)), bg_scale)
	draw_rect(lane_rect, Color8(170, 139, 94))

	var barn_body := _bg_rect(Rect2(FARMHOUSE_POS + Vector2(-108.0, -112.0), Vector2(216.0, 118.0)), bg_scale)
	draw_rect(barn_body, Color8(188, 62, 43))
	draw_rect(_bg_rect(Rect2(FARMHOUSE_POS + Vector2(-26.0, -56.0), Vector2(52.0, 62.0)), bg_scale), Color8(93, 52, 33))
	draw_rect(_bg_rect(Rect2(FARMHOUSE_POS + Vector2(-82.0, -86.0), Vector2(44.0, 34.0)), bg_scale), Color8(242, 233, 210))
	draw_rect(_bg_rect(Rect2(FARMHOUSE_POS + Vector2(38.0, -86.0), Vector2(44.0, 34.0)), bg_scale), Color8(242, 233, 210))

	var roof_points := PackedVector2Array([
		_bg_point(FARMHOUSE_POS + Vector2(-122.0, -112.0), bg_scale),
		_bg_point(FARMHOUSE_POS + Vector2(0.0, -186.0), bg_scale),
		_bg_point(FARMHOUSE_POS + Vector2(122.0, -112.0), bg_scale)
	])
	draw_colored_polygon(roof_points, Color8(88, 41, 34))

	var silo_rect := _bg_rect(Rect2(FARMHOUSE_POS + Vector2(146.0, -148.0), Vector2(58.0, 154.0)), bg_scale)
	draw_rect(silo_rect, Color8(113, 123, 134))
	draw_circle(_bg_point(FARMHOUSE_POS + Vector2(175.0, -148.0), bg_scale), _bg_radius(29.0, bg_scale), Color8(141, 152, 163))

	# Farm penalty visuals
	if silo_penalty_visual_active:
		var crack_pulse := (sin(penalty_pulse_time * 2.0) + 1.0) * 0.5
		var crack_alpha := lerpf(0.4, 0.7, crack_pulse)
		var crack_color := Color(0.85, 0.25, 0.18, crack_alpha)
		draw_line(_bg_point(FARMHOUSE_POS + Vector2(-60.0, -90.0), bg_scale), _bg_point(FARMHOUSE_POS + Vector2(-20.0, -40.0), bg_scale), crack_color, _bg_thickness(3.0, bg_scale), true)
		draw_line(_bg_point(FARMHOUSE_POS + Vector2(40.0, -80.0), bg_scale), _bg_point(FARMHOUSE_POS + Vector2(70.0, -30.0), bg_scale), crack_color, _bg_thickness(3.0, bg_scale), true)
		var icon_pos := _bg_point(FARMHOUSE_POS + Vector2(0.0, -198.0), bg_scale)
		draw_circle(icon_pos, _bg_radius(8.0, bg_scale), Color(0.85, 0.18, 0.14, 0.7))
		draw_line(icon_pos + _bg_size(Vector2(-5.0, 5.0), bg_scale), icon_pos + _bg_size(Vector2(5.0, -5.0), bg_scale), Color(1.0, 1.0, 1.0, 0.8), _bg_thickness(2.0, bg_scale), true)

	if power_penalty_visual_active:
		var flicker := randf() < 0.35
		if flicker:
			var arc_alpha := randf_range(0.15, 0.35)
			var arc_color := Color(0.5, 0.7, 0.9, arc_alpha)
			draw_arc(_bg_point(FARMHOUSE_POS + Vector2(-90.0, -130.0), bg_scale), _bg_radius(16.0, bg_scale), -0.8, 0.8, 12, arc_color, _bg_thickness(2.0, bg_scale), true)
			draw_arc(_bg_point(FARMHOUSE_POS + Vector2(90.0, -130.0), bg_scale), _bg_radius(14.0, bg_scale), 1.8, 3.6, 12, arc_color, _bg_thickness(2.0, bg_scale), true)

	# Dawn sky transition (wave 10)
	if dawn_progress > 0.0:
		var sky_alpha := dawn_progress * 0.35
		var dawn_color := Color(1.0, 0.72, 0.38, sky_alpha)
		draw_rect(Rect2(Vector2.ZERO, Vector2(viewport_size.x, _bg_point(Vector2(0.0, 248.0), bg_scale).y)), dawn_color)
		if dawn_progress > 0.5:
			var horizon_alpha := (dawn_progress - 0.5) * 0.6
			draw_rect(Rect2(Vector2.ZERO, Vector2(viewport_size.x, _bg_point(Vector2(0.0, 80.0), bg_scale).y)), Color(1.0, 0.85, 0.55, horizon_alpha))

	# Excavation depth bar (Act 2)
	if act_two_active and wave_active and excavation_depth > 0.0:
		var bar_x := _bg_point(Vector2(536.0, 78.0), bg_scale).x
		var bar_y := _bg_point(Vector2(0.0, 78.0), bg_scale).y
		var bar_w := _bg_size(Vector2(208.0, 0.0), bg_scale).x
		var bar_h := _bg_size(Vector2(0.0, 12.0), bg_scale).y
		draw_rect(Rect2(Vector2(bar_x, bar_y), Vector2(bar_w, bar_h)), Color8(42, 36, 32, 180))
		var fill_ratio := clampf(excavation_depth / EXCAVATION_MAX, 0.0, 1.0)
		var fill_color := Color8(214, 82, 62) if fill_ratio > 0.7 else Color8(218, 168, 82)
		draw_rect(Rect2(Vector2(bar_x + 1.0, bar_y + 1.0), Vector2((bar_w - 2.0) * fill_ratio, bar_h - 2.0)), fill_color)

	_draw_threat_indicators(viewport_size)
