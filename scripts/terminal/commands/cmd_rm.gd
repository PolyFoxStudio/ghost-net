extends RefCounted

func execute(args: Array, context: Dictionary) -> CommandResult:
	if args.is_empty():
		return CommandResult.new("rm: missing operand", false)
	var nav = context.terminal.navigator
	var target = args[-1]  # last arg is the target, ignore flags
	for i in nav.current_directory.children.size():
		if nav.current_directory.children[i].name == target:
			nav.current_directory.children.remove_at(i)
			return CommandResult.new("", true)
	return CommandResult.new("rm: cannot remove '%s': No such file or directory" % target, false)
