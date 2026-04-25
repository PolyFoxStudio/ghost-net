extends RefCounted

func execute(args: Array, context: Dictionary):
	if args.size() == 0:
		return CommandResult.new("cat: missing operand", false)
		
	var path = args[0]
	var nav: FilesystemNavigator = context.terminal.navigator
	var file_node = nav.get_file(path)
	
	if not file_node:
		return CommandResult.new("cat: %s: No such file or directory" % path, false)
		
	if file_node.type == FileNode.DIRECTORY:
		return CommandResult.new("cat: %s: Is a directory" % path, false)
		
	if file_node.is_tripwire:
		var m = NetworkManager.get_current_machine()
		if m:
			CountermeasureManager.trigger_trace(m)
			
	return CommandResult.new(file_node.content, true)
