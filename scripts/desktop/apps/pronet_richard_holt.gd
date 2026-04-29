extends ScrollContainer

@onready var rich_text_label: RichTextLabel = $MarginContainer/RichTextLabel

func _ready() -> void:
	rich_text_label.meta_clicked.connect(_on_meta_clicked)

func _on_meta_clicked(meta) -> void:
	var meta_str = str(meta)
	if meta_str == "msg_ghostwire_check":
		return
	GlobalSignals.navigator_navigate.emit(meta_str)
