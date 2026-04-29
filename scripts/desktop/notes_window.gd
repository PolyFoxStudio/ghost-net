extends "res://scripts/desktop/ghost_window.gd"

@onready var tab_container: TabContainer = $VBoxContainer/AppContainer/MainVBox/TabContainer
@onready var new_tab_btn: Button = $VBoxContainer/AppContainer/MainVBox/Toolbar/HBoxContainer/NewTabButton
@onready var rename_tab_btn: Button = $VBoxContainer/AppContainer/MainVBox/Toolbar/HBoxContainer/RenameTabButton
@onready var delete_tab_btn: Button = $VBoxContainer/AppContainer/MainVBox/Toolbar/HBoxContainer/DeleteTabButton

@onready var rename_dialog: ConfirmationDialog = $RenameDialog
@onready var rename_line_edit: LineEdit = $RenameDialog/RenameLineEdit

var save_timer: Timer
var notes_file_path: String = "user://notes.json"

func _ready() -> void:
	app_name = "NOTES"
	super._ready()
	
	new_tab_btn.pressed.connect(_on_new_tab_pressed)
	rename_tab_btn.pressed.connect(_on_rename_tab_pressed)
	delete_tab_btn.pressed.connect(_on_delete_tab_pressed)
	
	rename_dialog.confirmed.connect(_on_rename_confirmed)
	
	# Auto-save timer
	save_timer = Timer.new()
	save_timer.wait_time = 2.0
	save_timer.autostart = true
	save_timer.timeout.connect(_save_notes)
	add_child(save_timer)
	
	# Initialize first
	for child in tab_container.get_children():
		tab_container.remove_child(child)
		child.queue_free()
	
	_load_notes()
	
	if tab_container.get_child_count() == 0:
		_add_tab("Notes", "")

func _add_tab(tab_name: String = "", content: String = "") -> void:
	if tab_name == "":
		var count = tab_container.get_child_count() + 1
		tab_name = "Note " + str(count)
		
	var tab_control = Control.new()
	tab_control.name = tab_name
	
	var text_edit = TextEdit.new()
	text_edit.text = content
	text_edit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	text_edit.add_theme_color_override("background_color", Color(0.0549, 0.0549, 0.0706, 1))
	text_edit.add_theme_color_override("font_color", Color(0.6667, 0.6667, 0.8, 1))
	text_edit.add_theme_color_override("caret_color", Color(0, 1, 0.2549, 1))
	text_edit.add_theme_font_size_override("font_size", 13)
	text_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	
	text_edit.text_changed.connect(func(): _save_notes())
	
	tab_control.add_child(text_edit)
	tab_container.add_child(tab_control)
	tab_container.current_tab = tab_container.get_child_count() - 1
	
	_save_notes()

func _on_new_tab_pressed() -> void:
	_add_tab()

func _on_rename_tab_pressed() -> void:
	if tab_container.get_child_count() == 0:
		return
	var current_idx = tab_container.current_tab
	var current_tab = tab_container.get_child(current_idx)
	rename_line_edit.text = current_tab.name
	rename_dialog.popup_centered()
	rename_line_edit.grab_focus()
	rename_line_edit.select_all()

func _on_rename_confirmed() -> void:
	var new_name = rename_line_edit.text.strip_edges()
	if new_name != "" and tab_container.get_child_count() > 0:
		var current_idx = tab_container.current_tab
		var current_tab = tab_container.get_child(current_idx)
		current_tab.name = new_name
		_save_notes()

func _on_delete_tab_pressed() -> void:
	if tab_container.get_child_count() > 1:
		var current_idx = tab_container.current_tab
		var current_tab = tab_container.get_child(current_idx)
		tab_container.remove_child(current_tab)
		current_tab.queue_free()
		_save_notes()

func _save_notes() -> void:
	var data = []
	for child in tab_container.get_children():
		if child.is_queued_for_deletion():
			continue
		if child.get_child_count() > 0:
			var text_edit = child.get_child(0) as TextEdit
			if text_edit:
				data.append({
					"name": child.name,
					"content": text_edit.text
				})
			
	var file = FileAccess.open(notes_file_path, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data)
		file.store_string(json_string)
		file.close()

func _load_notes() -> void:
	if not FileAccess.file_exists(notes_file_path):
		return
		
	var file = FileAccess.open(notes_file_path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(json_string)
		if error == OK:
			var data = json.data
			if typeof(data) == TYPE_ARRAY:
				for item in data:
					if typeof(item) == TYPE_DICTIONARY and item.has("name") and item.has("content"):
						_add_tab(item["name"], item["content"])

func grab_focus_internal():
	if tab_container.get_child_count() > 0:
		var current_idx = tab_container.current_tab
		var current_tab = tab_container.get_child(current_idx)
		if current_tab and current_tab.get_child_count() > 0:
			current_tab.get_child(0).grab_focus()
