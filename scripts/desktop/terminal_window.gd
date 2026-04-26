extends "res://scripts/desktop/ghost_window.gd"

@onready var terminal = $VBoxContainer/AppContainer/Terminal

func _ready():
	super._ready()
	resized.connect(func(): $VBoxContainer.queue_sort())
	# grab focus after everything is ready
	call_deferred("_grab_terminal_focus")

func _grab_terminal_focus():
	var hidden_input = terminal.get_node_or_null("BGColor/HiddenInput")
	if hidden_input:
		hidden_input.grab_focus()

func grab_focus_internal():
	var hidden_input = terminal.get_node_or_null("BGColor/HiddenInput")
	if hidden_input:
		hidden_input.grab_focus()
