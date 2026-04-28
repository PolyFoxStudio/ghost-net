extends ScrollContainer

func _ready() -> void:
	var btn = find_child("DianeMarchBtn", true, false)
	if btn:
		btn.pressed.connect(_on_diane_marsh_pressed)
	else:
		push_error("PronetNadiaWebb: DianeMarchBtn not found in scene tree")
	
	var helix_btn = find_child("HelixCompanyBtn", true, false)
	if helix_btn:
		helix_btn.pressed.connect(_on_helix_pressed)

func _on_helix_pressed() -> void:
	GlobalSignals.navigator_navigate.emit("pronet.io/company/helix-solutions")

func _on_diane_marsh_pressed() -> void:
	GlobalSignals.navigator_navigate.emit("pronet.io/in/diane-marsh")
