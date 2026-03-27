extends Area2D

signal impacted(damage: int, target_structure_id: String)

var target_position := Vector2.ZERO
var direction := Vector2.DOWN
var speed := 360.0
var damage := 1
var lifetime := 2.4
var target_structure_id := ""
var trail_positions: Array[Vector2] = []
var trail_max := 3


func _ready() -> void:
	z_index = 23
	monitoring = false
	monitorable = false


func configure(origin: Vector2, new_target_position: Vector2, new_speed: float = 360.0, new_damage: int = 1, new_target_structure_id: String = "") -> void:
	global_position = origin
	target_position = new_target_position
	direction = (target_position - origin).normalized()
	speed = new_speed
	damage = new_damage
	target_structure_id = new_target_structure_id
	rotation = direction.angle()


func _physics_process(delta: float) -> void:
	trail_positions.push_front(global_position)
	if trail_positions.size() > trail_max:
		trail_positions.resize(trail_max)
	queue_redraw()

	var remaining_vector: Vector2 = target_position - global_position
	var travel_distance := speed * delta
	if remaining_vector.length() <= travel_distance + 14.0:
		impacted.emit(damage, target_structure_id)
		queue_free()
		return

	global_position += direction * travel_distance
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _draw() -> void:
	if trail_positions.size() >= 2:
		for i in range(trail_positions.size() - 1):
			var alpha := lerpf(0.4, 0.05, float(i) / float(trail_positions.size() - 1))
			var from_local := (trail_positions[i] - global_position).rotated(-rotation)
			var to_local := (trail_positions[i + 1] - global_position).rotated(-rotation)
			draw_line(from_local, to_local, Color(1.0, 0.45, 0.25, alpha), 3.0, true)

	draw_circle(Vector2.ZERO, 6.0, Color8(162, 214, 255))
	draw_circle(Vector2.ZERO, 3.0, Color8(246, 250, 255))
	draw_rect(Rect2(Vector2(-2.0, -3.0), Vector2(18.0, 6.0)), Color8(84, 141, 238))
