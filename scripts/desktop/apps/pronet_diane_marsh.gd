extends ScrollContainer

func _ready() -> void:
	var helix_btn = find_child("HelixCompanyBtn", true, false)
	if helix_btn:
		helix_btn.pressed.connect(_on_helix_pressed)

func _on_helix_pressed() -> void:
	GlobalSignals.navigator_navigate.emit("pronet.io/company/helix-solutions")