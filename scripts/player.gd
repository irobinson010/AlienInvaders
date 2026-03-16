extends CharacterBody2D

signal fired(origin: Vector2, direction: Vector2)

@export var move_speed := 270.0
@export var fire_interval := 0.16
var play_bounds := Rect2(Vector2(70.0, 110.0), Vector2(1140.0, 540.0))
var aim_direction := Vector2.RIGHT
var fire_cooldown := 0.0


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
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vector * move_speed
	move_and_slide()

	var min_bounds := play_bounds.position
	var max_bounds := play_bounds.position + play_bounds.size
	global_position = global_position.clamp(min_bounds, max_bounds)

	var mouse_vector := get_global_mouse_position() - global_position
	if mouse_vector.length_squared() > 1.0:
		aim_direction = mouse_vector.normalized()

	rotation = aim_direction.angle()
	fire_cooldown = maxf(0.0, fire_cooldown - delta)

	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_action_pressed("fire")) and fire_cooldown <= 0.0:
		fire_cooldown = fire_interval
		fired.emit(global_position + aim_direction * 28.0, aim_direction)


func set_fire_interval(new_fire_interval: float) -> void:
	fire_interval = new_fire_interval


func _draw() -> void:
	draw_circle(Vector2.ZERO, 16.0, Color8(69, 107, 192))
	draw_rect(Rect2(Vector2(2.0, -5.0), Vector2(24.0, 10.0)), Color8(242, 143, 59))
	draw_circle(Vector2(-5.0, -17.0), 10.0, Color8(245, 214, 181))
	draw_line(Vector2(-5.0, 11.0), Vector2(-13.0, 24.0), Color8(77, 58, 41), 4.0, true)
	draw_line(Vector2(3.0, 11.0), Vector2(11.0, 24.0), Color8(77, 58, 41), 4.0, true)
	draw_line(Vector2(-8.0, -4.0), Vector2(-20.0, 6.0), Color8(245, 214, 181), 4.0, true)
	draw_line(Vector2(2.0, -2.0), Vector2(28.0, -2.0), Color8(56, 47, 39), 6.0, true)
