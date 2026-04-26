extends RefCounted

func execute(args: Array, context: Dictionary) -> CommandResult:
	if args.is_empty():
		return CommandResult.new("touch: missing file operand", false)
	var nav = context.terminal.navigator
	# Update timestamp if exists, otherwise create empty file
	for child in nav.current_directory.children:
		if child.name == args[0]:
			return CommandResult.new("", true)
	var new_file = FileNode.new()
	new_file.name = args[0]
	new_file.type = FileNode.FILE
	new_file.permissions = "rw-r--r--"
	new_file.content = ""
	nav.current_directory.children.append(new_file)
	return CommandResult.new("", true)
