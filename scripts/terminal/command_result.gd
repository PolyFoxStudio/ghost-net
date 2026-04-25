class_name CommandResult
extends RefCounted

var output: String = ""
var success: bool = true
var clear_screen: bool = false

func _init(out: String = "", succ: bool = true, clear: bool = false):
	output = out
	success = succ
	clear_screen = clear
