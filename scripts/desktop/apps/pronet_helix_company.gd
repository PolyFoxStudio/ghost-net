extends ScrollContainer

func _ready() -> void:
	var diane_btn = find_child("DianeMarchBtn", true, false)
	if diane_btn:
		diane_btn.pressed.connect(_on_diane_marsh_pressed)
	var nadia_btn = find_child("NadiaWebbBtn", true, false)
	if nadia_btn:
		nadia_btn.pressed.connect(_on_nadia_webb_pressed)

func _on_diane_marsh_pressed() -> void:
	GlobalSignals.navigator_navigate.emit("pronet.io/in/diane-marsh")

func _on_nadia_webb_pressed() -> void:
	GlobalSignals.navigator_navigate.emit("pronet.io/in/nadia-webb")
