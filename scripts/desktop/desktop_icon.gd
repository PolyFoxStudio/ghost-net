extends VBoxContainer

signal double_clicked
signal single_clicked

@export var icon_name: String = "App"
@export var icon_symbol: String = "⬛"

@onready var icon_visual = $IconVisual
@onready var label = $IconLabel
@onready var highlight = $Highlight

var is_selected: bool = false

func _ready():
	label.text = icon_name
	icon_visual.text = icon_symbol
	gui_input.connect(_on_gui_input)

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if event.double_click:
			double_clicked.emit()
			set_selected(false)
		else:
			single_clicked.emit()
			set_selected(true)

func set_selected(selected: bool):
	is_selected = selected
	highlight.visible = selected

func set_running(running: bool):
	var dot = get_node_or_null("RunningDot")
	if running and not dot:
		var lbl = Label.new()
		lbl.name = "RunningDot"
		lbl.text = "●"
		lbl.add_theme_font_size_override("font_size", 8)
		lbl.add_theme_color_override("font_color", Color("#00ff41"))
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		add_child(lbl)
	elif not running and dot:
		dot.queue_free()
