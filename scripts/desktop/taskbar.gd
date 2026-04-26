extends PanelContainer
	
@onready var clock_label = $HBoxContainer/StatusIndicators/ClockLabel
@onready var conn_indicator = $HBoxContainer/StatusIndicators/ConnectionIndicator
@onready var trace_indicator = $HBoxContainer/StatusIndicators/TraceIndicator

@onready var term_btn = $HBoxContainer/AppLaunchers/TerminalBtn
@onready var nav_btn = $HBoxContainer/AppLaunchers/NavigatorBtn
@onready var notes_btn = $HBoxContainer/AppLaunchers/NotesBtn
@onready var files_btn = $HBoxContainer/AppLaunchers/FilesBtn

@onready var min_tray = $HBoxContainer/MinimisedTray

var _min_buttons: Dictionary = {}

var term_scene = preload("res://scenes/desktop/apps/TerminalWindow.tscn")
var nav_scene = preload("res://scenes/desktop/apps/NavigatorWindow.tscn")
var notes_scene = preload("res://scenes/desktop/apps/NotesWindow.tscn")
var files_scene = preload("res://scenes/desktop/apps/FilesWindow.tscn")

func _ready():
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.timeout.connect(_update_clock)
	add_child(timer)
	_update_clock()
	
	GlobalSignals.machine_connected.connect(_on_connected)
	GlobalSignals.machine_disconnected.connect(_on_disconnected)
	GlobalSignals.tier3_triggered.connect(_on_trace_triggered)
	GlobalSignals.trace_completed.connect(_on_trace_ended)
	if GlobalSignals.has_signal("cloak_expired"):
		GlobalSignals.cloak_expired.connect(_on_trace_ended)
	
	term_btn.pressed.connect(func(): WindowManager.open_window(term_scene, "TERMINAL"))
	nav_btn.pressed.connect(func(): WindowManager.open_window(nav_scene, "NAVIGATOR"))
	notes_btn.pressed.connect(func(): WindowManager.open_window(notes_scene, "NOTES"))
	files_btn.pressed.connect(func(): WindowManager.open_window(files_scene, "FILES"))

	GlobalSignals.window_minimised.connect(_on_window_minimised)
	GlobalSignals.window_restored.connect(_on_window_restored)
	GlobalSignals.window_closed.connect(_on_window_closed)

func _on_window_minimised(app_name: String):
	if _min_buttons.has(app_name): return
	var btn = Button.new()
	btn.text = "[ %s ]" % app_name.to_upper()
	btn.add_theme_font_size_override("font_size", 11)
	btn.add_theme_color_override("font_color", Color("#c0c0c0"))
	btn.add_theme_color_override("font_hover_color", Color("#00ff41"))
	var sb = StyleBoxEmpty.new()
	btn.add_theme_stylebox_override("normal", sb)
	btn.add_theme_stylebox_override("hover", sb)
	btn.add_theme_stylebox_override("pressed", sb)
	btn.add_theme_stylebox_override("focus", sb)
	btn.pressed.connect(func(): WindowManager.restore_window(app_name))
	min_tray.add_child(btn)
	_min_buttons[app_name] = btn

func _on_window_restored(app_name: String):
	if _min_buttons.has(app_name):
		_min_buttons[app_name].queue_free()
		_min_buttons.erase(app_name)

func _on_window_closed(app_name: String):
	if _min_buttons.has(app_name):
		_min_buttons[app_name].queue_free()
		_min_buttons.erase(app_name)

func _update_clock():
	var time = Time.get_time_dict_from_system()
	clock_label.text = "%02d:%02d:%02d" % [time.hour, time.minute, time.second]

func _on_connected(machine):
	conn_indicator.text = "◉ %s" % machine.hostname
	conn_indicator.add_theme_color_override("font_color", Color("#00ff41"))

func _on_disconnected(machine):
	conn_indicator.text = "◉ LOCAL"
	conn_indicator.add_theme_color_override("font_color", Color("#4a4a4a"))

func _on_trace_triggered(machine):
	trace_indicator.show()

func _on_trace_ended(machine):
	trace_indicator.hide()
	
