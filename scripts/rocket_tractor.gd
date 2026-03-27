extends Node2D
class_name RocketTractor

signal rocket_launched(origin: Vector2)

var bullet_scene: PackedScene
var patrol_left := 164.0
var patrol_right := 1116.0
var patrol_speed := 84.0
var rocket_interval := 2.8
var rocket_damage := 5
var rocket_speed := 470.0
var rocket_range := 780.0
var move_direction := 1.0
var rocket_cooldown := 0.0
var support_active := false


func _ready() -> void:
	z_index = 14


func configure(new_bullet_scene: PackedScene, new_patrol_left: float, new_patrol_right: float, new_patrol_speed: float, new_rocket_interval: float, new_rocket_damage: int, new_rocket_speed: float) -> void:
	bullet_scene = new_bullet_scene
	patrol_left = new_patrol_left
	patrol_right = new_patrol_right
	patrol_speed = new_patrol_speed
	rocket_interval = new_rocket_interval
	rocket_damage = new_rocket_damage
	rocket_speed = new_rocket_speed
	rocket_cooldown = rocket_interval * 0.45


func set_stats(new_patrol_speed: float, new_rocket_interval: float, new_rocket_damage: int, new_rocket_speed: float) -> void:
	patrol_speed = new_patrol_speed
	rocket_interval = new_rocket_interval
	rocket_damage = new_rocket_damage
	rocket_speed = new_rocket_speed
	rocket_cooldown = minf(rocket_cooldown, rocket_interval)


func set_support_active(enabled: bool) -> void:
	support_active = enabled


func _physics_process(delta: float) -> void:
	if not support_active:
		return

	global_position.x += move_direction * patrol_speed * delta
	if global_position.x <= patrol_left:
		global_position.x = patrol_left
		move_direction = 1.0
	elif global_position.x >= patrol_right:
		global_position.x = patrol_right
		move_direction = -1.0

	rotation = 0.04 * move_direction
	rocket_cooldown = maxf(0.0, rocket_cooldown - delta)
	if rocket_cooldown > 0.0:
		return

	var target := _pick_target()
	if target == null:
		return

	_launch_rocket(target.global_position)
	rocket_cooldown = rocket_interval


func _pick_target() -> Node2D:
	var best_target: Node2D
	var best_distance_sq := rocket_range * rocket_range
	for node in get_tree().get_nodes_in_group("aliens"):
		if not (node is Node2D):
			continue
		if node.is_queued_for_deletion():
			continue

		var node_2d := node as Node2D
		var distance_sq := global_position.distance_squared_to(node_2d.global_position)
		if distance_sq < best_distance_sq:
			best_distance_sq = distance_sq
			best_target = node_2d
	return best_target


func _launch_rocket(target_position: Vector2) -> void:
	if bullet_scene == null:
		return
	if get_parent() == null:
		return

	var bullet := bullet_scene.instantiate() as Area2D
	var launch_origin := global_position + Vector2(18.0 * move_direction, -24.0)
	var direction := (target_position - launch_origin).normalized()
	bullet.global_position = launch_origin
	bullet.configure(direction, rocket_speed, rocket_damage, 1.9, 10.0, Color8(255, 229, 189), Color8(214, 66, 48))
	get_parent().add_child(bullet)
	rocket_launched.emit(launch_origin)


func _draw() -> void:
	draw_rect(Rect2(Vector2(-28.0, -12.0), Vector2(50.0, 24.0)), Color8(196, 54, 44))
	draw_rect(Rect2(Vector2(-8.0, -28.0), Vector2(20.0, 16.0)), Color8(224, 104, 78))
	draw_rect(Rect2(Vector2(4.0, -36.0), Vector2(22.0, 8.0)), Color8(76, 80, 88))
	draw_rect(Rect2(Vector2(16.0, -46.0), Vector2(10.0, 10.0)), Color8(242, 180, 122))
	draw_circle(Vector2(-16.0, 16.0), 10.0, Color8(49, 43, 37))
	draw_circle(Vector2(12.0, 16.0), 10.0, Color8(49, 43, 37))
	draw_circle(Vector2(-16.0, 16.0), 5.0, Color8(188, 178, 154))
	draw_circle(Vector2(12.0, 16.0), 5.0, Color8(188, 178, 154))
	draw_rect(Rect2(Vector2(-32.0, -4.0), Vector2(6.0, 12.0)), Color8(227, 212, 172))
	draw_circle(Vector2(28.0, -38.0), 5.0, Color8(255, 207, 120))
