extends Node2D
class_name BackgroundPattern

@export var grid_size: float = 64.0
@export var line_color: Color = Color(0.2, 0.3, 0.2, 1)
@export var line_width: float = 1.0

func _ready() -> void:
	# Draw grid in _draw
	pass

func _draw() -> void:
	var viewport = get_viewport_rect()
	var start_x = -fmod(global_position.x, grid_size)
	var start_y = -fmod(global_position.y, grid_size)

	# Vertical lines
	var x = start_x
	while x < viewport.size.x:
		draw_line(Vector2(x, 0), Vector2(x, viewport.size.y), line_color, line_width)
		x += grid_size

	# Horizontal lines
	var y = start_y
	while y < viewport.size.y:
		draw_line(Vector2(0, y), Vector2(viewport.size.x, y), line_color, line_width)
		y += grid_size