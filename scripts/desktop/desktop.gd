extends Control
	
func _ready():
	WindowManager.set_window_layer($WindowLayer)
	
	if LocalMachineSetup.has_method("setup") and not NetworkManager.get_machine("127.0.0.1"):
		LocalMachineSetup.setup()
	if TestMachineSetup.has_method("setup") and not NetworkManager.get_machine("10.0.0.1"):
		TestMachineSetup.setup()
		
	var term_scene = load("res://scenes/desktop/apps/TerminalWindow.tscn")
	WindowManager.open_window(term_scene, "TERMINAL")

func _on_hidden_focus_trap_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		var window_layer = $WindowLayer
		if window_layer.get_child_count() > 0:
			var top_window = window_layer.get_child(window_layer.get_child_count() - 1)
			if top_window.has_method("grab_focus_internal"):
				top_window.grab_focus_internal()
	
