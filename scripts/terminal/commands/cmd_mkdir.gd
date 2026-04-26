extends RefCounted

func execute(args: Array, context: Dictionary) -> CommandResult:
	if args.is_empty():
		return CommandResult.new("mkdir: missing operand", false)
	var nav = context.terminal.navigator
	var new_dir = FileNode.new()
	new_dir.name = args[0]
	new_dir.type = FileNode.DIRECTORY
	new_dir.permissions = "rwxr-xr-x"
	nav.current_directory.children.append(new_dir)
	return CommandResult.new("", true)
