extends Node

var flags := {}
var ghostwire_active := false
var ghostwire_identity := ""
var cipher_relationship := 0

func get_flag(flag_name: String) -> bool:
	return flags.get(flag_name, false)

func set_flag(flag_name: String, value: bool) -> void:
	flags[flag_name] = value
