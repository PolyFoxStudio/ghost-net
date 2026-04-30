extends ColorRect

@onready var term_btn = $HBoxContainer/AppLaunchers/TerminalBtn
@onready var nav_btn = $HBoxContainer/AppLaunchers/NavigatorBtn
@onready var pl_btn = $HBoxContainer/AppLaunchers/PhantomLinkBtn
@onready var player_label = $HBoxContainer/PlayerLabel

var term_scene = preload("res://scenes/desktop/apps/TerminalWindow.tscn")
var nav_scene = preload("res://scenes/desktop/apps/NavigatorWindow.tscn")
var pl_scene = preload("res://scenes/desktop/apps/PhantomLinkWindow.tscn")

var unread_count = 0

func _ready() -> void:
	term_btn.pressed.connect(func(): WindowManager.open_window(term_scene, "TERMINAL"))
	nav_btn.pressed.connect(func(): WindowManager.open_window(nav_scene, "NAVIGATOR"))
	pl_btn.pressed.connect(func(): 
		WindowManager.open_window(pl_scene, "PHANTOMLINK")
		unread_count = 0
		_update_pl_btn()
	)
	
	if GameState.player_name != "":
		player_label.text = "%s / ghost" % GameState.player_name
	else:
		player_label.text = "unknown / ghost"
		
	if GlobalSignals.has_signal("phantomlink_message_received"):
		GlobalSignals.phantomlink_message_received.connect(_on_pl_message)
	if GlobalSignals.has_signal("window_restored"):
		GlobalSignals.window_restored.connect(_on_window_restored)
	
	if GlobalSignals.has_signal("window_focused"):
		GlobalSignals.window_focused.connect(_on_window_focused)
	if GlobalSignals.has_signal("window_unfocused"):
		GlobalSignals.window_unfocused.connect(_on_window_unfocused)

	_set_button_active(term_btn, false)
	_set_button_active(nav_btn, false)
	_set_button_active(pl_btn, false)

func _set_button_active(btn: Button, active: bool) -> void:
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color.TRANSPARENT
	
	if active:
		sb.border_width_left = 2
		sb.border_color = Color("#00ff41")
		btn.add_theme_color_override("font_color", Color("#e0e0e0"))
	else:
		sb.border_width_left = 0
		btn.add_theme_color_override("font_color", Color("#888888"))
		
	btn.add_theme_stylebox_override("normal", sb)
	btn.add_theme_stylebox_override("hover", sb)
	btn.add_theme_stylebox_override("pressed", sb)
	btn.add_theme_stylebox_override("focus", sb)

func _on_window_focused(app_name: String) -> void:
	if app_name == "TERMINAL": _set_button_active(term_btn, true)
	elif app_name == "NAVIGATOR": _set_button_active(nav_btn, true)
	elif app_name == "PHANTOMLINK": _set_button_active(pl_btn, true)

func _on_window_unfocused(app_name: String) -> void:
	if app_name == "TERMINAL": _set_button_active(term_btn, false)
	elif app_name == "NAVIGATOR": _set_button_active(nav_btn, false)
	elif app_name == "PHANTOMLINK": _set_button_active(pl_btn, false)

func _on_pl_message(_thread_id: String, _beat_id: String) -> void:
	unread_count += 1
	_update_pl_btn()

func _on_window_restored(app_name: String) -> void:
	if app_name == "PHANTOMLINK":
		unread_count = 0
		_update_pl_btn()

func _update_pl_btn() -> void:
	if unread_count > 0:
		pl_btn.text = "[✉ PHANTOMLINK (%d)]" % unread_count
	else:
		pl_btn.text = "[✉ PHANTOMLINK]"

func _process(_delta: float) -> void:
	pass
