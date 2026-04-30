extends Control

signal completed

@onready var content = $Content
@onready var line_edit = $Content/LineEdit

func _ready() -> void:
	content.modulate.a = 0.0
	
	var tween = create_tween()
	tween.tween_property(content, "modulate:a", 1.0, 0.6)
	await tween.finished
	
	line_edit.grab_focus()
	line_edit.text_submitted.connect(_on_text_submitted)

func _on_text_submitted(new_text: String) -> void:
	if new_text.strip_edges() == "": return
	
	GameState.player_name = new_text.strip_edges()
	line_edit.editable = false
	
	var tween = create_tween()
	tween.tween_property(content, "modulate:a", 0.0, 0.4)
	await tween.finished
	
	await get_tree().create_timer(0.8).timeout
	completed.emit()
