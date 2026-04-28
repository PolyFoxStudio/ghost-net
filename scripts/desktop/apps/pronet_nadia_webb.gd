extends ScrollContainer

func _ready() -> void:
	var btn = find_child("DianeMarchBtn", true, false)
	if btn:
		btn.pressed.connect(_on_diane_marsh_pressed)
	else:
		push_error("PronetNadiaWebb: DianeMarchBtn not found in scene tree")

func _on_diane_marsh_pressed() -> void:
	GlobalSignals.navigator_navigate.emit("pronet.io/in/diane-marsh")
