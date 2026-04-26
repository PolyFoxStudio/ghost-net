extends "res://scripts/desktop/ghost_window.gd"

@onready var content_rtf = $VBoxContainer/AppContainer/VBoxContainer/Content
@onready var dl_btn = $VBoxContainer/AppContainer/VBoxContainer/DownloadBtn

var file_node
var machine
var full_path: String

func setup(p_file_node, p_machine, p_full_path):
	file_node = p_file_node
	machine = p_machine
	full_path = p_full_path
	
	title_label.text = "VIEWER — " + file_node.name
	content_rtf.text = file_node.content
	
	if machine.ip == "127.0.0.1":
		dl_btn.disabled = true
		dl_btn.text = "ALREADY LOCAL"
	else:
		dl_btn.disabled = false
		dl_btn.text = "DOWNLOAD"

func _ready():
	super._ready()
	dl_btn.pressed.connect(_on_download)

func _on_download():
	if machine.ip != "127.0.0.1":
		GlobalSignals.file_downloaded.emit(file_node, machine.hostname, full_path)
		dl_btn.disabled = true
		dl_btn.text = "DOWNLOADED"
