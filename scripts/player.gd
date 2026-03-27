extends CharacterBody2D

signal fired(origin: Vector2, direction: Vector2)

@export var move_speed := 270.0
@export var fire_interval := 0.16
var play_bounds := Rect2(Vector2(70.0, 250.0), Vector2(1140.0, 400.0))
var aim_direction := Vector2.RIGHT
var fire_cooldown := 0.0
var weapon_style := "nailgun"
var touch_controls_enabled := false
var touch_move_vector := Vector2.ZERO
var touch_fire_active := false
var touch_aim_direction := Vector2.RIGHT
var recoil_offset := 0.0
var recoil_decay := 12.0


func _ready() -> void:
	z_index = 20
	collision_layer = 1
	collision_mask = 0

	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 18.0
	collision.shape = shape
	add_child(collision)


func _physics_process(delta: float) -> void:
	var input_vector := touch_move_vector if touch_controls_enabled else Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vector * move_speed
	move_and_slide()

	var min_bounds := play_bounds.position
	var max_bounds := play_bounds.position + play_bounds.size
	global_position = global_position.clamp(min_bounds, max_bounds)

	if touch_controls_enabled:
		if touch_aim_direction.length_squared() > 0.001:
			aim_direction = touch_aim_direction.normalized()
	else:
		var mouse_vector := get_global_mouse_position() - global_position
		if mouse_vector.length_squared() > 1.0:
			aim_direction = mouse_vector.normalized()

	rotation = aim_direction.angle()
	fire_cooldown = maxf(0.0, fire_cooldown - delta)

	if recoil_offset > 0.01:
		recoil_offset = maxf(0.0, recoil_offset - recoil_decay * delta)
		queue_redraw()

	var wants_fire := touch_fire_active if touch_controls_enabled else (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_action_pressed("fire"))
	if wants_fire and fire_cooldown <= 0.0:
		fire_cooldown = fire_interval
		if weapon_style == "tractor_cannon":
			recoil_offset = 7.0
		elif weapon_style == "scrap_blaster":
			recoil_offset = 5.0
		else:
			recoil_offset = 4.0
		fired.emit(global_position + aim_direction * 28.0, aim_direction)


func set_fire_interval(new_fire_interval: float) -> void:
	fire_interval = new_fire_interval


func set_move_speed(new_move_speed: float) -> void:
	move_speed = new_move_speed


func set_weapon_style(new_weapon_style: String) -> void:
	weapon_style = new_weapon_style
	queue_redraw()


func set_touch_controls_enabled(enabled: bool) -> void:
	touch_controls_enabled = enabled
	if not enabled:
		touch_move_vector = Vector2.ZERO
		touch_fire_active = false


func set_touch_move_vector(new_move_vector: Vector2) -> void:
	touch_move_vector = new_move_vector.limit_length(1.0)


func clear_touch_movement() -> void:
	touch_move_vector = Vector2.ZERO


func set_touch_aim_direction(new_aim_direction: Vector2, fire_active: bool = true) -> void:
	if new_aim_direction.length_squared() > 0.001:
		touch_aim_direction = new_aim_direction.normalized()
	touch_fire_active = fire_active


func stop_touch_aim() -> void:
	touch_fire_active = false


func _draw() -> void:
	var recoil_vec := Vector2(-recoil_offset, 0.0)
	draw_circle(recoil_vec, 16.0, Color8(69, 107, 192))
	if weapon_style == "tractor_cannon":
		draw_rect(Rect2(Vector2(-2.0, -8.0) + recoil_vec, Vector2(30.0, 16.0)), Color8(96, 108, 124))
		draw_rect(Rect2(Vector2(18.0, -6.0) + recoil_vec, Vector2(18.0, 12.0)), Color8(189, 120, 56))
		draw_circle(Vector2(5.0, -14.0) + recoil_vec, 7.0, Color8(201, 186, 120))
	elif weapon_style == "scrap_blaster":
		draw_rect(Rect2(Vector2(-1.0, -7.0) + recoil_vec, Vector2(28.0, 14.0)), Color8(112, 132, 148))
		draw_rect(Rect2(Vector2(18.0, -5.0) + recoil_vec, Vector2(14.0, 10.0)), Color8(234, 155, 82))
		draw_circle(Vector2(6.0, -13.0) + recoil_vec, 6.0, Color8(227, 201, 127))
	else:
		draw_rect(Rect2(Vector2(2.0, -5.0) + recoil_vec, Vector2(24.0, 10.0)), Color8(242, 143, 59))
	draw_circle(Vector2(-5.0, -17.0) + recoil_vec, 10.0, Color8(245, 214, 181))
	draw_line(Vector2(-5.0, 11.0) + recoil_vec, Vector2(-13.0, 24.0) + recoil_vec, Color8(77, 58, 41), 4.0, true)
	draw_line(Vector2(3.0, 11.0) + recoil_vec, Vector2(11.0, 24.0) + recoil_vec, Color8(77, 58, 41), 4.0, true)
	draw_line(Vector2(-8.0, -4.0) + recoil_vec, Vector2(-20.0, 6.0) + recoil_vec, Color8(245, 214, 181), 4.0, true)
	if weapon_style == "tractor_cannon":
		draw_line(Vector2(2.0, -2.0) + recoil_vec, Vector2(36.0, -2.0) + recoil_vec, Color8(42, 40, 36), 10.0, true)
	elif weapon_style == "scrap_blaster":
		draw_line(Vector2(2.0, -2.0) + recoil_vec, Vector2(32.0, -2.0) + recoil_vec, Color8(48, 44, 38), 8.0, true)
	else:
		draw_line(Vector2(2.0, -2.0) + recoil_vec, Vector2(28.0, -2.0) + recoil_vec, Color8(56, 47, 39), 6.0, true)
