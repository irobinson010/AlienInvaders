extends Node2D

var bullet_scene: PackedScene
var range := 230.0
var fire_interval := 0.80
var cooldown := 0.35


func _ready() -> void:
	z_index = 12


func configure(new_bullet_scene: PackedScene) -> void:
	bullet_scene = new_bullet_scene


func _physics_process(delta: float) -> void:
	if bullet_scene == null:
		return

	cooldown = maxf(0.0, cooldown - delta)
	var target := _find_target()
	if target == null:
		return

	var aim := target.global_position - global_position
	rotation = aim.angle()
	if cooldown > 0.0:
		return

	cooldown = fire_interval
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position + aim.normalized() * 28.0
	bullet.configure(aim, 620.0, 1)
	get_parent().add_child(bullet)


func _find_target() -> Node2D:
	var best_target: Node2D
	var best_distance_sq := range * range

	for node in get_tree().get_nodes_in_group("aliens"):
		if node is Node2D:
			var alien := node as Node2D
			var distance_sq := global_position.distance_squared_to(alien.global_position)
			if distance_sq < best_distance_sq:
				best_distance_sq = distance_sq
				best_target = alien

	return best_target


func _draw() -> void:
	draw_circle(Vector2.ZERO, 18.0, Color8(71, 69, 58))
	draw_circle(Vector2.ZERO, 10.0, Color8(202, 180, 111))
	draw_rect(Rect2(Vector2(0.0, -4.0), Vector2(28.0, 8.0)), Color8(99, 128, 146))
