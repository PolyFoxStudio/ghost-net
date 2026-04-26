extends RefCounted

func execute(args: Array, context: Dictionary) -> CommandResult:
	if args.size() < 2:
		return CommandResult.new("cp: missing destination operand", false)
	var nav = context.terminal.navigator
	var src_name = args[0]
	var dst_name = args[1]
	for child in nav.current_directory.children:
		if child.name == src_name:
			var copy = child.duplicate()
			copy.name = dst_name
			nav.current_directory.children.append(copy)
			return CommandResult.new("", true)
	return CommandResult.new("cp: '%s': No such file or directory" % src_name, false)
