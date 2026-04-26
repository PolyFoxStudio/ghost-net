extends RefCounted

func execute(args: Array, context: Dictionary) -> CommandResult:
	var lines_count = 10
	var filename = ""
	var i = 0
	while i < args.size():
		if args[i] == "-n" and i + 1 < args.size():
			lines_count = int(args[i + 1])
			i += 2
		else:
			filename = args[i]
			i += 1
	if filename == "":
		return CommandResult.new("head: missing operand", false)
	var nav = context.terminal.navigator
	var file_node = nav.get_file(filename)
	if not file_node:
		return CommandResult.new("head: '%s': No such file or directory" % filename, false)
	if file_node.type == FileNode.DIRECTORY:
		return CommandResult.new("head: '%s': Is a directory" % filename, false)
	var lines = file_node.content.split("\n")
	return CommandResult.new("\n".join(lines.slice(0, lines_count)), true)
