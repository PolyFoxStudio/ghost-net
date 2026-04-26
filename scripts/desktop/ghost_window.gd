extends PanelContainer

@export var app_name: String = "APP"
@export var default_size: Vector2 = Vector2(900, 600)

var _is_dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO
var _is_maximised: bool = false
var _pre_max_rect: Rect2

var _is_resizing: bool = false
var _resize_dir: Vector2 = Vector2.ZERO
var _resize_start_global_pos: Vector2
var _resize_start_pos: Vector2
var _resize_start_size: Vector2
var _resize_overlay: Control

@onready var title_label = $VBoxContainer/TitleBar/HBoxContainer/WindowTitle
@onready var app_container = $VBoxContainer/AppContainer

func _ready():
	title_label.text = app_name
	size = default_size
	
	var close_btn = $VBoxContainer/TitleBar/HBoxContainer/TrafficLights/CloseBtn
	var min_btn = $VBoxContainer/TitleBar/HBoxContainer/TrafficLights/MinimiseBtn
	var max_btn = $VBoxContainer/TitleBar/HBoxContainer/TrafficLights/MaximiseBtn
	
	close_btn.mouse_entered.connect(func(): close_btn.text = "✕")
	close_btn.mouse_exited.connect(func(): close_btn.text = "●")
	min_btn.mouse_entered.connect(func(): min_btn.text = "−")
	min_btn.mouse_exited.connect(func(): min_btn.text = "●")
	max_btn.mouse_entered.connect(func(): max_btn.text = "□")
	max_btn.mouse_exited.connect(func(): max_btn.text = "●")
	
	close_btn.pressed.connect(_on_close)
	min_btn.pressed.connect(_on_minimise)
	max_btn.pressed.connect(_on_maximise)
	
	var title_bar = $VBoxContainer/TitleBar
	title_bar.gui_input.connect(_on_title_bar_gui_input)
	gui_input.connect(_on_window_gui_input)

	# Create resize overlay — full window size, sits on top, catches edge/corner input
	_resize_overlay = Control.new()
	_resize_overlay.name = "ResizeOverlay"
	_resize_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_resize_overlay.mouse_filter = Control.MOUSE_FILTER_PASS
	_resize_overlay.mouse_default_cursor_shape = Control.CURSOR_ARROW
	_resize_overlay.gui_input.connect(_on_resize_overlay_gui_input)
	_resize_overlay.mouse_entered.connect(func():
		if not _is_dragging:
			_update_cursor_shape(_resize_overlay.get_local_mouse_position())
	)
	add_child(_resize_overlay)
	
func _on_close():
	WindowManager.close_window(app_name)

func _on_minimise():
	WindowManager.minimise_window(app_name)

func _on_maximise():
	if _is_maximised:
		position = _pre_max_rect.position
		size = _pre_max_rect.size
		_is_maximised = false
	else:
		_pre_max_rect = Rect2(position, size)
		var viewport_size = get_viewport_rect().size
		position = Vector2(0, 32)
		size = Vector2(viewport_size.x, viewport_size.y - 32)
		_is_maximised = true
		
func _on_title_bar_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_is_dragging = true
			_drag_offset = event.position
			WindowManager.bring_to_front(self)
		else:
			_is_dragging = false
	elif event is InputEventMouseMotion and _is_dragging and not _is_maximised:
		position += event.relative
		
func _on_window_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		WindowManager.bring_to_front(self)

func grab_focus_internal():
	pass

func _get_resize_dir(local_pos: Vector2) -> Vector2:
	var dir = Vector2.ZERO
	var margin = 6.0
	if local_pos.x < margin:
		dir.x = -1
	elif local_pos.x > size.x - margin:
		dir.x = 1
	if local_pos.y < margin:
		dir.y = -1
	elif local_pos.y > size.y - margin:
		dir.y = 1
	return dir

func _update_cursor_shape(local_pos: Vector2):
	var dir = _get_resize_dir(local_pos)
	if dir == Vector2(-1, -1) or dir == Vector2(1, 1):
		_resize_overlay.mouse_default_cursor_shape = Control.CURSOR_FDIAGSIZE
	elif dir == Vector2(1, -1) or dir == Vector2(-1, 1):
		_resize_overlay.mouse_default_cursor_shape = Control.CURSOR_BDIAGSIZE
	elif dir.x != 0:
		_resize_overlay.mouse_default_cursor_shape = Control.CURSOR_HSIZE
	elif dir.y != 0:
		_resize_overlay.mouse_default_cursor_shape = Control.CURSOR_VSIZE
	else:
		_resize_overlay.mouse_default_cursor_shape = Control.CURSOR_ARROW

func _on_resize_overlay_gui_input(event: InputEvent):
	if _is_maximised:
		_resize_overlay.mouse_default_cursor_shape = Control.CURSOR_ARROW
		return
		
	if event is InputEventMouseMotion:
		if _is_resizing:
			var delta = get_global_mouse_position() - _resize_start_global_pos
			var new_pos = _resize_start_pos
			var new_size = _resize_start_size
			
			if _resize_dir.x == 1:
				new_size.x += delta.x
			elif _resize_dir.x == -1:
				new_size.x -= delta.x
				new_pos.x += delta.x
				
			if _resize_dir.y == 1:
				new_size.y += delta.y
			elif _resize_dir.y == -1:
				new_size.y -= delta.y
				new_pos.y += delta.y
				
			var min_sz = Vector2(400, 300)
			if new_size.x < min_sz.x:
				if _resize_dir.x == -1:
					new_pos.x -= (min_sz.x - new_size.x)
				new_size.x = min_sz.x
			if new_size.y < min_sz.y:
				if _resize_dir.y == -1:
					new_pos.y -= (min_sz.y - new_size.y)
				new_size.y = min_sz.y
				
			position = new_pos
			size = new_size
		else:
			var dir = _get_resize_dir(event.position)
			if dir != Vector2.ZERO:
				_update_cursor_shape(event.position)
			else:
				_resize_overlay.mouse_default_cursor_shape = Control.CURSOR_ARROW
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var dir = _get_resize_dir(event.position)
				if dir != Vector2.ZERO:
					_is_resizing = true
					_resize_dir = dir
					_resize_start_global_pos = get_global_mouse_position()
					_resize_start_pos = position
					_resize_start_size = size
					WindowManager.bring_to_front(self)
					get_viewport().set_input_as_handled()
			else:
				if _is_resizing:
					_is_resizing = false
					get_viewport().set_input_as_handled()
