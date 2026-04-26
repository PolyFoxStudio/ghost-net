extends "res://scripts/desktop/ghost_window.gd"

@onready var notes_text = $VBoxContainer/AppContainer/TabContainer/Notes/TextEdit
@onready var hosts_rtf = $VBoxContainer/AppContainer/TabContainer/Hosts/RichTextLabel
@onready var creds_rtf = $VBoxContainer/AppContainer/TabContainer/Credentials/RichTextLabel
@onready var dl_rtf = $VBoxContainer/AppContainer/TabContainer/Downloads/RichTextLabel

var _saved_notes: String = "// your notes...\n"
var _known_hosts: Dictionary = {}

func _ready():
	super._ready()
	
	notes_text.text = _saved_notes
	notes_text.text_changed.connect(func(): _saved_notes = notes_text.text)
	
	hosts_rtf.text = "[color=#4a4a4a]// no data captured yet[/color]"
	creds_rtf.text = "[color=#4a4a4a]// no data captured yet[/color]"
	dl_rtf.text = "[color=#4a4a4a]// no data captured yet[/color]"
	
	_update_hosts_display()
	
	GlobalSignals.machine_discovered.connect(_on_machine_discovered)
	GlobalSignals.machine_scanned.connect(_on_machine_scanned)
	GlobalSignals.machine_connected.connect(_on_machine_connected)
	GlobalSignals.credential_found.connect(_on_credential_found)
	GlobalSignals.file_downloaded.connect(_on_file_downloaded)

func _on_machine_discovered(machine):
	_update_host_entry(machine)
	
func _on_machine_scanned(machine):
	_update_host_entry(machine)

func _on_machine_connected(machine):
	_update_host_entry(machine)

func _update_host_entry(machine):
	var status = "discovered"
	if machine.is_player_connected:
		status = "connected"
	elif machine.is_scanned:
		status = "scanned"
		
	_known_hosts[machine.ip] = {
		"hostname": machine.hostname,
		"zone": machine.network_zone,
		"status": status
	}
	_update_hosts_display()

func _update_hosts_display():
	var time = Time.get_time_dict_from_system()
	var time_str = "%02d:%02d:%02d" % [time.hour, time.minute, time.second]
	var bbcode = "[color=#4a4a4a]// GHOSTNET INTEL — auto-captured\n// last updated: %s\n\nIP             HOSTNAME        ZONE         STATUS[/color]\n\n" % time_str
	if _known_hosts.is_empty():
		bbcode = "[color=#4a4a4a]// no data captured yet[/color]"
	else:
		for ip in _known_hosts:
			var h = _known_hosts[ip]
			bbcode += "[color=#00ff41]■[/color]  %-14s %-15s %-12s %s\n" % [ip, h.hostname, h.zone, h.status]
	hosts_rtf.text = bbcode

func _on_credential_found(username, password, ip):
	var current = creds_rtf.text
	if current.is_empty() or "no data captured" in current:
		var time = Time.get_time_dict_from_system()
		var time_str = "%02d:%02d:%02d" % [time.hour, time.minute, time.second]
		current = "[color=#4a4a4a]// GHOSTNET INTEL — auto-captured\n// last updated: %s\n\nUSERNAME        PASSWORD        HOST[/color]\n\n" % time_str
	else:
		var lines = current.split("\n")
		var time = Time.get_time_dict_from_system()
		var time_str = "%02d:%02d:%02d" % [time.hour, time.minute, time.second]
		lines[1] = "[color=#4a4a4a]// last updated: %s" % time_str
		current = "\n".join(lines)
		
	var entry = "[color=#00ff41]■[/color]  %-15s %-15s %s\n" % [username, password, ip]
	if not entry in current:
		creds_rtf.text = current + entry

func _on_file_downloaded(file_node, source_machine, source_path):
	var current = dl_rtf.text
	if current.is_empty() or "no data captured" in current:
		var time = Time.get_time_dict_from_system()
		var time_str = "%02d:%02d:%02d" % [time.hour, time.minute, time.second]
		current = "[color=#4a4a4a]// GHOSTNET INTEL — auto-captured\n// last updated: %s\n\nFILENAME        SOURCE          PATH[/color]\n\n" % time_str
	else:
		var lines = current.split("\n")
		var time = Time.get_time_dict_from_system()
		var time_str = "%02d:%02d:%02d" % [time.hour, time.minute, time.second]
		lines[1] = "[color=#4a4a4a]// last updated: %s" % time_str
		current = "\n".join(lines)
		
	var entry = "[color=#00ff41]■[/color]  %-15s %-15s %s\n" % [file_node.name, source_machine, source_path]
	if not entry in current:
		dl_rtf.text = current + entry

func grab_focus_internal():
	notes_text.grab_focus()
