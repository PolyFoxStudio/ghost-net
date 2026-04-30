extends Control

var term_scene  = preload("res://scenes/desktop/apps/TerminalWindow.tscn")
var nav_scene   = preload("res://scenes/desktop/apps/NavigatorWindow.tscn")
var notes_scene = preload("res://scenes/desktop/apps/NotesWindow.tscn")
var files_scene = preload("res://scenes/desktop/apps/FilesWindow.tscn")
var senet_scene = preload("res://scenes/desktop/apps/SenetWindow.tscn")

var desktop_icon_scn = preload("res://scenes/desktop/DesktopIcon.tscn")

var pl_scene = preload("res://scenes/desktop/apps/PhantomLinkWindow.tscn")

# Track the SENET icon node so we can show it after unlock
var _senet_icon: Node = null

func _ready():
	$Taskbar.hide()
	$DesktopIcons.hide()
	$WindowLayer.hide()

	var boot_scene = preload("res://scenes/desktop/BootSequence.tscn")
	var boot = boot_scene.instantiate()
	add_child(boot)
	boot.boot_complete.connect(func():
		$Taskbar.show()
		$DesktopIcons.show()
		$WindowLayer.show()
		_setup_desktop()
		if GameState.get_flag("intro_just_finished", false):
			GameState.set_flag("intro_just_finished", false)
			WindowManager.open_window(pl_scene, "PHANTOMLINK")
			GlobalSignals.phantomlink_beat_trigger.emit("beat_02")
		else:
			# Not just finished intro, but we should restore state if any
			# Since save/load isn't fully implemented for PhantomLink yet,
			# just open Terminal.
			pass
	)

func _setup_desktop():
	WindowManager.set_window_layer($WindowLayer)

	resized.connect(func(): WindowManager.reposition_windows())

	if LocalMachineSetup.has_method("setup") and not NetworkManager.get_machine("127.0.0.1"):
		LocalMachineSetup.setup()
	if TestMachineSetup.has_method("setup") and not NetworkManager.get_machine("10.0.0.1"):
		TestMachineSetup.setup()

	_setup_desktop_icons()

	# Listen for SENET unlock signal
	GlobalSignals.senet_unlocked.connect(_on_senet_unlocked)
	GlobalSignals.senet_unlocked.connect(func(): GlobalSignals.phantomlink_beat_trigger.emit("beat_05"))

	if not GameState.get_flag("intro_just_finished", false):
		WindowManager.open_window(term_scene, "TERMINAL")

func _process(_delta: float) -> void:
	if has_node("Watermark"):
		$Watermark.visible = not GameState.wallpaper_default

func _setup_desktop_icons():
	var icons_container = $DesktopIcons
	if not icons_container:
		return

	var apps = [
		{"name": "Terminal",  "scene": term_scene,  "app_id": "TERMINAL",  "symbol": ">_"},
		{"name": "Navigator", "scene": nav_scene,   "app_id": "NAVIGATOR", "symbol": "◉"},
		{"name": "Notes",     "scene": notes_scene, "app_id": "NOTES",     "symbol": "≡"},
		{"name": "Files",     "scene": files_scene, "app_id": "FILES",     "symbol": "⬛"},
		{"name": "PhantomLink", "scene": pl_scene,  "app_id": "PHANTOMLINK", "symbol": "💬"},
	]

	var i = 0
	for app in apps:
		_create_icon(icons_container, app, i)
		i += 1

	# SENET — hidden at boot, revealed on senet_unlocked signal
	var senet_app = {
		"name":   "SENET",
		"scene":  senet_scene,
		"app_id": "SENET",
		"symbol": "✉"
	}
	_senet_icon = _create_icon(icons_container, senet_app, i)
	_senet_icon.hide()

func _create_icon(icons_container: Node, app: Dictionary, index: int) -> Node:
	var icon = desktop_icon_scn.instantiate()
	icon.icon_name   = app["name"]
	icon.icon_symbol = app["symbol"]
	icon.position    = Vector2(20, 50 + (index * 80))
	icons_container.add_child(icon)

	var captured_app_id = app["app_id"]
	var captured_icon   = icon
	GlobalSignals.window_closed.connect(func(window_name):
		if window_name == captured_app_id:
			captured_icon.set_running(false)
	)

	icon.double_clicked.connect(func():
		for child in icons_container.get_children():
			if child != icon:
				child.set_selected(false)
		WindowManager.open_window(app["scene"], app["app_id"])
		captured_icon.set_running(true)
	)

	icon.single_clicked.connect(func():
		for child in icons_container.get_children():
			if child != icon:
				child.set_selected(false)
	)

	return icon

func _on_senet_unlocked() -> void:
	if _senet_icon and not _senet_icon.visible:
		_senet_icon.show()
	WindowManager.open_window(senet_scene, "SENET")
