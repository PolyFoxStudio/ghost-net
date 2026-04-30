extends Control

signal completed

@onready var pl_window = $Windows/PhantomLinkWindow
@onready var term_window = $Windows/TerminalWindow
@onready var download_panel = $DownloadPanel
@onready var progress_bar = $DownloadPanel/VBoxContainer/ProgressBar
@onready var install_btn = $DownloadPanel/VBoxContainer/InstallBtn

func _ready() -> void:
	pl_window.grab_focus_internal()
	
	# Clear pre-existing history to simulate it being there from years ago
	var m1 = pl_window.PLMessage.new("cipher", "wherever you went.", "old")
	var m2 = pl_window.PLMessage.new("cipher", "i hope it's somewhere quiet.", "old")
	var m3 = pl_window.PLMessage.new("cipher", "take care of yourself.", "old")
	var m4 = pl_window.PLMessage.new("cipher", "— c", "old")
	
	pl_window.threads_data["cipher"]["messages"] = [m1, m2, m3, m4]
	pl_window._render_history("cipher")
	
	await get_tree().create_timer(3.0).timeout
	
	var m5 = pl_window.PLMessage.new("ghost", "I'm back.\nI need your help with something.\nThere's a missing woman. Her husband reached out.\nI said yes.", "intro")
	pl_window._append_message(m5, "cipher")
	
	await get_tree().create_timer(2.0).timeout
	
	# Start cipher response
	pl_window.trigger_beat("beat_01")

func _process(_delta: float) -> void:
	if not download_panel.visible:
		var msgs = pl_window.threads_data["cipher"]["messages"]
		if msgs.size() > 0 and msgs[-1].text == "anyway. installing now. give it a minute.":
			_start_download()

func _start_download() -> void:
	download_panel.show()
	install_btn.hide()
	
	var tween = create_tween()
	tween.tween_property(progress_bar, "value", 100.0, 3.0)
	await tween.finished
	
	install_btn.show()
	install_btn.pressed.connect(_install_now)
	
	await get_tree().create_timer(3.0).timeout
	if not install_btn.is_queued_for_deletion():
		_install_now()

func _install_now() -> void:
	install_btn.queue_free()
	var fade = create_tween()
	fade.tween_property(self, "modulate:a", 0.0, 0.5)
	await fade.finished
	completed.emit()
