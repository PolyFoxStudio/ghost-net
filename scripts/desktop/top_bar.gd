extends ColorRect

@onready var clock_label = $HBoxContainer/ClockLabel
@onready var alert_dot = $HBoxContainer/AlertHBox/AlertDot
@onready var alert_label = $HBoxContainer/AlertHBox/AlertLabel

var _pulse_time: float = 0.0

func _ready() -> void:
	var timer := Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.timeout.connect(_update_clock)
	add_child(timer)
	_update_clock()

func _update_clock() -> void:
	var time := Time.get_time_dict_from_system()
	clock_label.text = "%02d:%02d" % [time.hour, time.minute]

func _process(delta: float) -> void:
	var level: String = GameState.alert_level
	
	if level == "STEALTH":
		alert_label.hide()
		alert_dot.color = Color("#00ff41")
		alert_dot.color.a = 0.4
	elif level == "CAUTION":
		alert_label.show()
		alert_label.text = "CAUTION"
		alert_label.add_theme_color_override("font_color", Color("#ffb300"))
		alert_dot.color = Color("#ffb300")
	elif level == "WARNING":
		alert_label.show()
		alert_label.text = "WARNING"
		alert_label.add_theme_color_override("font_color", Color("#ffb300"))
		
		_pulse_time += delta * 5.0
		var a: float = (sin(_pulse_time) + 1.0) / 2.0
		alert_dot.color = Color("#ffb300")
		alert_dot.color.a = 0.4 + a * 0.6
	elif level == "CRITICAL":
		alert_label.show()
		alert_label.text = "CRITICAL"
		alert_label.add_theme_color_override("font_color", Color("#ff3333"))
		
		_pulse_time += delta * 15.0
		var a: float = (sin(_pulse_time) + 1.0) / 2.0
		alert_dot.color = Color("#ff3333")
		alert_dot.color.a = 0.4 + a * 0.6
