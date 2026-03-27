extends Area2D

signal build_requested(spot)

var occupied := false
var show_range_preview := false
var preview_range := 230.0
var preview_color := Color(0.4, 0.55, 0.7, 0.12)


func _ready() -> void:
	z_index = 8
	collision_layer = 8
	collision_mask = 0
	input_pickable = true

	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(72.0, 56.0)
	collision.shape = shape
	add_child(collision)

	input_event.connect(_on_input_event)


func mark_built() -> void:
	occupied = true
	show_range_preview = false
	queue_redraw()


func set_range_preview(show: bool, range_value: float = 230.0, color: Color = Color(0.4, 0.55, 0.7, 0.12)) -> void:
	show_range_preview = show and not occupied
	preview_range = range_value
	preview_color = color
	queue_redraw()


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if occupied:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		build_requested.emit(self)
	elif event is InputEventScreenTouch and event.pressed:
		build_requested.emit(self)


func _draw() -> void:
	var rect := Rect2(Vector2(-36.0, -28.0), Vector2(72.0, 56.0))
	if occupied:
		draw_rect(rect, Color8(89, 77, 58, 180))
		draw_rect(rect, Color8(204, 190, 154), false, 2.0)
	else:
		draw_rect(rect, Color8(255, 227, 130, 120))
		draw_rect(rect, Color8(255, 236, 177), false, 3.0)
		draw_line(Vector2(-14.0, 0.0), Vector2(14.0, 0.0), Color8(255, 248, 218), 4.0, true)
		draw_line(Vector2(0.0, -14.0), Vector2(0.0, 14.0), Color8(255, 248, 218), 4.0, true)

	if show_range_preview and not occupied:
		draw_arc(Vector2.ZERO, preview_range, -PI, PI, 48, preview_color, 2.0, true)
		draw_circle(Vector2.ZERO, preview_range, Color(preview_color.r, preview_color.g, preview_color.b, preview_color.a * 0.3))
