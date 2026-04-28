class_name GameStateSingleton
extends Node

var flags: Dictionary = {}

var cipher_score: int = 0
var marcus_score: int = 0

var countermeasure_tiers: Dictionary = {}

var current_act: int = 1

func set_flag(key: String, value: Variant = true) -> void:
	flags[key] = value

func get_flag(key: String, default: Variant = false) -> Variant:
	return flags.get(key, default)

func modify_cipher(amount: int) -> void:
	cipher_score = clampi(cipher_score + amount, -3, 3)

func modify_marcus(amount: int) -> void:
	marcus_score = clampi(marcus_score + amount, -3, 3)

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
		"current_act": current_act
	}
	var file := FileAccess.open("user://ghostnet_save.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func load_save() -> void:
	if not FileAccess.file_exists("user://ghostnet_save.json"): return
	var file := FileAccess.open("user://ghostnet_save.json", FileAccess.READ)
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
