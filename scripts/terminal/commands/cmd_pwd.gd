extends RefCounted

func execute(_args: Array, context: Dictionary) -> CommandResult:
	var nav = context.terminal.navigator
	var path = "/" + "/".join(nav.current_path_stack) if nav.current_path_stack.size() > 0 else "/"
	return CommandResult.new(path, true)
