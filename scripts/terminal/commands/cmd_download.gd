extends RefCounted

func execute(args: Array, context: Dictionary):
	if args.size() == 0:
		return CommandResult.new("download: missing operand", false)
		
	var path = args[0]
	var current_machine = NetworkManager.get_current_machine()
	
	if not current_machine or current_machine.network_zone == "local":
		return CommandResult.new("download: must be connected to a remote machine", false)
		
	var nav: FilesystemNavigator = context.terminal.navigator
	var file_node = nav.get_file(path)
	
	if not file_node:
		return CommandResult.new("download: %s: No such file or directory" % path, false)
		
	if file_node.type == FileNode.DIRECTORY:
		return CommandResult.new("download: %s: Is a directory" % path, false)
		
	if context.has("terminal"):
		await context.terminal.get_tree().create_timer(0.5).timeout
		
	return CommandResult.new("downloaded: %s -> /evidence/%s" % [file_node.name, file_node.name], true)
