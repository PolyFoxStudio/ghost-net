extends RefCounted

func execute(_args: Array, context: Dictionary) -> CommandResult:
	var hist = context.terminal.command_history
	if hist.is_empty():
		return CommandResult.new("", true)
	var out = ""
	for i in hist.size():
		out += "  %d  %s\n" % [i + 1, hist[i]]
	return CommandResult.new(out.strip_edges(), true)
