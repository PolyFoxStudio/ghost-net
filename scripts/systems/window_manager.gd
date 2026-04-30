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
	
	# Clamp so window never spawns behind taskbar (36px) or off screen
	var vp = _window_layer.get_viewport_rect().size
	window.position.x = clamp(window.position.x, 0, max(0, vp.x - window.default_size.x))
	window.position.y = clamp(window.position.y, 44, max(44, vp.y - window.default_size.y))
	
	bring_to_front(window)
	window.call_deferred("grab_focus_internal")
	return window

func close_window(app_name: String):
	if _windows.has(app_name) and is_instance_valid(_windows[app_name]):
		var window = _windows[app_name]
		window.queue_free()
		_windows.erase(app_name)
		GlobalSignals.window_closed.emit(app_name)

func minimise_window(app_name: String):
	if _windows.has(app_name) and is_instance_valid(_windows[app_name]):
		_windows[app_name].hide()
		GlobalSignals.window_minimised.emit(app_name)

func restore_window(app_name: String):
	if _windows.has(app_name) and is_instance_valid(_windows[app_name]):
		bring_to_front(_windows[app_name])
		GlobalSignals.window_restored.emit(app_name)

func bring_to_front(window: Control):
	if _window_layer and is_instance_valid(window) and window.get_parent() == _window_layer:
		# Dim all windows
		for app_name in _windows:
			var w = _windows[app_name]
			if is_instance_valid(w) and w.has_method("set_focused"):
				w.set_focused(false)
				GlobalSignals.window_unfocused.emit(app_name)
		# Also dim any viewer windows not in _windows dict
		for child in _window_layer.get_children():
			if child.has_method("set_focused"):
				child.set_focused(false)
				if child.has_method("get_app_name"):
					GlobalSignals.window_unfocused.emit(child.get_app_name())
		
		_window_layer.move_child(window, _window_layer.get_child_count() - 1)
		window.show()
		
		var app_name_focused = window.app_name if "app_name" in window else "UNKNOWN"
		
		if window.has_method("set_focused"):
			window.set_focused(true)
			GlobalSignals.window_focused.emit(app_name_focused)
		if window.has_method("grab_focus_internal"):
			window.grab_focus_internal()

func reposition_windows():
	if not is_instance_valid(_window_layer): return
	var parent_size = _window_layer.size
	for app_name in _windows:
		var window = _windows[app_name]
		if is_instance_valid(window):
			var new_x = clamp(window.position.x, 0, max(0, parent_size.x - window.size.x))
			var new_y = clamp(window.position.y, 44, max(44, parent_size.y - window.size.y))
			window.position = Vector2(new_x, new_y)

func get_app_window(app_name: String) -> Control:
	if _windows.has(app_name) and is_instance_valid(_windows[app_name]):
		return _windows[app_name]
	return null

func get_window_layer() -> Control:
	return _window_layer
