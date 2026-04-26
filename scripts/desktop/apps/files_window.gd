extends "res://scripts/desktop/ghost_window.gd"

@onready var locations_list = $VBoxContainer/AppContainer/HSplitContainer/Sidebar/VBoxContainer/LocationsList
@onready var path_label = $VBoxContainer/AppContainer/HSplitContainer/MainPanel/PathBar/HBoxContainer/PathLabel
@onready var file_grid = $VBoxContainer/AppContainer/HSplitContainer/MainPanel/ScrollContainer/FileGrid
@onready var back_btn = $VBoxContainer/AppContainer/HSplitContainer/MainPanel/PathBar/HBoxContainer/BackBtn
@onready var fwd_btn = $VBoxContainer/AppContainer/HSplitContainer/MainPanel/PathBar/HBoxContainer/ForwardBtn

var current_machine = null
var current_path = "/"
var history = []
var history_index = -1

var viewer_scene = preload("res://scenes/desktop/apps/FileViewerWindow.tscn")

func _ready():
	super._ready()
	
	current_machine = NetworkManager.get_machine("127.0.0.1")
	_populate_sidebar()
	_navigate_to("/")
	
	back_btn.pressed.connect(_on_back)
	fwd_btn.pressed.connect(_on_forward)
	
	GlobalSignals.machine_discovered.connect(func(m): _populate_sidebar())
	GlobalSignals.machine_scanned.connect(func(m): _populate_sidebar())
	GlobalSignals.machine_connected.connect(func(m): _populate_sidebar())
	GlobalSignals.machine_disconnected.connect(func(m): _populate_sidebar())

func _populate_sidebar():
	for child in locations_list.get_children():
		child.queue_free()
	
	var local_btn = Button.new()
	local_btn.text = "⬛ local machine"
	local_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_style_sidebar_btn(local_btn)
	local_btn.pressed.connect(func(): _switch_machine("127.0.0.1"))
	locations_list.add_child(local_btn)
	
	for ip in NetworkManager.discovered_machines:
		if ip == "127.0.0.1": continue
		var machine = NetworkManager.get_machine(ip)
		var btn = Button.new()
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		
		if machine.is_player_connected:
			btn.text = "⬛ " + machine.hostname
			_style_sidebar_btn(btn)
			btn.pressed.connect(func(): _switch_machine(ip))
		else:
			btn.text = "🔒 " + machine.hostname
			_style_sidebar_btn_locked(btn)
			
		locations_list.add_child(btn)

func _style_sidebar_btn(btn: Button):
	btn.add_theme_color_override("font_color", Color("#c0c0c0"))
	btn.add_theme_color_override("font_hover_color", Color("#00ff41"))
	btn.add_theme_font_size_override("font_size", 12)
	var sb = StyleBoxEmpty.new()
	btn.add_theme_stylebox_override("normal", sb)
	btn.add_theme_stylebox_override("hover", sb)
	btn.add_theme_stylebox_override("pressed", sb)
	btn.add_theme_stylebox_override("focus", sb)

func _style_sidebar_btn_locked(btn: Button):
	btn.add_theme_color_override("font_color", Color("#4a4a4a"))
	btn.add_theme_font_size_override("font_size", 12)
	var sb = StyleBoxEmpty.new()
	btn.add_theme_stylebox_override("normal", sb)
	btn.add_theme_stylebox_override("hover", sb)
	btn.add_theme_stylebox_override("pressed", sb)
	btn.add_theme_stylebox_override("focus", sb)

func _switch_machine(ip: String):
	current_machine = NetworkManager.get_machine(ip)
	history.clear()
	history_index = -1
	_navigate_to("/")

func _navigate_to(path: String, add_to_history: bool = true):
	if current_machine == null: return
	
	if add_to_history:
		if history_index < history.size() - 1:
			history.resize(history_index + 1)
		history.append(path)
		history_index += 1
		
	current_path = path
	path_label.text = path
	back_btn.disabled = history_index <= 0
	fwd_btn.disabled = history_index >= history.size() - 1
	
	_render_files()

func _on_back():
	if history_index > 0:
		history_index -= 1
		_navigate_to(history[history_index], false)

func _on_forward():
	if history_index < history.size() - 1:
		history_index += 1
		_navigate_to(history[history_index], false)

func _render_files():
	for child in file_grid.get_children():
		child.queue_free()
	
	if current_machine == null: return
	var dir_node = current_machine.filesystem.get_node_at_path(current_path)
	if not dir_node or not dir_node.is_directory: return
	
	for name in dir_node.children:
		var node = dir_node.children[name]
		var hbox = HBoxContainer.new()
		
		var icon_lbl = Label.new()
		icon_lbl.text = "📁" if node.is_directory else "📄"
		icon_lbl.add_theme_font_size_override("font_size", 12)
		if node.is_directory: icon_lbl.add_theme_color_override("font_color", Color("#00ff41"))
		
		var name_btn = Button.new()
		name_btn.text = name
		name_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		name_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_btn.add_theme_font_size_override("font_size", 12)
		
		if node.is_hidden:
			name_btn.add_theme_color_override("font_color", Color("#4a4a4a"))
		else:
			name_btn.add_theme_color_override("font_color", Color("#c0c0c0"))
			name_btn.add_theme_color_override("font_hover_color", Color("#00ff41"))
			
		var sb = StyleBoxEmpty.new()
		name_btn.add_theme_stylebox_override("normal", sb)
		name_btn.add_theme_stylebox_override("hover", sb)
		name_btn.add_theme_stylebox_override("pressed", sb)
		name_btn.add_theme_stylebox_override("focus", sb)
		
		if node.is_directory:
			name_btn.pressed.connect(func(): _navigate_to(current_path.path_join(name).simplify_path()))
		else:
			name_btn.pressed.connect(func(): _open_viewer(node))
		
		var type_lbl = Label.new()
		type_lbl.text = "DIR" if node.is_directory else "FILE"
		type_lbl.custom_minimum_size = Vector2(50, 0)
		type_lbl.add_theme_font_size_override("font_size", 12)
		type_lbl.add_theme_color_override("font_color", Color("#4a4a4a"))
		
		var size_lbl = Label.new()
		size_lbl.text = "—" if node.is_directory else "%.1f KB" % (node.content.length() / 1024.0 + 0.1)
		size_lbl.custom_minimum_size = Vector2(60, 0)
		size_lbl.add_theme_font_size_override("font_size", 12)
		size_lbl.add_theme_color_override("font_color", Color("#4a4a4a"))
		
		hbox.add_child(icon_lbl)
		hbox.add_child(name_btn)
		hbox.add_child(type_lbl)
		hbox.add_child(size_lbl)
		
		file_grid.add_child(hbox)

func _open_viewer(node):
	var viewer = viewer_scene.instantiate()
	WindowManager.get_window_layer().add_child(viewer)
	viewer.setup(node, current_machine, current_path.path_join(node.name).simplify_path())
	WindowManager.bring_to_front(viewer)
