extends Control

@onready var title_card = $TitleCard
@onready var title_label = $TitleCard/VBoxContainer/Title
@onready var subtitle_label = $TitleCard/VBoxContainer/Subtitle
@onready var background = $ColorRect

var phone_seq_scene = preload("res://scenes/intro/PhoneSequence.tscn")
var name_prompt_scene = preload("res://scenes/intro/NamePrompt.tscn")
var pre_desktop_scene = preload("res://scenes/intro/PreDesktop.tscn")

var _skipping: bool = false

func _ready() -> void:
	GameState.load_save()
	if GameState.intro_completed:
		_go_to_desktop()
		return
	
	_play_intro()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not _skipping:
		_skip_intro()

func _skip_intro() -> void:
	_skipping = true
	if GameState.player_name == "":
		GameState.player_name = "Ghost"
	_go_to_desktop()

func _go_to_desktop() -> void:
	if not GameState.intro_completed:
		GameState.set_flag("intro_just_finished", true)
	GameState.intro_completed = true
	GameState.save()
	get_tree().change_scene_to_file("res://scenes/desktop/Desktop.tscn")

func _play_intro() -> void:
	# Part 1 - Title Card
	await get_tree().create_timer(1.5).timeout
	if _skipping: return
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(title_label, "modulate:a", 1.0, 0.8)
	tween.tween_property(subtitle_label, "modulate:a", 1.0, 0.8)
	await tween.finished
	if _skipping: return
	
	await get_tree().create_timer(2.5).timeout
	if _skipping: return
	
	tween = create_tween().set_parallel(true)
	tween.tween_property(title_label, "modulate:a", 0.0, 0.8)
	tween.tween_property(subtitle_label, "modulate:a", 0.0, 0.8)
	await tween.finished
	if _skipping: return
	
	title_card.queue_free()
	
	await get_tree().create_timer(1.0).timeout
	if _skipping: return
	
	# Part 2 - Phone Sequence
	var phone = phone_seq_scene.instantiate()
	add_child(phone)
	await phone.completed
	if _skipping: return
	phone.queue_free()
	
	# Part 3 - Name Prompt
	var name_prompt = name_prompt_scene.instantiate()
	add_child(name_prompt)
	await name_prompt.completed
	if _skipping: return
	name_prompt.queue_free()
	
	# Part 4, 5, 6 - PreDesktop and Cipher
	var pre_desktop = pre_desktop_scene.instantiate()
	add_child(pre_desktop)
	await pre_desktop.completed
	if _skipping: return
	
	_go_to_desktop()
