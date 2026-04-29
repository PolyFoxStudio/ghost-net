extends "res://scripts/desktop/ghost_window.gd"

@onready var notes_text: TextEdit = $VBoxContainer/AppContainer/TabContainer/Notes/TextEdit
@onready var hosts_label: RichTextLabel = $VBoxContainer/AppContainer/TabContainer/Hosts/VBoxContainer/RichTextLabel
@onready var creds_label: RichTextLabel = $VBoxContainer/AppContainer/TabContainer/Credentials/VBoxContainer/RichTextLabel
@onready var down_label: RichTextLabel = $VBoxContainer/AppContainer/TabContainer/Downloads/VBoxContainer/RichTextLabel

var notes_content: String = "// your notes...\\n"
var discovered_hosts: Dictionary = {}

func _ready() -> void:
	app_name = "NOTES"
	super._ready()
	notes_text.text = notes_content
	notes_text.text_changed.connect(_on_notes_changed)
	GlobalSignals.machine_discovered.connect(_on_machine_discovered)
	GlobalSignals.machine_scanned.connect(_on_machine_scanned)
	GlobalSignals.machine_connected.connect(_on_machine_connected)
	GlobalSignals.credential_found.connect(_on_credential_found)
	GlobalSignals.file_downloaded.connect(_on_file_downloaded)
	_refresh_hosts()

func _on_notes_changed() -> void:
	notes_content = notes_text.text

func _on_machine_discovered(machine) -> void:
	discovered_hosts[machine.ip] = {"host": machine.hostname, "zone": machine.network_zone, "status": "discovered"}
	_refresh_hosts()

func _on_machine_scanned(machine) -> void:
	if discovered_hosts.has(machine.ip) and discovered_hosts[machine.ip]["status"] != "connected":
		discovered_hosts[machine.ip]["status"] = "scanned"
		_refresh_hosts()

func _on_machine_connected(machine) -> void:
	if discovered_hosts.has(machine.ip):
		discovered_hosts[machine.ip]["status"] = "connected"
		_refresh_hosts()

func _refresh_hosts() -> void:
	var text = ""
	for ip in discovered_hosts.keys():
		var h = discovered_hosts[ip]
		text += "[color=#00ff41]■[/color]  %-15s %-15s %-12s %s\\n" % [ip, h["host"], h["zone"], h["status"]]
	hosts_label.text = text

func _on_credential_found(username: String, password: String, ip: String) -> void:
	creds_label.text += "[color=#00ff41]■[/color]  %-15s %-15s %s\\n" % [username, password, ip]

func _on_file_downloaded(file_node, source_machine: String, source_path: String) -> void:
	down_label.text += "[color=#00ff41]■[/color]  %-15s %-15s %s\\n" % [file_node.name, source_machine, source_path]
