extends "res://scripts/desktop/ghost_window.gd"

class_name PhantomLinkWindow

@onready var thread_items: VBoxContainer = $VBoxContainer/AppContainer/MainArea/ThreadList/Background/VBox/ThreadItems
@onready var contact_name: Label = $VBoxContainer/AppContainer/MainArea/ChatPanel/Background/VBox/Margin/VBox2/ChatHeader/ContactName
@onready var status_dot: ColorRect = $VBoxContainer/AppContainer/MainArea/ChatPanel/Background/VBox/Margin/VBox2/ChatHeader/StatusDot
@onready var message_history: RichTextLabel = $VBoxContainer/AppContainer/MainArea/ChatPanel/Background/VBox/Margin/VBox2/MessageHistory
@onready var compose_area: HBoxContainer = $VBoxContainer/AppContainer/MainArea/ChatPanel/Background/VBox/Margin/VBox2/ComposeArea
@onready var choice_panel: VBoxContainer = $VBoxContainer/AppContainer/MainArea/ChatPanel/Background/VBox/Margin/VBox2/ChoicePanel

class PLMessage:
	var speaker: String
	var text: String
	var beat_id: String
	var delay: float
	func _init(s: String, t: String, b: String, d: float = 0.0) -> void:
		speaker = s
		text = t
		beat_id = b
		delay = d

var threads_data: Dictionary = {
	"cipher": {"messages": [], "unread": false, "button": null, "choices": [], "is_typing": false},
	"marcus": {"messages": [], "unread": false, "button": null, "choices": [], "is_typing": false}
}

var current_thread: String = "cipher"
var _is_focused: bool = true

func _ready() -> void:
	app_name = "PHANTOMLINK"
	super._ready()
	
	_create_thread_button("cipher", "cipher")
	_create_thread_button("marcus", "marcus webb")
	
	_on_thread_selected("cipher")
	
	GlobalSignals.phantomlink_beat_trigger.connect(trigger_beat)

	# Setup message listener
	GlobalSignals.phantomlink_message.connect(func(sender: String, message: String):
		var msg = PLMessage.new(sender, message, "custom")
		_append_message(msg, sender)
	)

func grab_focus_internal() -> void:
	_is_focused = true
	threads_data[current_thread]["unread"] = false
	_update_thread_buttons()

func set_focused(focused: bool) -> void:
	super.set_focused(focused)
	_is_focused = focused
	if focused:
		threads_data[current_thread]["unread"] = false
		_update_thread_buttons()

func _create_thread_button(id: String, display_name: String) -> void:
	var btn: Button = Button.new()
	btn.text = display_name
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.flat = true
	btn.add_theme_color_override("font_color", Color("#555577"))
	btn.pressed.connect(func(): _on_thread_selected(id))
	thread_items.add_child(btn)
	threads_data[id]["button"] = btn

func _on_thread_selected(thread_id: String) -> void:
	current_thread = thread_id
	contact_name.text = threads_data[thread_id]["button"].text
	threads_data[thread_id]["unread"] = false
	_update_thread_buttons()
	_render_history(thread_id)
	
	# Update choices
	for child in choice_panel.get_children():
		child.queue_free()
	
	var active_choices = threads_data[thread_id]["choices"]
	if active_choices.is_empty():
		choice_panel.hide()
		compose_area.show()
	else:
		compose_area.hide()
		choice_panel.show()
		for idx in range(active_choices.size()):
			var choice: Dictionary = active_choices[idx]
			var btn: Button = Button.new()
			btn.text = choice["text"]
			btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			btn.pressed.connect(func(): _resolve_player_choice(choice))
			choice_panel.add_child(btn)

func _update_thread_buttons() -> void:
	for tid in threads_data:
		var btn: Button = threads_data[tid]["button"]
		if tid == current_thread:
			btn.add_theme_color_override("font_color", Color("#aaaacc"))
			btn.text = tid if tid == "cipher" else "marcus webb"
		else:
			if threads_data[tid]["unread"]:
				btn.add_theme_color_override("font_color", Color("#6666cc"))
				btn.text = "● " + tid if tid == "cipher" else "● marcus webb"
			else:
				btn.add_theme_color_override("font_color", Color("#555577"))
				btn.text = tid if tid == "cipher" else "marcus webb"

func _render_history(thread_id: String) -> void:
	message_history.text = ""
	for msg in threads_data[thread_id]["messages"]:
		_append_message_ui(msg)
	
	if threads_data[thread_id].get("is_typing", false):
		message_history.append_text("[color=#555577][font_size=10]" + thread_id + " is typing...[/font_size][/color]\n")

func _append_message(msg: PLMessage, thread_id: String) -> void:
	threads_data[thread_id]["messages"].append(msg)
	if thread_id == current_thread:
		_render_history(thread_id)
	
	if not _is_focused or thread_id != current_thread:
		threads_data[thread_id]["unread"] = true
		_update_thread_buttons()
		GlobalSignals.phantomlink_message_received.emit(thread_id, msg.beat_id)

func _append_message_ui(msg: PLMessage) -> void:
	var bb: String = ""
	if msg.speaker == "cipher":
		bb = "[color=#555577][font_size=10]cipher · just now[/font_size][/color]\n[color=#aaaacc]" + msg.text + "[/color]\n\n"
	elif msg.speaker == "ghost":
		bb = "[right][color=#555577][font_size=10]you · just now[/font_size][/color]\n[color=#666688]" + msg.text + "[/color][/right]\n\n"
	elif msg.speaker == "marcus":
		bb = "[color=#555577][font_size=10]marcus · just now[/font_size][/color]\n[color=#ccaa88]" + msg.text + "[/color]\n\n"
	message_history.append_text(bb)

func trigger_beat(beat_id: String) -> void:
	if beat_id == "beat_03" and GameState.get_flag("beat_03_complete", false): return
	var msgs: Array = _get_beat_messages(beat_id)
	if msgs.is_empty(): return
	var thread_id: String = _get_beat_thread(beat_id)
	_process_message_queue(msgs, thread_id, beat_id)

func _process_message_queue(msgs: Array, thread_id: String, beat_id: String) -> void:
	for m in msgs:
		var delay_time = m.delay
		if delay_time <= 0:
			delay_time = max(1.0, m.text.length() * 0.04) # 40ms per char
			
		if m.speaker != "ghost":
			threads_data[thread_id]["is_typing"] = true
			if thread_id == current_thread:
				_render_history(thread_id)
				
		await get_tree().create_timer(delay_time).timeout
		
		if m.speaker != "ghost":
			threads_data[thread_id]["is_typing"] = false
			
		_append_message(m, thread_id)
	
	_show_choices_for_beat(beat_id)
	
	if beat_id == "beat_00b":
		trigger_beat("beat_01")
	elif beat_id in ["beat_01_A", "beat_01_B", "beat_01_C"]:
		trigger_beat("beat_01_merge")
	elif beat_id == "beat_01_merge":
		pass
	elif beat_id == "beat_10":
		# After Beat 10 completes, start timers for Beat 10b (file drop) and Beat 10c (idle check)
		_start_beat10b_timer()
		_start_beat10c_timer()

func _get_beat_thread(beat_id: String) -> String:
	if beat_id.begins_with("beat_04") or beat_id.begins_with("beat_13") or beat_id.begins_with("beat_15"): return "marcus"
	return "cipher"

func _get_beat_messages(beat_id: String) -> Array:
	match beat_id:
		"beat_00b":
			return [
				PLMessage.new("cipher", "wherever you went.", beat_id),
				PLMessage.new("cipher", "i hope it's somewhere quiet.", beat_id),
				PLMessage.new("cipher", "take care of yourself.", beat_id),
				PLMessage.new("cipher", "— c", beat_id),
				PLMessage.new("ghost", "I'm back.\nI need your help with something.\nThere's a missing woman. Her husband reached out.\nI said yes.", beat_id, 2.0)
			]
		"beat_01":
			return [
				PLMessage.new("cipher", "GHOST.", beat_id, 0.8),
				PLMessage.new("cipher", "you're actually back", beat_id, 1.2),
				PLMessage.new("cipher", "okay i'm fine i'm being normal", beat_id, 2.0),
				PLMessage.new("cipher", "i read your last message by the way", beat_id, 0.5),
				PLMessage.new("ghost", "I know. I'm sorry I didn't reply.", beat_id, 1.5),
				PLMessage.new("cipher", "...", beat_id, 3.0),
				PLMessage.new("cipher", "don't worry about it", beat_id, 1.5),
				PLMessage.new("cipher", "you're here now", beat_id, 2.0),
				PLMessage.new("cipher", "tell me about the woman", beat_id, 1.0)
			]
		"beat_01_A":
			return [
				PLMessage.new("cipher", "helix solutions", beat_id, 1.0),
				PLMessage.new("cipher", "give me two minutes", beat_id, 4.0),
				PLMessage.new("cipher", "okay so", beat_id, 0.8),
				PLMessage.new("cipher", "their public footprint is very clean", beat_id, 1.0),
				PLMessage.new("cipher", "which is interesting", beat_id, 1.5),
				PLMessage.new("cipher", "companies that do legitimate compliance work\ndon't usually scrub this hard", beat_id, 2.0),
				PLMessage.new("cipher", "i want to help with this one", beat_id, 1.5),
				PLMessage.new("cipher", "actually — i've been working on something", beat_id, 1.0),
				PLMessage.new("cipher", "for a while now", beat_id, 0.8),
				PLMessage.new("cipher", "i was going to give it to you eventually anyway", beat_id, 1.2),
				PLMessage.new("cipher", "this feels like the right time", beat_id, 1.0)
			]
		"beat_01_B":
			return [
				PLMessage.new("cipher", "six days is a long time", beat_id, 1.2),
				PLMessage.new("cipher", "police won't move until it's too late, they never do", beat_id, 1.5),
				PLMessage.new("cipher", "alright. i'm in.", beat_id, 2.0),
				PLMessage.new("cipher", "i've got something for you actually", beat_id, 1.0),
				PLMessage.new("cipher", "been sitting on it for a while", beat_id, 1.0)
			]
		"beat_01_C":
			return [
				PLMessage.new("cipher", "okay", beat_id, 0.8),
				PLMessage.new("cipher", "fair enough", beat_id, 2.0),
				PLMessage.new("cipher", "i've got a toolkit ready", beat_id, 1.0),
				PLMessage.new("cipher", "actually it's more than a toolkit", beat_id, 1.0)
			]
		"beat_01_merge":
			return [
				PLMessage.new("cipher", "i'm going to send you something", beat_id, 1.0),
				PLMessage.new("cipher", "it's. okay so.", beat_id, 1.5),
				PLMessage.new("cipher", "i built it over the last couple of years", beat_id, 1.0),
				PLMessage.new("cipher", "properly built it. not just scripts.", beat_id, 0.8),
				PLMessage.new("cipher", "a whole environment", beat_id, 2.0),
				PLMessage.new("cipher", "i named it GhostNet", beat_id, 1.2),
				PLMessage.new("cipher", "before you say anything", beat_id, 0.8),
				PLMessage.new("cipher", "the name is load-bearing", beat_id, 0.6),
				PLMessage.new("cipher", "technically", beat_id, 1.0),
				PLMessage.new("ghost", "You named your operating system after me.", beat_id, 2.0),
				PLMessage.new("cipher", "...our operating system", beat_id, 3.0),
				PLMessage.new("cipher", "i think you'll find", beat_id, 2.0),
				PLMessage.new("cipher", "anyway. installing now. give it a minute.", beat_id, 1.0)
			]
		"beat_02":
			return [
				PLMessage.new("cipher", "okay so", beat_id),
				PLMessage.new("cipher", "it has your name on it", beat_id),
				PLMessage.new("cipher", "obviously", beat_id),
				PLMessage.new("cipher", "i thought that was clear from context but", beat_id),
				PLMessage.new("cipher", "the boot screen also says it", beat_id),
				PLMessage.new("cipher", "and the taskbar", beat_id),
				PLMessage.new("cipher", "and there's a watermark in the corner", beat_id),
				PLMessage.new("cipher", "it's tasteful", beat_id)
			]
		"beat_02_A":
			return [
				PLMessage.new("cipher", "three days", beat_id),
				PLMessage.new("cipher", "do not tell anyone that", beat_id),
				PLMessage.new("cipher", "the watermark was the hardest part actually", beat_id),
				PLMessage.new("cipher", "i wanted it to be subtle but also unmistakeable", beat_id),
				PLMessage.new("cipher", "i think i nailed it", beat_id),
				PLMessage.new("cipher", "anyway. the tools are all preloaded.", beat_id)
			]
		"beat_02_B":
			return [
				PLMessage.new("cipher", "yeah", beat_id),
				PLMessage.new("cipher", "good", beat_id),
				PLMessage.new("cipher", "the tools are preloaded, terminal's ready", beat_id),
				PLMessage.new("cipher", "let me know when you're in", beat_id)
			]
		"beat_02_C":
			return [
				PLMessage.new("cipher", "i could have done a lot of things", beat_id),
				PLMessage.new("cipher", "there are seven startup sounds by the way", beat_id, 2.0),
				PLMessage.new("cipher", "the fourth one is the best one", beat_id),
				PLMessage.new("cipher", "use the fourth one", beat_id)
			]
		"beat_03":
			return [
				PLMessage.new("cipher", "first rule of ghostnet.", beat_id),
				PLMessage.new("cipher", "always proxychains. ALWAYS.", beat_id),
				PLMessage.new("cipher", "i cannot stress this enough", beat_id),
				PLMessage.new("cipher", "i built the whole proxy layer specifically so you'd use it", beat_id),
				PLMessage.new("cipher", "please use it", beat_id)
			]
		"beat_03_A":
			return [
				PLMessage.new("cipher", "i know you know", beat_id),
				PLMessage.new("cipher", "i'm just saying", beat_id),
				PLMessage.new("cipher", "also bleachbit after every session", beat_id),
				PLMessage.new("cipher", "and the evidence vault auto-encrypts but double check anyway", beat_id),
				PLMessage.new("cipher", "okay i'm done. go investigate.", beat_id)
			]
		"beat_03_B":
			return [
				PLMessage.new("cipher", "okay yes", beat_id),
				PLMessage.new("cipher", "phantom is the big one — run phantom --help first", beat_id),
				PLMessage.new("cipher", "ghostwire handles identity spoofing, i'll explain that when you need it", beat_id),
				PLMessage.new("cipher", "deadrop is for file drops — anonymous, untraceable, not to be used lightly", beat_id),
				PLMessage.new("cipher", "compile builds your dossier at the end when you're ready to go public", beat_id),
				PLMessage.new("cipher", "that's the toolkit", beat_id),
				PLMessage.new("cipher", "now go. you've got a missing person.", beat_id)
			]
		"beat_03_C":
			return [
				PLMessage.new("cipher", "just use proxychains", beat_id, 30.0)
			]
		"beat_04":
			return [
				PLMessage.new("marcus", "i sent everything i have", beat_id),
				PLMessage.new("marcus", "her photo, her employee ID from an old email, the name of her manager", beat_id),
				PLMessage.new("marcus", "and a timeline i wrote out as best i could", beat_id),
				PLMessage.new("marcus", "i don't know if any of it is useful", beat_id),
				PLMessage.new("marcus", "i don't really know how this works", beat_id),
				PLMessage.new("marcus", "i just wanted to say — thank you", beat_id),
				PLMessage.new("marcus", "for saying yes", beat_id),
				PLMessage.new("marcus", "i didn't know who else to call", beat_id)
			]
		"beat_04_A":
			return [
				PLMessage.new("marcus", "okay", beat_id),
				PLMessage.new("marcus", "okay. that's good.", beat_id),
				PLMessage.new("marcus", "she'd been anxious for weeks before she disappeared", beat_id),
				PLMessage.new("marcus", "not sleeping. jumping at things.", beat_id),
				PLMessage.new("marcus", "i kept asking her what was wrong and she kept saying work was stressful", beat_id),
				PLMessage.new("marcus", "i should have pushed harder", beat_id),
				PLMessage.new("marcus", "there was a woman she mentioned a few times. Diane Marsh.", beat_id),
				PLMessage.new("marcus", "she said Diane was the only one at Helix she actually trusted", beat_id),
				PLMessage.new("marcus", "i don't know if that means anything to you", beat_id),
				PLMessage.new("marcus", "i hope it does", beat_id)
			]
		"beat_04_B":
			return [
				PLMessage.new("marcus", "yes", beat_id),
				PLMessage.new("marcus", "there was someone", beat_id),
				PLMessage.new("marcus", "a woman called Diane Marsh", beat_id),
				PLMessage.new("marcus", "she worked with Nadia. senior analyst or something like that.", beat_id),
				PLMessage.new("marcus", "Nadia mentioned her a few times in the last few months", beat_id),
				PLMessage.new("marcus", "said she was one of the good ones", beat_id),
				PLMessage.new("marcus", "i don't know if she knows anything", beat_id),
				PLMessage.new("marcus", "but she knew Nadia better than most people there did", beat_id)
			]
		"beat_04_C":
			return [
				PLMessage.new("marcus", "i know", beat_id),
				PLMessage.new("marcus", "i know you can't promise", beat_id),
				PLMessage.new("marcus", "thank you for being straight with me", beat_id),
				PLMessage.new("marcus", "i'll be here if you need anything", beat_id),
				PLMessage.new("marcus", "anything at all", beat_id)
			]
		"beat_05":
			return [
				PLMessage.new("cipher", "okay so theHarvester just flagged something", beat_id),
				PLMessage.new("cipher", "helix solutions has active employee addresses", beat_id),
				PLMessage.new("cipher", "real ones. not just the info@ contact", beat_id),
				PLMessage.new("cipher", "i've pushed a new tool to your desktop", beat_id),
				PLMessage.new("cipher", "it's called SENET", beat_id),
				PLMessage.new("cipher", "social engineering network exploitation toolkit", beat_id),
				PLMessage.new("cipher", "before you say anything — the name was already taken when i tried to name it something cooler", beat_id),
				PLMessage.new("cipher", "anyway", beat_id),
				PLMessage.new("cipher", "it lets you craft emails under ghostwire identities", beat_id),
				PLMessage.new("cipher", "you'll need to have run ghostwire --list first", beat_id),
				PLMessage.new("cipher", "and you'll need to already know the addresses", beat_id),
				PLMessage.new("cipher", "it won't fill them in for you", beat_id),
				PLMessage.new("cipher", "the tool finds the crack. you have to choose whether to use it.", beat_id)
			]
		"beat_06":
			return [
				PLMessage.new("cipher", "BVI registered. nominee director. no beneficial owner disclosed.", beat_id),
				PLMessage.new("cipher", "this wasn't set up for tax efficiency", beat_id),
				PLMessage.new("cipher", "it was set up to hide who's really behind helix", beat_id),
				PLMessage.new("cipher", "holt and vane are the names on the tin", beat_id),
				PLMessage.new("cipher", "but whoever's pulling the strings doesn't want their name anywhere near this", beat_id),
				PLMessage.new("cipher", "that's not compliance consulting", beat_id),
				PLMessage.new("cipher", "that's a front", beat_id)
			]
		"beat_07":
			return [
				PLMessage.new("cipher", "she deleted it", beat_id),
				PLMessage.new("cipher", "but she retweeted a whistleblower guide three days before she went quiet", beat_id),
				PLMessage.new("cipher", "she knew what she was sitting on", beat_id),
				PLMessage.new("cipher", "and she was trying to figure out what to do about it", beat_id),
				PLMessage.new("cipher", "that's not someone who ran", beat_id),
				PLMessage.new("cipher", "that's someone who got scared and started looking for an exit", beat_id),
				PLMessage.new("cipher", "keep going", beat_id)
			]
		"beat_08":
			return [
				PLMessage.new("cipher", "sarah okafor", beat_id),
				PLMessage.new("cipher", "she's the right person for this", beat_id),
				PLMessage.new("cipher", "read her data broker piece — she knows exactly what she's looking at", beat_id),
				PLMessage.new("cipher", "and she's got a securedrop", beat_id),
				PLMessage.new("cipher", "that's important", beat_id),
				PLMessage.new("cipher", "when you've got what you need", beat_id),
				PLMessage.new("cipher", "she's one of the people who can do something with it", beat_id)
			]
		"beat_09":
			return [
				PLMessage.new("cipher", "archivst", beat_id),
				PLMessage.new("cipher", "handle's too new to have a trail", beat_id),
				PLMessage.new("cipher", "but the data they're selling", beat_id),
				PLMessage.new("cipher", "the format matches helix's audit exports", beat_id),
				PLMessage.new("cipher", "i've seen enough of those to know", beat_id),
				PLMessage.new("cipher", "this is an inside job or very close to one", beat_id),
				PLMessage.new("cipher", "run phantom --trace archivst if you haven't", beat_id),
				PLMessage.new("cipher", "it won't get far but it'll tell us something", beat_id)
			]
		"beat_10":
			return [
				PLMessage.new("cipher", "vaultpay processing", beat_id),
				PLMessage.new("cipher", "that's the money pipe", beat_id),
				PLMessage.new("cipher", "helix runs the data, vaultpay moves what it's worth", beat_id),
				PLMessage.new("cipher", "and both of them trace back to the same BVI box", beat_id),
				PLMessage.new("cipher", "holt-vane holdings is the hub", beat_id),
				PLMessage.new("cipher", "whoever controls holt-vane controls everything", beat_id),
				PLMessage.new("cipher", "we need a name", beat_id),
				PLMessage.new("cipher", "the nominee director arrangement is a dead end", beat_id),
				PLMessage.new("cipher", "but there'll be a trace somewhere", beat_id),
				PLMessage.new("cipher", "there always is", beat_id)
			]
		"beat_11":
			return [
				PLMessage.new("cipher", "a company owned entirely by another company with no named individuals", beat_id),
				PLMessage.new("cipher", "that's a structure designed to obscure", beat_id),
				PLMessage.new("cipher", "it's legal. barely.", beat_id),
				PLMessage.new("cipher", "but nobody sets it up this way unless they expect scrutiny", beat_id),
				PLMessage.new("cipher", "they were expecting scrutiny", beat_id),
				PLMessage.new("cipher", "that means they knew they were doing something worth scrutinising", beat_id)
			]
		"beat_12":
			return [
				PLMessage.new("cipher", "okay so", beat_id),
				PLMessage.new("cipher", "the name kane", beat_id),
				PLMessage.new("cipher", "i've seen it before", beat_id),
				PLMessage.new("cipher", "not in public records. elsewhere.", beat_id),
				PLMessage.new("cipher", "i know someone who might know more", beat_id),
				PLMessage.new("cipher", "they go by vesper", beat_id),
				PLMessage.new("cipher", "they're careful. very careful.", beat_id),
				PLMessage.new("cipher", "i'm going to introduce you", beat_id),
				PLMessage.new("cipher", "but you need to be on tor first", beat_id),
				PLMessage.new("cipher", "and you need to be patient", beat_id),
				PLMessage.new("cipher", "vesper doesn't like being rushed", beat_id),
				PLMessage.new("cipher", "i've sent an introduction", beat_id, 3.0),
				PLMessage.new("cipher", "check phantomboard4w9z.onion when you're ready", beat_id),
				PLMessage.new("cipher", "the thread will be there", beat_id)
			]
		"beat_13":
			return [
				PLMessage.new("marcus", "sorry to message again", beat_id),
				PLMessage.new("marcus", "i don't want to get in the way", beat_id),
				PLMessage.new("marcus", "i just", beat_id),
				PLMessage.new("marcus", "is there anything? anything at all?", beat_id),
				PLMessage.new("marcus", "i've been sitting here trying not to refresh my phone", beat_id)
			]
		"beat_13_A":
			return [
				PLMessage.new("marcus", "okay", beat_id),
				PLMessage.new("marcus", "okay, that's enough", beat_id),
				PLMessage.new("marcus", "thank you", beat_id),
				PLMessage.new("marcus", "i'll leave you to it", beat_id)
			]
		"beat_13_B":
			return [
				PLMessage.new("marcus", "i wasn't going to", beat_id),
				PLMessage.new("marcus", "i was thinking about it", beat_id, 3.0),
				PLMessage.new("marcus", "but i wasn't going to", beat_id),
				PLMessage.new("marcus", "thank you", beat_id)
			]
		"beat_13_C":
			return [
				PLMessage.new("marcus", "right", beat_id),
				PLMessage.new("marcus", "yeah", beat_id),
				PLMessage.new("marcus", "i'm going to go for a walk", beat_id),
				PLMessage.new("marcus", "i'll be fine", beat_id)
			]
		"beat_15":
			return [
				PLMessage.new("marcus", "you found her", beat_id),
				PLMessage.new("marcus", "you actually found her", beat_id),
				PLMessage.new("marcus", "i don't know what to say", beat_id),
				PLMessage.new("marcus", "thank you", beat_id),
				PLMessage.new("marcus", "i mean it", beat_id),
				PLMessage.new("marcus", "thank you", beat_id)
			]
		"beat_15_A":
			var msgs: Array = []
			msgs.append(PLMessage.new("marcus", "i knew something was wrong", beat_id))
			msgs.append(PLMessage.new("marcus", "i should have pushed harder", beat_id))
			msgs.append(PLMessage.new("marcus", "but at least now we know", beat_id))
			msgs.append(PLMessage.new("marcus", "at least now i can bring her home", beat_id))
			
			if GameState.is_convergence_high():
				msgs.append(PLMessage.new("marcus", "and tell whoever helped you… thank you", beat_id, 1.8))
				msgs.append(PLMessage.new("marcus", "from both of us", beat_id))
			
			return msgs
		"beat_15_B":
			return [
				PLMessage.new("marcus", "i need to call her family", beat_id),
				PLMessage.new("marcus", "and i need to sit down", beat_id),
				PLMessage.new("marcus", "i'll be okay", beat_id),
				PLMessage.new("marcus", "thank you for telling me", beat_id)
			]
		"beat_15_C":
			return [
				PLMessage.new("marcus", "okay", beat_id),
				PLMessage.new("marcus", "okay", beat_id, 3.0),
				PLMessage.new("marcus", "i need some time", beat_id),
				PLMessage.new("marcus", "but thank you", beat_id)
			]
		"beat_16":
			var threshold = GameState.get_cipher_threshold()
			var msgs = []
			if threshold == "high":
				msgs.append(PLMessage.new("cipher", "hey", beat_id))
				msgs.append(PLMessage.new("cipher", "you going dark again after this", beat_id, 3.0))
				msgs.append(PLMessage.new("cipher", "you don't have to answer that", beat_id, 2.0))
				msgs.append(PLMessage.new("cipher", "i just", beat_id))
				msgs.append(PLMessage.new("cipher", "ghostnet needs its ghost", beat_id))
				msgs.append(PLMessage.new("cipher", "that's just a fact", beat_id))
				msgs.append(PLMessage.new("cipher", "that's how the software works", beat_id))
				
				if GameState.beat_02_choice == "watermark":
					msgs.append(PLMessage.new("cipher", "i kept thinking about the watermark while you were in there", beat_id, 3.0))
					msgs.append(PLMessage.new("cipher", "three days and i almost didn't put it in", beat_id))
					msgs.append(PLMessage.new("cipher", "thought it was too much", beat_id))
					msgs.append(PLMessage.new("cipher", "i'm glad i did", beat_id))
				else:
					msgs.append(PLMessage.new("cipher", "you used proxychains the whole time didn't you", beat_id, 3.0))
					msgs.append(PLMessage.new("cipher", "i know you did", beat_id))
					msgs.append(PLMessage.new("cipher", "i'm not going to make a thing of it", beat_id))
					
				msgs.append(PLMessage.new("cipher", "don't disappear again", beat_id, 3.0))
				msgs.append(PLMessage.new("cipher", "i mean it", beat_id))
				
				if GameState.is_convergence_mid():
					msgs.append(PLMessage.new("cipher", "the husband", beat_id, 1.5))
					msgs.append(PLMessage.new("cipher", "is he okay", beat_id))
			elif threshold == "mid":
				msgs.append(PLMessage.new("cipher", "hey", beat_id))
				msgs.append(PLMessage.new("cipher", "you did good work", beat_id))
				msgs.append(PLMessage.new("cipher", "i mean it", beat_id))
				msgs.append(PLMessage.new("cipher", "get some sleep", beat_id, 3.0))
				msgs.append(PLMessage.new("cipher", "ghostnet will still be here when you wake up", beat_id))
				msgs.append(PLMessage.new("cipher", "i'll be here when you need the next one", beat_id, 3.0))
			else:
				msgs.append(PLMessage.new("cipher", "you did it", beat_id))
				msgs.append(PLMessage.new("cipher", "i'm glad you came back", beat_id, 5.0))
				msgs.append(PLMessage.new("cipher", "even if it was just for this", beat_id))
			return msgs
	return []

func _show_choices_for_beat(beat_id: String) -> void:
	var choices: Array = []
	if beat_id == "beat_01":
		choices = [
			{"text": "Her name is Nadia Webb. She worked for a data consultancy called Helix Solutions. Her husband thinks she found something.", "next": "beat_01_A", "score": 1, "target": "cipher"},
			{"text": "Missing six days. Husband came to me through a mutual contact. Police aren't moving.", "next": "beat_01_B", "score": 0, "target": "cipher"},
			{"text": "I'll send you what I have when I have more. I just need your toolkit first.", "next": "beat_01_C", "score": -1, "target": "cipher"}
		]
	elif beat_id == "beat_02":
		choices = [
			{"text": "How long did the watermark take you.", "next": "beat_02_A", "score": 1, "target": "cipher"},
			{"text": "It's good. Thank you.", "next": "beat_02_B", "score": 0, "target": "cipher"},
			{"text": "You could have just sent me the tools.", "next": "beat_02_C", "score": -1, "target": "cipher"}
		]
	elif beat_id == "beat_03":
		choices = [
			{"text": "I know how proxychains works.", "next": "beat_03_A", "score": 0, "target": "cipher"},
			{"text": "Noted. Anything else I should know?", "next": "beat_03_B", "score": 1, "target": "cipher"},
			{"text": "...", "next": "beat_03_C", "score": -1, "target": "cipher"}
		]
	elif beat_id == "beat_04":
		choices = [
			{"text": "I got it. I'm already looking. I'll be in touch when there's something.", "next": "beat_04_A", "score": 1, "target": "marcus"},
			{"text": "Got everything. One question — was there anyone at Helix she trusted? Anyone she talked about?", "next": "beat_04_B", "score": 0, "target": "marcus"},
			{"text": "I'll be honest with you. I can't promise anything. But I'll look.", "next": "beat_04_C", "score": -1, "target": "marcus"}
		]
	elif beat_id == "beat_13":
		choices = [
			{"text": "I have leads. I'm following them. Don't do anything reckless.", "next": "beat_13_A", "score": 1, "target": "marcus"},
			{"text": "Don't contact Helix.", "next": "beat_13_B", "score": 0, "target": "marcus"},
			{"text": "I'll tell you when I have something.", "next": "beat_13_C", "score": -1, "target": "marcus"}
		]
	elif beat_id == "beat_15":
		choices = [
			{"text": "I found evidence. She was trying to blow the whistle. They stopped her.", "next": "beat_15_A", "score": 1, "target": "marcus"},
			{"text": "She's dead. I'm sorry.", "next": "beat_15_B", "score": 0, "target": "marcus"},
			{"text": "She didn't make it. I have the evidence she was trying to protect.", "next": "beat_15_C", "score": -1, "target": "marcus"}
		]

	if choices.is_empty(): return
	
	var thread_id = choices[0]["target"]
	threads_data[thread_id]["choices"] = choices
	
	if thread_id == current_thread:
		compose_area.hide()
		choice_panel.show()
		for child in choice_panel.get_children():
			child.queue_free()
		
		for idx in range(choices.size()):
			var choice: Dictionary = choices[idx]
			var btn: Button = Button.new()
			btn.text = choice["text"]
			btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			btn.pressed.connect(func(): _resolve_player_choice(choice))
			choice_panel.add_child(btn)
	else:
		# Flash unread badge since new choices are waiting
		threads_data[thread_id]["unread"] = true
		_update_thread_buttons()

func _resolve_player_choice(choice: Dictionary) -> void:
	var thread_id = choice["target"]
	threads_data[thread_id]["choices"] = []
	
	if thread_id == current_thread:
		choice_panel.hide()
		compose_area.show()
	
	var msg: PLMessage = PLMessage.new("ghost", choice["text"], "player")
	_append_message(msg, choice["target"])
	
	# Reset Beat 10c idle timer if player interacts with Cipher thread
	if choice["target"] == "cipher" and not GameState.get_flag("beat_10c_sent"):
		GameState.set_flag("beat_10c_sent", true)
	
	if choice["target"] == "cipher":
		GameState.adjust_cipher_score(choice["score"])
	else:
		GameState.adjust_marcus_state(choice["score"])
	
	if choice["next"].begins_with("beat_02_"):
		if choice["next"] == "beat_02_A": GameState.beat_02_choice = "watermark"
		elif choice["next"] == "beat_02_B": GameState.beat_02_choice = "good"
		elif choice["next"] == "beat_02_C": GameState.beat_02_choice = "tools"
		
	if choice["next"] == "beat_12_C":
		for ip in HelixConfig.HELIX_IPS:
			GameState.increment_tier(ip)
		GameState.set_flag("helix_alert_elevated", true)
	
	if choice["next"] == "beat_04_A" or choice["next"] == "beat_04_B":
		GameState.set_flag("marcus_mentioned_diane", true)
	if choice["next"] == "beat_13_B":
		GameState.set_flag("marcus_warned_about_helix", true)
	
	if choice["next"].begins_with("beat_03_"):
		GameState.set_flag("beat_03_complete", true)
		
	trigger_beat(choice["next"])
	
	if choice["next"].begins_with("beat_02_"):
		trigger_beat("beat_04")

# ── Beat 10b — Silent File Drop ────────────────────────────────
func _start_beat10b_timer() -> void:
	await get_tree().create_timer(30.0).timeout
	_drop_beat10b_file()

func _drop_beat10b_file() -> void:
	if not GameState.is_convergence_mid():  # cipher_relationship_score >= 5
		return
	if GameState.get_flag("beat_10b_dropped"):
		return
	GameState.set_flag("beat_10b_dropped", true)
	
	var machine: MachineResource = NetworkManager.get_machine("127.0.0.1")
	if not machine: 
		return
	
	# Find the ghost home directory
	var ghost_dir: FileNode = LocalMachineSetup.find_node_in_fs(machine.filesystem, "ghost")
	if not ghost_dir: 
		return
	
	# Drop note_for_ghost.txt in /home/ghost/
	var note: FileNode = FileNode.new()
	note.name = "note_for_ghost.txt"
	note.type = FileNode.FILE
	note.content = _get_beat10b_note_content()
	ghost_dir.add_child(note)
	
	# Drop partial log in /tmp/
	var tmp_dir: FileNode = LocalMachineSetup.find_or_create_dir(machine.filesystem, "tmp")
	if not tmp_dir:
		return
	var partial: FileNode = FileNode.new()
	partial.name = "kc_trace_partial.log"
	partial.type = FileNode.FILE
	partial.content = _get_beat10b_partial_log_content()
	tmp_dir.add_child(partial)

func _get_beat10b_note_content() -> String:
	return """ghost —

if you're reading this i'm already offline. which i hate.

the kane trace is almost done. i was pulling his comms metadata when i noticed the ping. gave me time to close cleanly. i think.

i left a partial map in /tmp/kc_trace_partial.log — it's incomplete but it should narrow down where they're routing security operations. might save you an hour.

also i know you won't ask but i'm fine. this isn't the first time i've had to drop off the grid for a bit. it won't be the last.

finish it.

— c

p.s. seriously though. proxychains.

p.p.s. you still run nmap without -sV first. i've seen the logs. please."""

func _get_beat10b_partial_log_content() -> String:
	return """[TRACE PARTIAL — kc_comms — auto-export on disconnect]
timestamp: [REDACTED]
target: kane, director — helix solutions ltd
method: metadata correlation via smtp relay
status: INCOMPLETE — session terminated early

routing hops identified: 3 of est. 7
  hop_01: 10.0.1.1   [helix internal gateway]
  hop_02: 185.220.x.x [tor exit — netherlands]
  hop_03: [UNRESOLVED]

notes: security ops likely routing through hop_02 subnet.
	   cross-reference with nmap scan of 10.0.1.x range.
	   — c"""

# ── Beat 10c — Cipher Idle Check ────────────────────────────────
func _start_beat10c_timer() -> void:
	if GameState.get_cipher_threshold() == "low":
		return
	if GameState.get_flag("beat_10c_sent"):
		return
	
	await get_tree().create_timer(45.0).timeout
	
	if GameState.get_flag("beat_10c_sent"):
		return  # player interacted — cancel
	
	_fire_beat10c()

func _fire_beat10c() -> void:
	GameState.set_flag("beat_10c_sent", true)
	
	# Queue to Cipher thread, no player choice
	var msgs: Array[PLMessage] = [
		PLMessage.new("cipher", "hey", "beat_10c", 0.0),
		PLMessage.new("cipher", "just checking you're still there", "beat_10c", 1.5),
		PLMessage.new("cipher", "you go quiet when things get heavy", "beat_10c", 4.0),
		PLMessage.new("cipher", "i've noticed that", "beat_10c", 1.0),
		PLMessage.new("cipher", "it's fine. i know it's how you work.", "beat_10c", 1.5),
		PLMessage.new("cipher", "i just", "beat_10c", 2.0),
		PLMessage.new("cipher", "you don't have to do that here", "beat_10c", 1.5),
		PLMessage.new("cipher", "i'm not going anywhere", "beat_10c", 2.5),
		PLMessage.new("cipher", "okay. carry on. ignore me.", "beat_10c", 3.0),
	]
	
	_process_message_queue(msgs, "cipher", "beat_10c")
