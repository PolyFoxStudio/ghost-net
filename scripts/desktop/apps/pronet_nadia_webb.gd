extends ScrollContainer

func _ready() -> void:
	# Connect the Diane Marsh button
	$VBoxContainer/Endorsements/MarginContainer/VBoxContainer/DianeMarchBtn.pressed.connect(_on_diane_marsh_pressed)

func _on_diane_marsh_pressed() -> void:
	GlobalSignals.navigator_navigate.emit("pronet.io/in/diane-marsh")
