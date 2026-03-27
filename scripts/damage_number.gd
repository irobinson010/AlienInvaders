extends Node2D

var text := ""
var text_color := Color8(255, 255, 255)
var lifetime := 1.0
var elapsed := 0.0
var rise_speed := 60.0
var font_size := 16


func _ready() -> void:
	z_index = 50


func configure(new_text: String, new_color: Color = Color8(255, 255, 255), new_lifetime: float = 1.0, new_font_size: int = 16) -> void:
	text = new_text
	text_color = new_color
	lifetime = new_lifetime
	font_size = new_font_size


func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= lifetime:
		queue_free()
		return
	position.y -= rise_speed * delta
	rise_speed = maxf(20.0, rise_speed - 40.0 * delta)
	queue_redraw()


func _draw() -> void:
	var alpha := clampf(1.0 - (elapsed / lifetime), 0.0, 1.0)
	var color := Color(text_color.r, text_color.g, text_color.b, alpha)
	var font := ThemeDB.fallback_font
	if font == null:
		return
	draw_string(font, Vector2(-40.0, 0.0), text, HORIZONTAL_ALIGNMENT_CENTER, 80.0, font_size, color)
