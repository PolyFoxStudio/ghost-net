class_name GameStateSingleton
extends Node

signal flag_set(flag_name: String)

var flags: Dictionary = {}

var cipher_score: int = 0
var marcus_score: int = 0

var cipher_relationship: int = 0
var cipher_relationship_score: int = 0   # range -10 to +10
var marcus_emotional_state: int = 0      # range -5 to +5
var navigator_pages_visited: int = 0

var countermeasure_tiers: Dictionary = {}

var current_act: int = 1

var player_name: String = ""
var wallpaper_default: bool = false
var intro_completed: bool = false
var beat_02_choice: String = ""
var phantomlink_unread: int = 0
var alert_level: String = "STEALTH"

func set_flag(key: String, value: Variant = true) -> void:
	flags[key] = value
	emit_signal("flag_set", key)

func get_flag(key: String, default: Variant = false) -> Variant:
	return flags.get(key, default)

func has_flag(flag_name: String) -> bool:
	return flags.get(flag_name, false) == true

func modify_cipher(amount: int) -> void:
	cipher_score = clampi(cipher_score + amount, -3, 3)

func modify_marcus(amount: int) -> void:
	marcus_score = clampi(marcus_score + amount, -3, 3)

func adjust_cipher_score(delta: int) -> void:
	cipher_relationship_score = clampi(cipher_relationship_score + delta, -10, 10)
	cipher_relationship = cipher_relationship_score

func adjust_marcus_state(delta: int) -> void:
	marcus_emotional_state = clampi(marcus_emotional_state + delta, -5, 5)

func get_cipher_threshold() -> String:
	if cipher_relationship_score >= 5: return "high"
	elif cipher_relationship_score >= -2: return "mid"
	else: return "low"

func get_tier(target_ip: String) -> int:
	return countermeasure_tiers.get(target_ip, 0)

func increment_tier(target_ip: String) -> void:
	countermeasure_tiers[target_ip] = clampi(get_tier(target_ip) + 1, 0, 3)

func set_act(act: int) -> void:
	current_act = act

func save() -> void:
	var data: Dictionary = {
		"flags": flags,
		"cipher_score": cipher_score,
		"marcus_score": marcus_score,
		"countermeasure_tiers": countermeasure_tiers,
		"current_act": current_act,
		"player_name": player_name,
		"wallpaper_default": wallpaper_default,
		"intro_completed": intro_completed,
		"beat_02_choice": beat_02_choice
	}
	var file := FileAccess.open("user://gamestate.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func load_save() -> void:
	if not FileAccess.file_exists("user://gamestate.json"): return
	var file := FileAccess.open("user://gamestate.json", FileAccess.READ)
	if file:
		var parsed = JSON.parse_string(file.get_as_text())
		file.close()
		if typeof(parsed) == TYPE_DICTIONARY:
			var data: Dictionary = parsed
			flags = data.get("flags", {})
			cipher_score = data.get("cipher_score", 0)
			marcus_score = data.get("marcus_score", 0)
			countermeasure_tiers = data.get("countermeasure_tiers", {})
			current_act = data.get("current_act", 1)
			player_name = data.get("player_name", "")
			wallpaper_default = data.get("wallpaper_default", false)
			intro_completed = data.get("intro_completed", false)
			beat_02_choice = data.get("beat_02_choice", "")
