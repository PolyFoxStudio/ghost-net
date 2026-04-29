extends Node

var flags := {}
var ghostwire_active := false
var ghostwire_identity := ""
var cipher_relationship := 0

var cipher_relationship_score: int = 0
var marcus_emotional_state: int = 0
var navigator_pages_visited: int = 0

func get_flag(flag_name: String) -> bool:
	return flags.get(flag_name, false)

func set_flag(flag_name: String, value: bool) -> void:
	flags[flag_name] = value

func adjust_cipher_score(delta: int) -> void:
	cipher_relationship_score = clampi(cipher_relationship_score + delta, -10, 10)
	cipher_relationship = cipher_relationship_score

func adjust_marcus_state(delta: int) -> void:
	marcus_emotional_state = clampi(marcus_emotional_state + delta, -5, 5)

func get_cipher_threshold() -> String:
	if cipher_relationship_score >= 5: return "high"
	elif cipher_relationship_score >= -2: return "mid"
	else: return "low"
