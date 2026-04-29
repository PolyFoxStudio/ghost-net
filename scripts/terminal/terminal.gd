class_name Terminal
extends Control

@onready var output_label: RichTextLabel = $BGColor/OutputLabel
@onready var input_field: LineEdit = $BGColor/HiddenInput
@onready var trace_bar: HBoxContainer = $BGColor/TraceBar
@onready var trace_progress: ProgressBar = $BGColor/TraceBar/TraceProgress
@onready var cursor_timer: Timer = $CursorTimer

var command_registry: CommandRegistry
var navigator: FilesystemNavigator

var command_history: Array[String] = []
var history_index: int = -1

var input_mode: String = "normal"
signal input_provided(text: String)

var in_ftp_mode: bool = false

var static_history: String = ""
var current_input: String = ""
var current_prompt: String = ""
var cursor_visible: bool = true

func _ready() -> void:
	command_registry = CommandRegistry.new()
	navigator = FilesystemNavigator.new()
	
	navigator.set_machine(NetworkManager.get_local_machine())
	
	input_field.text_changed.connect(_on_input_text_changed)
	input_field.gui_input.connect(_on_input_gui_input)
	cursor_timer.timeout.connect(_on_cursor_timer_timeout)
	
	gui_input.connect(_on_terminal_gui_input)
	
	GlobalSignals.trace_updated.connect(_on_trace_updated)
	GlobalSignals.trace_completed.connect(_on_trace_completed)
	GlobalSignals.machine_connected.connect(_on_machine_changed)
	GlobalSignals.machine_disconnected.connect(_on_machine_changed)
	
	GlobalSignals.tier1_triggered.connect(_on_tier1_triggered)
	GlobalSignals.tier2_triggered.connect(_on_tier2_triggered)
	GlobalSignals.tier3_triggered.connect(_on_tier3_triggered)
	GlobalSignals.lockout_expired.connect(_on_lockout_expired)
	GlobalSignals.cloak_expired.connect(_on_cloak_expired)
	
	trace_bar.hide()
	_update_prompt()
	input_field.grab_focus()

func _scroll_to_bottom() -> void:
	await get_tree().process_frame
	output_label.scroll_to_line(output_label.get_line_count() - 1)

func print_output(text: String, is_error: bool = false) -> void:
	if text == "": return
	if is_error:
		if static_history == "":
			static_history = "[color=#ff3333]" + text + "[/color]"
		else:
			static_history += "\n[color=#ff3333]" + text + "[/color]"
	else:
		if static_history == "":
			static_history = text
		else:
			static_history += "\n" + text
	_redraw_terminal()
	_scroll_to_bottom()

func _update_prompt() -> void:
	if input_mode == "password" or input_mode == "input":
		return
		
	var m = NetworkManager.get_current_machine()
	if not m: m = NetworkManager.get_local_machine()
	
	var host = "local"
	if m and m.network_zone != "local":
		host = m.hostname
		
	if in_ftp_mode:
		current_prompt = "ftp>"
	else:
		var path = navigator.get_current_path()
		if path == "/": path = "~"
		current_prompt = "ghost@%s:%s$" % [host, path]
		
	_redraw_terminal()

func get_colored_prompt() -> String:
	if input_mode == "password" or input_mode == "input":
		return current_prompt
	elif in_ftp_mode:
		return current_prompt + " "
	else:
		return "[color=#00ff41]" + current_prompt + "[/color] "

func _redraw_terminal() -> void:
	var cursor_char = "█" if cursor_visible else ""
	var prompt_color = get_colored_prompt()
	
	var input_display = current_input
	if input_mode == "password":
		input_display = ""
		for i in range(current_input.length()):
			input_display += "*"
			
	var active_line = prompt_color + input_display + "[color=#00ff41]" + cursor_char + "[/color]"
	
	if static_history == "":
		output_label.text = active_line
	else:
		output_label.text = static_history + "\n" + active_line

func freeze_current_line() -> void:
	var input_display = current_input
	if input_mode == "password":
		input_display = ""
		for i in range(current_input.length()):
			input_display += "*"
			
	var prompt_color = get_colored_prompt()
		
	var frozen_line = prompt_color + input_display
	if static_history == "":
		static_history = frozen_line
	else:
		static_history += "\n" + frozen_line

func _on_input_text_changed(new_text: String) -> void:
	current_input = new_text
	cursor_visible = true
	cursor_timer.start()
	_redraw_terminal()

func _on_cursor_timer_timeout() -> void:
	cursor_visible = not cursor_visible
	_redraw_terminal()

func _on_terminal_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		input_field.grab_focus()

func _on_input_gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			var text = input_field.text
			input_field.text = ""
			current_input = ""
			_process_enter(text)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_UP:
			if history_index < command_history.size() - 1:
				history_index += 1
				input_field.text = command_history[history_index]
				current_input = input_field.text
				input_field.caret_column = input_field.text.length()
				_redraw_terminal()
				get_viewport().set_input_as_handled()
		elif event.keycode == KEY_DOWN:
			if history_index > 0:
				history_index -= 1
				input_field.text = command_history[history_index]
			else:
				history_index = -1
				input_field.text = ""
			current_input = input_field.text
			input_field.caret_column = input_field.text.length()
			_redraw_terminal()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_TAB:
			# basic tab completion stub
			get_viewport().set_input_as_handled()

func _process_enter(text: String) -> void:
	freeze_current_line()
	
	if input_mode == "password":
		input_mode = "normal"
		input_provided.emit(text)
		return
	elif input_mode == "input":
		input_mode = "normal"
		input_provided.emit(text)
		return
		
	if text.strip_edges() == "":
		_redraw_terminal()
		input_field.grab_focus()
		return
		
	if command_history.is_empty() or command_history[0] != text:
		command_history.push_front(text)
		if command_history.size() > 50:
			command_history.pop_back()
	history_index = -1
	
	if in_ftp_mode:
		await _handle_ftp_command(text)
	else:
		await _execute_command(text)
		
	_update_prompt()
	input_field.grab_focus()

func _execute_command(text: String) -> void:
	var parts = text.split(" ", false)
	var cmd = parts[0]
	var args = []
	for i in range(1, parts.size()):
		args.append(parts[i])
		
	GlobalSignals.command_executed.emit(cmd, args)
	
	var context = {
		"terminal": self
	}
	
	var result = await command_registry.execute(cmd, args, context)
	if result is CommandResult:
		if result.clear_screen:
			static_history = ""
		elif result.output != "":
			print_output(result.output, not result.success)

func _handle_ftp_command(text: String) -> void:
	var parts = text.split(" ", false)
	var cmd = parts[0]
	
	if cmd == "quit" or cmd == "exit":
		in_ftp_mode = false
		NetworkManager.disconnect_current()
		navigator.set_machine(NetworkManager.get_local_machine())
		print_output("221 Goodbye.")
	elif cmd == "ls":
		var nav_res = navigator.list_directory(false)
		var out = ""
		for f in nav_res:
			var file_size = f.content.length() if f.type == FileNode.FILE else 4096
			out += "-rw-r--r-- 1 ftp ftp %d Jan 1 00:00 %s\n" % [file_size, f.name]
		print_output(out.strip_edges())
	elif cmd == "get":
		if parts.size() < 2:
			print_output("get <filename>")
		else:
			var f = navigator.get_file(parts[1])
			if f and f.type == FileNode.FILE:
				print_output("200 PORT command successful. Consider using PASV.")
				print_output("150 Opening BINARY mode data connection for " + f.name)
				await get_tree().create_timer(1.0).timeout
				print_output("226 Transfer complete.")
			else:
				print_output("550 Failed to open file.")
	else:
		print_output("?Invalid command")

func request_password(prompt_text: String) -> String:
	input_mode = "password"
	current_prompt = prompt_text
	_redraw_terminal()
	
	var user_input = await input_provided
	_update_prompt()
	return user_input

func request_input(prompt_text: String) -> String:
	input_mode = "input"
	current_prompt = prompt_text
	_redraw_terminal()
	
	var user_input = await input_provided
	_update_prompt()
	return user_input

func enter_ftp_mode() -> void:
	in_ftp_mode = true

func _on_trace_updated(_machine: MachineResource, progress: float) -> void:
	trace_bar.show()
	trace_progress.value = progress * 100.0

func _on_trace_completed(_machine: MachineResource) -> void:
	trace_bar.hide()
	print_output("[color=#ff3333][!!] trace complete - connection terminated. machine locked.[/color]")

func _on_machine_changed(_machine: MachineResource) -> void:
	_update_prompt()

func _on_tier1_triggered(_machine: MachineResource) -> void:
	print_output("[color=#ffaa00][!] authentication failed - attempt logged[/color]")

func _on_tier2_triggered(_machine: MachineResource) -> void:
	print_output("[color=#ff3333][!] too many failed attempts - service locked (2:00)[/color]")

func _on_tier3_triggered(_machine: MachineResource) -> void:
	print_output("[color=#ff3333][!!] intrusion detection triggered - trace initiated[/color]")
	trace_bar.show()
	trace_progress.value = 0.0

func _on_lockout_expired(_machine: MachineResource) -> void:
	print_output("[i] lockout expired - service available[/i]")

func _on_cloak_expired(_machine: MachineResource) -> void:
	print_output("[color=#00ff41][phantom] cooldown expired - target available[/color]")
