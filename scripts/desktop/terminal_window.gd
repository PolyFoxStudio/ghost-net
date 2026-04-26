extends "res://scripts/desktop/ghost_window.gd"

@onready var terminal = $VBoxContainer/AppContainer/Terminal

func _ready():
	resized.connect(func(): $VBoxContainer.queue_sort())

func grab_focus_internal():
	var hidden_input = terminal.get_node_or_null("BGColor/HiddenInput")
	if hidden_input:
		hidden_input.grab_focus()
