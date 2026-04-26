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
