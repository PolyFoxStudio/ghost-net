extends Control

signal completed

@onready var message_list = $PhoneBody/ScrollContainer/MessageList
@onready var scroll_container = $PhoneBody/ScrollContainer
@onready var typing_indicator = $PhoneBody/TypingIndicator
@onready var phone_body = $PhoneBody

func _ready() -> void:
	phone_body.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(phone_body, "modulate:a", 1.0, 1.0)
	await tween.finished
	
	await get_tree().create_timer(3.0).timeout
	await _run_sequence()

func _run_sequence() -> void:
	await _marcus("I got your number from Danny Reeves. I hope that's okay.", 23, 9, 2500)
	await _marcus("He said you might be able to help with something.", 23, 9, 1800)
	await _marcus("I don't really know how to explain this.", 23, 9, 4000)
	
	_show_typing()
	await get_tree().create_timer(2.0).timeout
	_hide_typing()
	
	await _marcus("My wife is missing.", 23, 10, 3000)
	
	await _marcus("Her name is Nadia. She's been gone for six days.", 23, 10, 3000)
	await _marcus("I filed a police report on day one but they're not doing anything.", 23, 10, 2500)
	await _marcus("They keep saying it's too early. That people leave sometimes.", 23, 10, 5000)
	
	# Flickering typing indicator
	_show_typing()
	await get_tree().create_timer(1.0).timeout
	_hide_typing()
	await get_tree().create_timer(0.5).timeout
	_show_typing()
	await get_tree().create_timer(1.0).timeout
	_hide_typing()
	await get_tree().create_timer(0.5).timeout
	_show_typing()
	await get_tree().create_timer(1.5).timeout
	_hide_typing()
	
	await _marcus("She didn't leave. She was scared.", 23, 11, 2000)
	await _marcus("She'd been scared for weeks before it happened and I didn't\npush her on it and now I can't stop thinking about that.", 23, 11, 3000)
	
	await _marcus("Danny said you're good at finding things. Finding people.", 23, 12, 2500)
	await _marcus("That you've done it before.", 23, 12, 6000)
	
	_show_typing()
	await get_tree().create_timer(3.0).timeout
	_hide_typing()
	
	await _marcus("I know we haven't spoken in a long time.\nI know that's on me as much as anything.", 23, 13, 1500)
	await _marcus("But I didn't know who else to call.\n\nI keep thinking Jess would have known what to do.\nShe always knew what to do.", 23, 13, 1000)
	
	await _marcus("I'm sorry. That wasn't fair.\nI just need help.\nWill you help me?", 23, 13, 5000)
	
	# Ghost's typing indicator
	typing_indicator.text = "You are typing..."
	_show_typing()
	await get_tree().create_timer(3.0).timeout
	_hide_typing()
	
	await _ghost("Send me everything you have.", 23, 14, 800)
	
	await _marcus("Thank you.", 23, 14, 2000)
	
	var fade_out = create_tween()
	fade_out.tween_property(phone_body, "modulate:a", 0.0, 1.5)
	await fade_out.finished
	completed.emit()

func _marcus(text: String, h: int, m: int, wait_ms: int) -> void:
	await _add_bubble(text, "%02d:%02d" % [h, m], false)
	await get_tree().create_timer(wait_ms / 1000.0).timeout

func _ghost(text: String, h: int, m: int, wait_ms: int) -> void:
	await _add_bubble(text, "%02d:%02d" % [h, m], true)
	await get_tree().create_timer(wait_ms / 1000.0).timeout

func _show_typing() -> void:
	typing_indicator.show()

func _hide_typing() -> void:
	typing_indicator.hide()

func _add_bubble(text: String, time: String, is_ghost: bool) -> void:
	var container = HBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var bubble = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	
	if is_ghost:
		style.bg_color = Color("#2a3a2a")
		container.add_child(spacer)
		container.add_child(bubble)
	else:
		style.bg_color = Color("#1a1a1a")
		container.add_child(bubble)
		container.add_child(spacer)
	
	bubble.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	bubble.add_child(vbox)
	
	var label = Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(250, 0)
	label.add_theme_color_override("font_color", Color("#e0e0e0"))
	label.add_theme_font_size_override("font_size", 13)
	vbox.add_child(label)
	
	var time_label = Label.new()
	time_label.text = time
	time_label.add_theme_color_override("font_color", Color("#888888"))
	time_label.add_theme_font_size_override("font_size", 10)
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	vbox.add_child(time_label)
	
	container.modulate.a = 0.0
	message_list.add_child(container)
	
	var tween = create_tween()
	tween.tween_property(container, "modulate:a", 1.0, 0.2)
	
	await get_tree().process_frame
	await get_tree().process_frame
	scroll_container.scroll_vertical = int(scroll_container.get_v_scroll_bar().max_value)
