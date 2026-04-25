extends PanelContainer

@export var app_name: String = "APP"
@export var default_size: Vector2 = Vector2(900, 600)

var _is_dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO
var _is_maximised: bool = false
var _pre_max_rect: Rect2

@onready var title_label = $VBoxContainer/TitleBar/HBoxContainer/WindowTitle
@onready var app_container = $VBoxContainer/AppContainer

func _ready():
	title_label.text = app_name
	size = default_size
	
	var close_btn = $VBoxContainer/TitleBar/HBoxContainer/TrafficLights/CloseBtn
	var min_btn = $VBoxContainer/TitleBar/HBoxContainer/TrafficLights/MinimiseBtn
	var max_btn = $VBoxContainer/TitleBar/HBoxContainer/TrafficLights/MaximiseBtn
	
	close_btn.pressed.connect(_on_close)
	min_btn.pressed.connect(_on_minimise)
	max_btn.pressed.connect(_on_maximise)
	
	var title_bar = $VBoxContainer/TitleBar
	title_bar.gui_input.connect(_on_title_bar_gui_input)
	gui_input.connect(_on_window_gui_input)
	
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
