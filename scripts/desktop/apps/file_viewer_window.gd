extends "res://scripts/desktop/ghost_window.gd"

@onready var content_rtf = $VBoxContainer/AppContainer/VBoxContainer/ScrollContainer/Content
@onready var dl_btn = $VBoxContainer/AppContainer/VBoxContainer/DownloadBtn

var file_node: FileNode
var machine: MachineResource
var full_path: String

func _ready():
	super._ready()
	# @onready vars are now valid — safe to populate
	title_label.text = "VIEWER — " + file_node.name
	content_rtf.bbcode_enabled = false
	content_rtf.text = file_node.content
	if machine.ip == "127.0.0.1":
		dl_btn.disabled = true
		dl_btn.text = "ALREADY LOCAL"
	else:
		dl_btn.disabled = false
		dl_btn.text = "DOWNLOAD"
	dl_btn.pressed.connect(_on_download)

func _on_download():
	if machine.ip != "127.0.0.1":
		dl_btn.disabled = true
		dl_btn.text = "DOWNLOADED"
