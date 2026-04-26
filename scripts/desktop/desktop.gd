extends Control

var term_scene = preload("res://scenes/desktop/apps/TerminalWindow.tscn")
var nav_scene = preload("res://scenes/desktop/apps/NavigatorWindow.tscn")
var notes_scene = preload("res://scenes/desktop/apps/NotesWindow.tscn")
var files_scene = preload("res://scenes/desktop/apps/FilesWindow.tscn")
var desktop_icon_scn = preload("res://scenes/desktop/DesktopIcon.tscn")

func _ready():
	WindowManager.set_window_layer($WindowLayer)
	
	resized.connect(func(): WindowManager.reposition_windows())
	
	if LocalMachineSetup.has_method("setup") and not NetworkManager.get_machine("127.0.0.1"):
		LocalMachineSetup.setup()
	if TestMachineSetup.has_method("setup") and not NetworkManager.get_machine("10.0.0.1"):
		TestMachineSetup.setup()
	
	_setup_desktop_icons()
	
	WindowManager.open_window(term_scene, "TERMINAL")

func _setup_desktop_icons():
	var icons_container = $DesktopIcons
	if not icons_container:
		return
	
	var apps = [
		{"name": "Terminal", "scene": term_scene, "app_id": "TERMINAL", "symbol": ">_"},
		{"name": "Navigator", "scene": nav_scene, "app_id": "NAVIGATOR", "symbol": "◉"},
		{"name": "Notes", "scene": notes_scene, "app_id": "NOTES", "symbol": "≡"},
		{"name": "Files", "scene": files_scene, "app_id": "FILES", "symbol": "⬛"}
	]
	
	var i = 0
	for app in apps:
		var icon = desktop_icon_scn.instantiate()
		icon.icon_name = app["name"]
		icon.icon_symbol = app["symbol"]
		
		# Position the icons properly!
		icon.position = Vector2(20, 50 + (i * 80))
		i += 1
		
		icons_container.add_child(icon)
		
		icon.double_clicked.connect(func():
			for child in icons_container.get_children():
				if child != icon:
					child.set_selected(false)
			WindowManager.open_window(app["scene"], app["app_id"])
		)
		
		icon.single_clicked.connect(func():
			for child in icons_container.get_children():
				if child != icon:
					child.set_selected(false)
		)
	
