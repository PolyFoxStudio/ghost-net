extends Control

func _ready():
	set_process(false)
	set_process_input(false)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func _draw():
	var rect = get_viewport_rect()
	var w = rect.size.x
	var h = rect.size.y
	var c = Color(0, 0, 0, 0.06)
	var i = 0
	while i < h:
		draw_line(Vector2(0, i), Vector2(w, i), c, 1.0)
		i += 3
