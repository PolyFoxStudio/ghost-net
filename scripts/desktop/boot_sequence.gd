extends Control

signal boot_complete

@onready var output = $VBoxContainer/Output
@onready var cursor = $VBoxContainer/Cursor
@onready var loading_bar = $VBoxContainer/LoadingBar

const BOOT_LINES = [
	{"text": "   ________.__                   __   _______          __   ", "delay": 0.0},
	{"text": "  /  _____/|  |__   ____  _______/  |_ \\      \\   _____/  |_ ", "delay": 0.0},
	{"text": " /   \\  ___|  |  \\ /  _ \\/  ___/\\   __\\/   |   \\_/ __ \\   __\\", "delay": 0.0},
	{"text": " \\    \\_\\  \\   Y  (  <_> )___ \\  |  | /    |    \\  ___/|  |  ", "delay": 0.0},
	{"text": "  \\______  /___|  /\\____/____  > |__| \\____|__  /\\___  >__|  ", "delay": 0.0},
	{"text": "         \\/     \\/           \\/               \\/     \\/      ", "delay": 0.0},
	{"text": "                   [ v2.3.1 — built by Cipher ]              ", "delay": 0.0},
	{"text": "", "delay": 0.0},
	{"text": "──────────────────────────────────────────────────────────────", "delay": 0.3},
	{"text": "", "delay": 0.4},
	{"text": "GhostNet OS v2.3.1 — Kernel initialising...", "delay": 0.5},
	{"text": "Loading hardware drivers...", "delay": 0.8},
	{"text": "  [  OK  ] CPU: 4 cores @ 3.6GHz", "delay": 1.0},
	{"text": "  [  OK  ] Memory: 16GB DDR4", "delay": 1.1},
	{"text": "  [  OK  ] Storage: 512GB NVMe", "delay": 1.2},
	{"text": "  [  OK  ] Network interface: eth0", "delay": 1.4},
	{"text": "Mounting encrypted volumes...", "delay": 1.7},
	{"text": "  [  OK  ] /dev/sda1 mounted at /", "delay": 1.9},
	{"text": "  [  OK  ] /dev/sda2 mounted at /home", "delay": 2.0},
	{"text": "  [  OK  ] Encrypted partition /dev/ghost verified", "delay": 2.1},
	{"text": "Starting system services...", "delay": 2.4},
	{"text": "  [  OK  ] firewall active", "delay": 2.6},
	{"text": "  [  OK  ] VPN tunnel ghostwire0 established", "delay": 2.8},
	{"text": "  [ WARN ] Route table anomaly detected — suppressed", "delay": 3.0},
	{"text": "  [  OK  ] phantom-cloak daemon loaded", "delay": 3.2},
	{"text": "  [  OK  ] Ziva AI assistant online", "delay": 3.4},
	{"text": "  [  OK  ] ghostnet-shell v2.3.1 ready", "delay": 3.6},
	{"text": "", "delay": 3.9},
	{"text": "Welcome back, Ghost.", "delay": 4.1},
	{"text": "", "delay": 4.3},
	{"text": "Launching desktop environment...", "delay": 4.5},
]

func _ready():
	modulate = Color(1, 1, 1, 1)
	output.clear()
	_play_boot()

func _play_boot():
	# Actually sequence them properly
	output.clear()
	var last_delay = 0.0
	for i in BOOT_LINES.size():
		var line = BOOT_LINES[i]
		var wait = line["delay"] - last_delay
		last_delay = line["delay"]
		if wait > 0:
			await get_tree().create_timer(wait).timeout
		var display = line["text"]
		if "  OK  " in display:
			display = display.replace("[  OK  ]", "[color=#00ff41][  OK  ][/color]")
		elif "WARN" in display:
			display = display.replace("[ WARN ]", "[color=#ffcc00][ WARN ][/color]")
		elif display.begins_with("Welcome back"):
			display = "[color=#ffffff][b]" + display + "[/b][/color]"
		output.append_text(display + "\n")
		
	# Pause so player can read
	await get_tree().create_timer(0.8).timeout
	
	# Fill loading bar in its own label — no screen clearing
	var bar_width = 30
	for i in bar_width + 1:
		var filled = "█".repeat(i)
		var empty = " ".repeat(bar_width - i)
		var pct = int((float(i) / bar_width) * 100)
		loading_bar.text = "[" + filled + empty + "]  %d%%" % pct
		await get_tree().create_timer(0.04).timeout
	
	# Hold so player can read
	await get_tree().create_timer(1.5).timeout
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	await tween.finished
	boot_complete.emit()
	queue_free()
