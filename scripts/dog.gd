extends CharacterBody2D

signal barked(world_position: Vector2)
signal growled(world_position: Vector2)

const PATCH_NONE := 0
const PATCH_SCRAP := 1
const PATCH_GUARD := 2
const PATCH_SCOUT := 3

@export var follow_speed := 250.0
@export var pounce_speed := 420.0
@export var detection_range := 180.0
@export var bite_range := 26.0
@export var bite_cooldown_time := 0.95

var player_ref: CharacterBody2D
var target: Node2D
var bite_cooldown := 0.0
var bark_cooldown := 0.0
var bark_range := 0.0
var bark_stun_duration := 0.0
var path_kind := PATCH_NONE
var path_rank := 0
var salvage_counter := 0
var collar_color := Color8(214, 188, 118)
var bark_flash := 0.0


func _ready() -> void:
	z_index = 19
	collision_layer = 16
	collision_mask = 0

	var collision: CollisionShape2D = CollisionShape2D.new()
	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = 14.0
	collision.shape = shape
	add_child(collision)


func set_player(new_player: CharacterBody2D) -> void:
	player_ref = new_player


func apply_path_rank(new_path_kind: int, new_path_rank: int) -> void:
	path_kind = new_path_kind
	path_rank = new_path_rank
	salvage_counter = 0
	follow_speed = 250.0
	pounce_speed = 420.0
	detection_range = 180.0
	bite_range = 26.0
	bite_cooldown_time = 0.95
	bark_range = 0.0
	bark_stun_duration = 0.0
	collar_color = Color8(214, 188, 118)

	match path_kind:
		PATCH_SCRAP:
			follow_speed = 270.0
			detection_range = 195.0
			collar_color = Color8(232, 187, 94)
		PATCH_GUARD:
			detection_range = 215.0 + float(path_rank - 1) * 28.0
			pounce_speed = 435.0 + float(path_rank - 1) * 20.0
			bite_cooldown_time = 0.85
			bark_range = 150.0 + float(path_rank - 1) * 38.0
			bark_stun_duration = 0.75 + float(path_rank - 1) * 0.35
			collar_color = Color8(233, 98, 83)
		PATCH_SCOUT:
			follow_speed = 282.0
			detection_range = 220.0
			collar_color = Color8(107, 192, 226)

	queue_redraw()


func claim_salvage_bonus() -> int:
	if path_kind != PATCH_SCRAP or path_rank <= 0:
		return 0

	salvage_counter += 1
	match path_rank:
		1:
			if salvage_counter % 3 == 0:
				return 1
		2:
			if salvage_counter % 2 == 0:
				return 1
		3:
			var bonus := 1
			if salvage_counter % 3 == 0:
				bonus += 1
			return bonus

	return 0


func _physics_process(delta: float) -> void:
	if player_ref == null or not is_instance_valid(player_ref):
		return

	bite_cooldown = maxf(0.0, bite_cooldown - delta)
	bark_cooldown = maxf(0.0, bark_cooldown - delta)
	if bark_flash > 0.0:
		bark_flash = maxf(0.0, bark_flash - delta)
		queue_redraw()
	if target != null and not is_instance_valid(target):
		target = null

	if target == null:
		target = _find_target()

	var follow_anchor: Vector2 = player_ref.global_position + Vector2(-38.0, 26.0).rotated(player_ref.rotation)
	var move_vector: Vector2 = follow_anchor - global_position
	var move_speed: float = follow_speed

	if target != null:
		var chase_vector: Vector2 = target.global_position - global_position
		var max_target_distance: float = detection_range * 1.8
		if chase_vector.length() > max_target_distance:
			target = null
		else:
			move_vector = chase_vector
			move_speed = pounce_speed
			if path_kind == PATCH_GUARD:
				_try_guard_bark()
			if chase_vector.length() <= bite_range and bite_cooldown <= 0.0:
				if target.has_method("take_damage"):
					target.take_damage(1)
				growled.emit(global_position)
				bite_cooldown = bite_cooldown_time

	if move_vector.length() > 4.0:
		velocity = move_vector.normalized() * move_speed
		rotation = velocity.angle()
	else:
		velocity = Vector2.ZERO

	move_and_slide()


func _try_guard_bark() -> void:
	if bark_range <= 0.0 or bark_cooldown > 0.0:
		return

	var stunned_any := false
	for node in get_tree().get_nodes_in_group("aliens"):
		if node is Node2D:
			var alien: Node2D = node
			if global_position.distance_to(alien.global_position) <= bark_range and alien.has_method("apply_stun"):
				alien.apply_stun(bark_stun_duration)
				stunned_any = true

	if stunned_any:
		bark_cooldown = maxf(2.8, 7.2 - float(path_rank) * 1.45)
		bark_flash = 0.16
		barked.emit(global_position)
		queue_redraw()


func _find_target() -> Node2D:
	var best_target: Node2D
	var best_distance_sq: float = detection_range * detection_range

	for node in get_tree().get_nodes_in_group("aliens"):
		if node is Node2D:
			var alien: Node2D = node
			var distance_sq: float = global_position.distance_squared_to(alien.global_position)
			if distance_sq < best_distance_sq:
				best_distance_sq = distance_sq
				best_target = alien

	return best_target


func _draw() -> void:
	if bark_flash > 0.0:
		draw_arc(Vector2.ZERO, 28.0, -0.55, 0.55, 16, Color8(245, 243, 219), 4.0, true)
		draw_arc(Vector2.ZERO, 35.0, -0.55, 0.55, 16, Color8(245, 243, 219), 3.0, true)
	draw_circle(Vector2(-4.0, 0.0), 13.0, Color8(169, 120, 72))
	draw_circle(Vector2(11.0, -4.0), 9.0, Color8(187, 137, 84))
	draw_circle(Vector2(15.0, -6.0), 2.2, Color8(28, 23, 20))
	draw_circle(Vector2(18.0, -1.0), 1.8, Color8(28, 23, 20))
	draw_line(Vector2(-16.0, 2.0), Vector2(-29.0, -9.0), Color8(169, 120, 72), 4.0, true)
	draw_line(Vector2(-4.0, 10.0), Vector2(-8.0, 22.0), Color8(95, 67, 43), 4.0, true)
	draw_line(Vector2(7.0, 10.0), Vector2(3.0, 22.0), Color8(95, 67, 43), 4.0, true)
	draw_colored_polygon(PackedVector2Array([Vector2(5.0, -10.0), Vector2(10.0, -24.0), Vector2(14.0, -9.0)]), Color8(120, 80, 48))
	draw_colored_polygon(PackedVector2Array([Vector2(14.0, -9.0), Vector2(20.0, -23.0), Vector2(22.0, -8.0)]), Color8(120, 80, 48))
	draw_circle(Vector2(0.0, -8.0), 4.0, collar_color)
