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
const ACT_ONE_WAVES = [
	{
		"title": "Act 1: First Contact",
		"story": "Strange lights sweep over the corn. Eli grabs his barn-built nailgun while Patch circles the porch, waiting for the first landing.",
		"objective": "Hold the north fence against 6 scout saucers.",
		"spawn_count": 6,
		"driller_count": 0,
		"harrier_count": 0,
		"spawn_interval": 1.95,
		"start_delay": 0.80,
		"spawn_mode": "top",
	},
	{
		"title": "Wave 2: Fence Breakers",
		"story": "The first wrecks are still smoking. Patch takes on a real job while a second alien rush lines up over the field, and a few raiders angle straight toward the farm's power shed.",
		"objective": "Stop 8 raiders, including the first driller brute, and keep the power shed online.",
		"spawn_count": 8,
		"driller_count": 1,
		"harrier_count": 0,
		"structure_raids": [{"id":"power_shed", "count":2}],
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
		"harrier_count": 0,
		"drill_site": true,
		"drill_rate": 2.30,
		"drill_health": 10,
		"spawn_interval": 1.50,
		"start_delay": 0.70,
		"spawn_mode": "sides",
	},
	{
		"title": "Wave 4: North Field Signal",
		"story": "Crop circles are no longer random. The whole north field lines up around a relay mast dropped over something buried deep below the roots while blue harriers start firing from above the rows and scouts slash toward Eli's barn workshop.",
		"objective": "Destroy the signal relay, clear 12 invaders, and keep the barn workshop standing.",
		"spawn_count": 12,
		"driller_count": 2,
		"harrier_count": 2,
		"structure_raids": [{"id":"barn", "count":3}],
		"relay_trigger_spawned": 5,
		"relay_position": Vector2(316.0, 250.0),
		"relay_health": 8,
		"relay_interval": 5.30,
		"relay_boost_multiplier": 1.25,
		"relay_boost_duration": 3.00,
		"relay_drill_boost": 0.0,
		"relay_scrap": 5,
		"spawn_interval": 1.30,
		"start_delay": 0.70,
		"spawn_mode": "top",
	},
	{
		"title": "Wave 5: Harvester Approach",
		"story": "More lights peel off the mothership. A second relay slams down near the silo while shield drones start screening the rush, burrowers cut under the fence, harriers strafe the farmhouse, and raiders split off toward the silo and power shed.",
		"objective": "Smash the new signal relay, crack the shield drones, catch the first burrowers, hold off 14 attackers, and stop the silo and power shed from falling.",
		"spawn_count": 14,
		"driller_count": 3,
		"harrier_count": 3,
		"shield_count": 2,
		"burrower_count": 2,
		"structure_raids": [{"id":"silo", "count":3}, {"id":"power_shed", "count":2}],
		"relay_trigger_spawned": 6,
		"relay_position": Vector2(980.0, 254.0),
		"relay_health": 9,
		"relay_interval": 4.90,
		"relay_boost_multiplier": 1.30,
		"relay_boost_duration": 3.20,
		"relay_drill_boost": 0.0,
		"relay_scrap": 6,
		"spawn_interval": 1.10,
		"start_delay": 0.65,
		"spawn_mode": "mixed",
	},
	{
		"title": "Wave 6: Final Stand At The Silo",
		"story": "Everything comes in at once. A command drill rig locks onto the signal under the field while shield drones screen the final relay, burrowers tunnel in under the lane, and raiders break for the barn, silo, and power shed under harrier fire.",
		"objective": "Smash the command drill rig and final relay, break the shield screen, stop the tunneling rush, survive 16 attackers, and keep the barn, silo, and power shed alive.",
		"spawn_count": 16,
		"driller_count": 4,
		"harrier_count": 4,
		"shield_count": 3,
		"burrower_count": 3,
		"drill_site": true,
		"drill_rate": 3.10,
		"drill_health": 14,
		"structure_raids": [{"id":"barn", "count":2}, {"id":"power_shed", "count":2}, {"id":"silo", "count":2}],
		"relay_trigger_spawned": 7,
		"relay_position": Vector2(980.0, 302.0),
		"relay_health": 10,
		"relay_interval": 4.50,
		"relay_boost_multiplier": 1.35,
		"relay_boost_duration": 3.50,
		"relay_drill_boost": 6.5,
		"relay_scrap": 7,
		"spawn_interval": 0.92,
		"start_delay": 0.60,
		"spawn_mode": "mixed",
	},
]

const PLAYER_SCENE := preload("res://scenes/player.tscn")
const DOG_SCENE := preload("res://scenes/dog.tscn")
const ALIEN_SCENE := preload("res://scenes/alien.tscn")
const FARM_STRUCTURE_SCENE := preload("res://scenes/farm_structure.tscn")
const DRILL_RIG_SCENE := preload("res://scenes/drill_rig.tscn")
const SIGNAL_RELAY_SCENE := preload("res://scenes/signal_relay.tscn")
const FIELD_SIGNAL_SCENE := preload("res://scenes/field_signal.tscn")
const ROCKET_TRACTOR_SCENE := preload("res://scenes/rocket_tractor.tscn")
const BULLET_SCENE := preload("res://scenes/bullet.tscn")
const ENEMY_BOLT_SCENE := preload("res://scenes/enemy_bolt.tscn")
const TURRET_SCENE := preload("res://scenes/turret.tscn")
const SHOCK_POST_SCENE := preload("res://scenes/shock_post.tscn")
const BARRICADE_SCENE := preload("res://scenes/barricade.tscn")
const BUILD_SPOT_SCENE := preload("res://scenes/build_spot.tscn")
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
var shield_warning_sent := false
var burrower_warning_sent := false
var structure_raid_pool: Array[String] = []
var structure_raid_notice_sent := false
var pending_upgrade_choices: Array[Dictionary] = []
var pending_upgrade_wave_index := -1
var pending_transition_text := ""


func _ready() -> void:
	randomize()
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

	var buttons_row: HBoxContainer = HBoxContainer.new()
	buttons_row.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	buttons_row.add_theme_constant_override("separation", 14)
	content.add_child(buttons_row)

	title_auto_button = Button.new()
	title_auto_button.text = "Auto"
	title_auto_button.custom_minimum_size = Vector2(248.0, 56.0)
	title_auto_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	title_auto_button.pressed.connect(_on_control_mode_selected.bind(ControlMode.AUTO))
	buttons_row.add_child(title_auto_button)

	title_desktop_button = Button.new()
	title_desktop_button.text = "Desktop"
	title_desktop_button.custom_minimum_size = Vector2(248.0, 56.0)
	title_desktop_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	title_desktop_button.pressed.connect(_on_control_mode_selected.bind(ControlMode.DESKTOP))
	buttons_row.add_child(title_desktop_button)

	title_touch_button = Button.new()
	title_touch_button.text = "Touch"
	title_touch_button.custom_minimum_size = Vector2(248.0, 56.0)
	title_touch_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	title_touch_button.pressed.connect(_on_control_mode_selected.bind(ControlMode.TOUCH))
	buttons_row.add_child(title_touch_button)

	title_footer_label = Label.new()
	title_footer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_footer_label.modulate = Color8(191, 198, 207)
	content.add_child(title_footer_label)


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
	pause_restart_button.text = "Restart Act 1"
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
			panel.position = (viewport_size - panel.size) * 0.5
	if pause_panel != null:
		pause_panel.position = (viewport_size - pause_panel.size) * 0.5
	if prep_panel != null:
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
	rocket_tractor.configure(BULLET_SCENE, 164.0, 1116.0, 84.0, 2.8, 5, 470.0)
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
	_update_field_signal_state(wave, bool(wave_data.get("drill_site", false)) or wave_data.has("relay_trigger_spawned"))
	_refresh_support_units()
	_update_hint()
	_update_stats()


func _compose_briefing_text(wave_data: Dictionary, transition_text: String) -> String:
	var briefing_text: String = String(wave_data["story"])
	if transition_text != "":
		briefing_text = transition_text + "\n\n" + briefing_text
	briefing_text += "\n\nObjective: %s" % String(wave_data["objective"])
	return briefing_text


func _on_briefing_continue_pressed() -> void:
	_ensure_audio_started()
	if mission_complete or game_over:
		get_tree().paused = false
		get_tree().reload_current_scene()
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
	prep_phase_active = false
	relay_spawned_for_wave = false
	shield_warning_sent = false
	burrower_warning_sent = false
	structure_raid_pool = _build_structure_raid_pool(wave_data)
	structure_raid_notice_sent = false
	_spawn_wave_objectives(wave_data)
	banner_default = _story_text_for_wave(wave)
	_set_banner(banner_default, 3.0)
	if music_sting_player != null and is_instance_valid(music_sting_player):
		music_sting_player.play()
	_update_field_signal_state(wave, _has_live_drill_site() or wave >= 4)
	_refresh_support_units()
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
		"harrier":
			_play_positional_sfx(SFX_ALIEN_CHITTER_IDLE, spawn_position, -18.0, 1.04, 1.10)
		"shield_drone":
			_play_positional_sfx(SFX_ALIEN_CHITTER_IDLE, spawn_position, -16.0, 0.90, 0.98)
			if not shield_warning_sent:
				shield_warning_sent = true
				_set_banner("Shield drone on the lane. Flank it or crack it with shock posts.", 2.4)
		"burrower":
			_play_positional_sfx(SFX_ALIEN_CHITTER_IDLE, spawn_position, -17.0, 0.82, 0.92)
			if not burrower_warning_sent:
				burrower_warning_sent = true
				_set_banner("Burrower under the fence. They ignore barricades and go straight for the farm.", 2.4)
		_:
			if randf() <= 0.22:
				_play_positional_sfx(SFX_ALIEN_CHITTER_IDLE, spawn_position, -20.0, 0.98, 1.08)
	wave_spawned += 1
	active_aliens += 1
	_maybe_spawn_midwave_objective()
	_update_stats()


func _spawn_wave_objectives(wave_data: Dictionary) -> void:
	current_drill_site = null
	current_signal_relay = null
	if not bool(wave_data.get("drill_site", false)):
		return

	var drill_rig: StaticBody2D = DRILL_RIG_SCENE.instantiate() as StaticBody2D
	drill_rig.position = DRILL_SITE_POS
	drill_rig.configure(int(wave_data["drill_health"]), float(wave_data["drill_rate"]), 4 + wave)
	drill_rig.destroyed.connect(_on_drill_site_destroyed)
	drill_rig.breached.connect(_on_drill_site_breached)
	drill_rig.damaged.connect(_on_objective_damaged)
	add_child(drill_rig)
	current_drill_site = drill_rig
	active_aliens += 1


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
	_set_banner("Raiders angle toward the %s." % _structure_display_name(structure_id), 1.8)


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
	_refresh_current_objective_text()
	_set_banner("An alien relay locks onto the field. Smash it before the next pulse.", 2.4)
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


func _refresh_current_objective_text() -> void:
	if not wave_active:
		return
	if _has_live_signal_relay():
		if _has_live_drill_site():
			current_objective_text = "Destroy the signal relay before it accelerates the command rig."
		else:
			current_objective_text = "Destroy the signal relay before it boosts the whole lane again."
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
	if structure_id == "power_shed":
		_refresh_turret_stats()
	_update_stats()


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
		_:
			return ""


func _refresh_turret_stats() -> void:
	for node in get_tree().get_nodes_in_group("turrets"):
		if node.has_method("set_stats"):
			node.set_stats(_effective_turret_fire_interval(), turret_damage)
	for node in get_tree().get_nodes_in_group("shock_posts"):
		if node.has_method("set_stats"):
			node.set_stats(_effective_shock_post_fire_interval(), shock_post_damage, shock_post_stun_duration)


func _spawn_bullet(origin: Vector2, direction: Vector2, speed: float, damage: int, lifetime: float = 1.6, radius: float = 6.0, core_color: Color = Color8(255, 241, 196), tail_color: Color = Color8(255, 185, 71), damage_falloff_start: float = -1.0, damage_falloff_end: float = -1.0, minimum_damage: int = 1) -> void:
	var bullet: Area2D = BULLET_SCENE.instantiate() as Area2D
	bullet.global_position = origin
	bullet.configure(direction, speed, damage, lifetime, radius, core_color, tail_color, damage_falloff_start, damage_falloff_end, minimum_damage)
	add_child(bullet)


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
		shock_post.configure(_effective_shock_post_fire_interval(), shock_post_damage, shock_post_stun_duration)
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
		turret.configure(BULLET_SCENE, _effective_turret_fire_interval(), turret_damage)
		turret.fired_shot.connect(_on_turret_fired)
		add_child(turret)
		_play_positional_sfx(SFX_WEAPON_HEAVY_BLAST, spot.global_position, -12.0, 1.00, 1.06)
		_set_banner("Coil turret online. Keep the lane clear.", 1.8)

	_update_hint()
	_update_stats()


func _on_alien_destroyed(scrap_value: int, _world_position: Vector2) -> void:
	if game_over:
		return

	active_aliens = maxi(0, active_aliens - 1)
	_play_positional_sfx(SFX_ALIEN_DEATH, _world_position, -10.0, 0.94, 1.04)

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
	_queue_wave_completion_check()


func _on_alien_drill_site_reached(progress_boost: float) -> void:
	if game_over:
		return

	active_aliens = maxi(0, active_aliens - 1)
	if _has_live_drill_site():
		current_drill_site.boost_progress(progress_boost)
		if game_over:
			return
		_set_banner("A driller fed the north-field rig.", 1.6)
	_update_stats()
	_queue_wave_completion_check()


func _on_alien_structure_hit(structure_id: String, damage: int) -> void:
	if game_over:
		return

	active_aliens = maxi(0, active_aliens - 1)
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

	var enemy_bolt: Area2D = ENEMY_BOLT_SCENE.instantiate() as Area2D
	enemy_bolt.configure(origin, target_position, projectile_speed, damage, target_structure_id)
	enemy_bolt.impacted.connect(_on_enemy_bolt_impacted)
	add_child(enemy_bolt)
	_play_positional_sfx(SFX_WEAPON_ROCKET_LAUNCH, origin, -13.0, 0.92, 1.00)


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
	base_health -= damage + _farmhouse_damage_bonus()
	if base_health <= 0:
		_trigger_game_over("The farmhouse is gone. Reset and hold the line again.")
	else:
		_play_positional_sfx(SFX_WEAPON_HEAVY_BLAST, FARMHOUSE_POS, -18.0, 0.88, 0.96)
		_set_banner("The farmhouse took a hit!", 1.4)
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
			_set_banner("Silo shattered. Every farmhouse hit will land harder.", 2.2)
		_:
			_set_banner("%s lost." % _structure_display_name(structure_id), 2.0)
	_update_hint()
	_update_stats()


func _on_objective_damaged(_world_position: Vector2) -> void:
	if game_over:
		return
	_update_stats()


func _on_drill_site_destroyed(scrap_value: int, _world_position: Vector2) -> void:
	if game_over:
		return

	active_aliens = maxi(0, active_aliens - 1)
	current_drill_site = null
	scrap += scrap_value
	_play_positional_sfx(SFX_WEAPON_HEAVY_BLAST, _world_position, -8.0, 0.84, 0.92)
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
	current_drill_site = null
	_update_field_signal_state(wave, true)
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
		_set_banner("Relay pulse drives the lane and feeds the command rig.", 1.7)
	elif boosted_enemies > 0:
		_set_banner("Relay pulse drives the invaders into a frenzy.", 1.6)
	elif boosted_drill:
		_set_banner("Relay pulse surges into the north-field rig.", 1.6)


func _on_signal_relay_destroyed(scrap_value: int, _world_position: Vector2) -> void:
	if game_over:
		return

	active_aliens = maxi(0, active_aliens - 1)
	current_signal_relay = null
	scrap += scrap_value
	_play_positional_sfx(SFX_WEAPON_HEAVY_BLAST, _world_position, -9.0, 0.82, 0.90)
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
	var farm_transition_text := _wave_clear_farm_text()
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
	if farm_transition_text != "":
		if transition_text != "":
			transition_text = farm_transition_text + "\n\n" + transition_text
		else:
			transition_text = farm_transition_text
	_show_upgrade_panel(next_wave_index, transition_text)


func _show_mission_complete() -> void:
	mission_complete = true
	settings_menu_open = false
	prep_phase_active = false
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
	prep_panel.visible = false
	upgrade_panel.visible = false
	patch_panel.visible = false
	pause_panel.visible = false
	get_tree().paused = true
	_update_field_signal_state(wave, true)
	_refresh_support_units()
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
	_update_hint()
	_update_stats()


func _set_banner(text: String, duration: float = 2.0) -> void:
	banner_label.text = text
	if duration > 0.0:
		banner_timer.start(duration)


func _restore_banner() -> void:
	banner_label.text = banner_default


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
	return "Farm " + "  ".join(status_bits)


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
		hint_label.text = "Act 1 complete. Press R or use the panel to restart the defense."
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


func _draw() -> void:
	var viewport_size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color8(251, 210, 157))
	draw_circle(Vector2(1116.0, 118.0), 76.0, Color8(255, 239, 174))
	draw_rect(Rect2(Vector2(0.0, 248.0), Vector2(viewport_size.x, maxf(0.0, viewport_size.y - 248.0))), Color8(195, 151, 82))
	draw_rect(Rect2(Vector2(0.0, 464.0), Vector2(viewport_size.x, maxf(0.0, viewport_size.y - 464.0))), Color8(120, 155, 76))

	for row in range(6):
		var y: float = 288.0 + float(row) * 34.0
		draw_line(Vector2(80.0, y), Vector2(maxf(1200.0, viewport_size.x - 80.0), y + 54.0), Color8(147, 110, 58), 2.0, true)

	for x in range(96, maxi(1184, int(viewport_size.x) - 96), 48):
		draw_line(Vector2(float(x), 440.0), Vector2(float(x), 470.0), Color8(235, 224, 193), 3.0, true)
	draw_line(Vector2(72.0, 444.0), Vector2(maxf(1208.0, viewport_size.x - 72.0), 444.0), Color8(235, 224, 193), 4.0, true)
	draw_line(Vector2(72.0, 470.0), Vector2(maxf(1208.0, viewport_size.x - 72.0), 470.0), Color8(235, 224, 193), 4.0, true)

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
