extends Control

signal close_requested

@onready var to_field: LineEdit = $VBoxContainer/MarginContainer/ContentVBox/ToField
@onready var from_field: LineEdit = $VBoxContainer/MarginContainer/ContentVBox/FromField
@onready var subject_field: LineEdit = $VBoxContainer/MarginContainer/ContentVBox/SubjectField
@onready var body_field: TextEdit = $VBoxContainer/MarginContainer/ContentVBox/BodyField
@onready var context_field: LineEdit = $VBoxContainer/MarginContainer/ContentVBox/ContextField
@onready var send_button: Button = $VBoxContainer/MarginContainer/ContentVBox/SendButton
@onready var engagement_log: RichTextLabel = $VBoxContainer/MarginContainer/ContentVBox/EngagementLog
@onready var close_button: Button = $VBoxContainer/TitleBar/HBoxContainer/CloseButton

func _ready() -> void:
	close_button.pressed.connect(func(): close_requested.emit())
	send_button.pressed.connect(_evaluate_send)

func _evaluate_send() -> void:
	var to_text: String = to_field.text.strip_edges()
	var from_text: String = from_field.text.strip_edges()
	var subject_text: String = subject_field.text.strip_edges()
	var body_text: String = body_field.text.strip_edges()
	
	if to_text.is_empty() or from_text.is_empty() or subject_text.is_empty() or body_text.is_empty():
		engagement_log.append_text("[ERROR] All fields required.\n")
	else:
		engagement_log.append_text("[SENT] Message dispatched.\n")
		
func log_response(sender: String, message: String) -> void:
	engagement_log.append_text("[%s] %s\n" % [sender, message])
