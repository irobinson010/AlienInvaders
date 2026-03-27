extends StaticBody2D

signal destroyed(scrap_value: int, world_position: Vector2, objective_id: String, display_name: String, objective_kind: String)
signal pulsed(objective_id: String, display_name: String, objective_kind: String, effect_kind: String, primary_value: float, secondary_value: float, tertiary_value: float, target_structure_id: String, world_position: Vector2)
signal damaged(world_position: Vector2)

const KIND_EXCAVATION_PYLON := "excavation_pylon"
const KIND_BREACH_BEACON := "breach_beacon"
const KIND_LIFT_ANCHOR := "lift_anchor"
const KIND_COMMAND_BEACON := "command_beacon"

var objective_id := ""
var display_name := "Excavation Node"
var objective_kind := KIND_EXCAVATION_PYLON
var effect_kind := "drill_boost"
var health := 8
var max_health := 8
var scrap_value := 4
var pulse_interval := 4.8
var pulse_timer := 3.0
var primary_value := 0.0
var secondary_value := 0.0
var tertiary_value := 0.0
var target_structure_id := ""
var hit_flash := 0.0
var pulse_flash := 0.0


func _ready() -> void:
	z_index = 11
	collision_layer = 2
	collision_mask = 0
	add_to_group("aliens")
	add_to_group("act2_objectives")

	var collision: CollisionShape2D = CollisionShape2D.new()
	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = 24.0
	collision.shape = shape
	add_child(collision)


func configure(config: Dictionary) -> void:
	objective_id = String(config.get("id", "act2_objective"))
	display_name = String(config.get("name", "Excavation Node"))
	objective_kind = String(config.get("kind", KIND_EXCAVATION_PYLON))
	effect_kind = String(config.get("effect", "drill_boost"))
	health = int(config.get("health", 8))
	max_health = health
	scrap_value = int(config.get("scrap", 4))
	pulse_interval = float(config.get("pulse_interval", 4.8))
	pulse_timer = float(config.get("pulse_start", maxf(1.2, pulse_interval * 0.68)))
	primary_value = float(config.get("primary_value", 0.0))
	secondary_value = float(config.get("secondary_value", 0.0))
	tertiary_value = float(config.get("tertiary_value", 0.0))
	target_structure_id = String(config.get("target_structure_id", ""))
	hit_flash = 0.0
	pulse_flash = 0.0
	queue_redraw()


func _physics_process(delta: float) -> void:
	if hit_flash > 0.0:
		hit_flash = maxf(0.0, hit_flash - delta)
		queue_redraw()
	if pulse_flash > 0.0:
		pulse_flash = maxf(0.0, pulse_flash - delta)
		queue_redraw()

	pulse_timer -= delta
	if pulse_timer > 0.0:
		return

	pulse_timer = pulse_interval
	pulse_flash = 0.24
	pulsed.emit(objective_id, display_name, objective_kind, effect_kind, primary_value, secondary_value, tertiary_value, target_structure_id, global_position)
	queue_redraw()


func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		destroyed.emit(scrap_value, global_position, objective_id, display_name, objective_kind)
		queue_free()
		return
	hit_flash = 0.18
	damaged.emit(global_position)
	queue_redraw()


func get_health() -> int:
	return health


func get_max_health() -> int:
	return max_health


func get_objective_kind() -> String:
	return objective_kind


func get_status_text() -> String:
	return "%s %02d/%02d" % [display_name, health, max_health]


func _palette() -> Dictionary:
	match objective_kind:
		KIND_BREACH_BEACON:
			return {
				"shell": Color8(120, 64, 66),
				"core": Color8(255, 168, 114),
				"beam": Color8(255, 104, 86),
			}
		KIND_LIFT_ANCHOR:
			return {
				"shell": Color8(74, 112, 146),
				"core": Color8(140, 232, 255),
				"beam": Color8(246, 190, 124),
			}
		KIND_COMMAND_BEACON:
			return {
				"shell": Color8(112, 78, 154),
				"core": Color8(202, 228, 255),
				"beam": Color8(255, 170, 108),
			}
		_:
			return {
				"shell": Color8(126, 92, 76),
				"core": Color8(255, 214, 132),
				"beam": Color8(255, 118, 74),
			}


func _draw() -> void:
	var palette: Dictionary = _palette()
	var shell: Color = palette["shell"]
	var core: Color = palette["core"]
	var beam: Color = palette["beam"]
	if hit_flash > 0.0:
		shell = shell.lightened(0.22)
		core = core.lightened(0.16)
		beam = beam.lightened(0.18)
	elif pulse_flash > 0.0:
		shell = shell.lightened(0.14)
		core = core.lightened(0.08)
		beam = beam.lightened(0.12)

	match objective_kind:
		KIND_BREACH_BEACON:
			_draw_breach_beacon(shell, core, beam)
		KIND_LIFT_ANCHOR:
			_draw_lift_anchor(shell, core, beam)
		KIND_COMMAND_BEACON:
			_draw_command_beacon(shell, core, beam)
		_:
			_draw_excavation_pylon(shell, core, beam)

	var health_ratio := float(health) / float(maxi(1, max_health))
	draw_rect(Rect2(Vector2(-30.0, -78.0), Vector2(60.0, 7.0)), Color8(24, 20, 18))
	draw_rect(Rect2(Vector2(-28.0, -76.0), Vector2(56.0 * health_ratio, 3.0)), Color(core.r, core.g, core.b, 0.95))
	if pulse_flash > 0.0:
		draw_arc(Vector2.ZERO, 36.0, -PI, PI, 30, Color(core.r, core.g, core.b, 0.46), 3.0, true)
	if health < max_health and max_health > 0:
		var bar_y := -40.0
		var bar_w := 34.0
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


func _draw_excavation_pylon(shell: Color, core: Color, beam: Color) -> void:
	draw_rect(Rect2(Vector2(-12.0, -46.0), Vector2(24.0, 58.0)), shell)
	draw_rect(Rect2(Vector2(-5.0, -72.0), Vector2(10.0, 28.0)), core)
	draw_circle(Vector2(0.0, -78.0), 8.0, beam)
	draw_line(Vector2(-10.0, 12.0), Vector2(-24.0, 34.0), shell, 5.0, true)
	draw_line(Vector2(10.0, 12.0), Vector2(24.0, 34.0), shell, 5.0, true)
	draw_line(Vector2(0.0, 12.0), Vector2(0.0, 36.0), shell, 4.0, true)


func _draw_breach_beacon(shell: Color, core: Color, beam: Color) -> void:
	draw_circle(Vector2.ZERO, 22.0, shell)
	draw_circle(Vector2.ZERO, 11.0, core)
	draw_rect(Rect2(Vector2(-8.0, -48.0), Vector2(16.0, 24.0)), shell)
	draw_circle(Vector2(0.0, -54.0), 9.0, beam)
	draw_line(Vector2(-18.0, 14.0), Vector2(-30.0, 28.0), shell, 4.0, true)
	draw_line(Vector2(18.0, 14.0), Vector2(30.0, 28.0), shell, 4.0, true)


func _draw_lift_anchor(shell: Color, core: Color, beam: Color) -> void:
	draw_circle(Vector2.ZERO, 20.0, shell)
	draw_circle(Vector2.ZERO, 10.0, Color8(28, 34, 46))
	draw_circle(Vector2.ZERO, 7.0, core)
	draw_rect(Rect2(Vector2(-6.0, -50.0), Vector2(12.0, 26.0)), shell)
	draw_line(Vector2(-22.0, 0.0), Vector2(-36.0, -20.0), beam, 4.0, true)
	draw_line(Vector2(22.0, 0.0), Vector2(36.0, -20.0), beam, 4.0, true)
	draw_line(Vector2(-20.0, 8.0), Vector2(-34.0, 28.0), shell, 4.0, true)
	draw_line(Vector2(20.0, 8.0), Vector2(34.0, 28.0), shell, 4.0, true)


func _draw_command_beacon(shell: Color, core: Color, beam: Color) -> void:
	draw_polygon(PackedVector2Array([
		Vector2(0.0, -54.0),
		Vector2(18.0, -8.0),
		Vector2(0.0, 24.0),
		Vector2(-18.0, -8.0),
	]), PackedColorArray([shell]))
	draw_circle(Vector2.ZERO, 10.0, core)
	draw_circle(Vector2(0.0, -60.0), 9.0, beam)
	draw_line(Vector2(-10.0, 24.0), Vector2(-24.0, 40.0), shell, 4.0, true)
	draw_line(Vector2(10.0, 24.0), Vector2(24.0, 40.0), shell, 4.0, true)
