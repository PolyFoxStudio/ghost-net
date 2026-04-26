extends Node

var _windows: Dictionary = {}
var _window_layer: Control

func set_window_layer(layer: Control):
	_window_layer = layer

func open_window(window_scene: PackedScene, app_name: String) -> Control:
	if _windows.has(app_name) and is_instance_valid(_windows[app_name]):
		var existing = _windows[app_name]
		existing.show()
		bring_to_front(existing)
		return existing
		
	if not _window_layer:
		push_error("WindowManager: No window layer set!")
		return null
		
	var window = window_scene.instantiate()
	window.app_name = app_name
	_window_layer.add_child(window)
	_windows[app_name] = window
	
	var offset = _windows.size() * 20
	window.position = Vector2(100 + offset, 100 + offset)
	
	bring_to_front(window)
	window.call_deferred("grab_focus_internal")
	return window

func close_window(app_name: String):
	if _windows.has(app_name) and is_instance_valid(_windows[app_name]):
		var window = _windows[app_name]
		window.queue_free()
		_windows.erase(app_name)

func minimise_window(app_name: String):
	if _windows.has(app_name) and is_instance_valid(_windows[app_name]):
		_windows[app_name].hide()

func bring_to_front(window: Control):
	if _window_layer and is_instance_valid(window) and window.get_parent() == _window_layer:
		_window_layer.move_child(window, _window_layer.get_child_count() - 1)
		window.show()
		if window.has_method("grab_focus_internal"):
			window.grab_focus_internal()

func reposition_windows():
	if not is_instance_valid(_window_layer): return
	var parent_size = _window_layer.size
	for app_name in _windows:
		var window = _windows[app_name]
		if is_instance_valid(window):
			var w_size = window.size
			var w_pos = window.position
			var new_x = clamp(w_pos.x, 0, max(0, parent_size.x - w_size.x))
			var new_y = clamp(w_pos.y, 0, max(0, parent_size.y - w_size.y))
			window.position = Vector2(new_x, new_y)

func get_app_window(app_name: String) -> Control:
	if _windows.has(app_name) and is_instance_valid(_windows[app_name]):
		return _windows[app_name]
	return null
