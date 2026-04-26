extends RefCounted

func execute(args: Array, context: Dictionary) -> CommandResult:
	if args.size() < 2:
		return CommandResult.new("mv: missing destination operand", false)
	var nav = context.terminal.navigator
	var src_name = args[0]
	var dst_name = args[1]
	for child in nav.current_directory.children:
		if child.name == src_name:
			child.name = dst_name
			return CommandResult.new("", true)
	return CommandResult.new("mv: '%s': No such file or directory" % src_name, false)
