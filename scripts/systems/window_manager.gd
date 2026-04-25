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

func get_app_window(app_name: String) -> Control:
	if _windows.has(app_name) and is_instance_valid(_windows[app_name]):
		return _windows[app_name]
	return null
