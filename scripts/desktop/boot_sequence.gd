extends Control

signal boot_complete

@onready var output = $VBoxContainer/Output
@onready var cursor = $VBoxContainer/Cursor

const BOOT_LINES = [
	{"text": "GhostNet OS v2.3.1 — Kernel initialising...", "delay": 0.0},
	{"text": "Loading hardware drivers...", "delay": 0.3},
	{"text": "  [  OK  ] CPU: 4 cores @ 3.6GHz", "delay": 0.5},
	{"text": "  [  OK  ] Memory: 16GB DDR4", "delay": 0.6},
	{"text": "  [  OK  ] Storage: 512GB NVMe", "delay": 0.7},
	{"text": "  [  OK  ] Network interface: eth0", "delay": 0.9},
	{"text": "Mounting encrypted volumes...", "delay": 1.2},
	{"text": "  [  OK  ] /dev/sda1 mounted at /", "delay": 1.4},
	{"text": "  [  OK  ] /dev/sda2 mounted at /home", "delay": 1.5},
	{"text": "Starting system services...", "delay": 1.8},
	{"text": "  [  OK  ] firewall active", "delay": 2.0},
	{"text": "  [  OK  ] phantom-cloak daemon loaded", "delay": 2.2},
	{"text": "  [  OK  ] ghostnet-shell v2.3.1 ready", "delay": 2.4},
	{"text": "", "delay": 2.7},
	{"text": "Welcome back, Ghost.", "delay": 2.8},
	{"text": "", "delay": 3.0},
	{"text": "Launching desktop environment...", "delay": 3.1},
]

func _ready():
	modulate = Color(1, 1, 1, 1)
	output.text = ""
	_play_boot()

func _play_boot():
	for line in BOOT_LINES:
		await get_tree().create_timer(line["delay"] if line == BOOT_LINES[0] else 0.0).timeout
	# Actually sequence them properly
	output.text = ""
	var last_delay = 0.0
	for i in BOOT_LINES.size():
		var line = BOOT_LINES[i]
		var wait = line["delay"] - last_delay
		last_delay = line["delay"]
		if wait > 0:
			await get_tree().create_timer(wait).timeout
		output.text += line["text"] + "\n"
	# After last line, wait then fade out
	await get_tree().create_timer(0.6).timeout
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	await tween.finished
	boot_complete.emit()
	queue_free()