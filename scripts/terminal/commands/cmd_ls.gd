extends RefCounted

func execute(args: Array, context: Dictionary) -> CommandResult:
	var show_hidden = false
	var path = ""
	
	for arg in args:
		if arg.begins_with("-"):
			if "a" in arg:
				show_hidden = true
		else:
			path = arg
			
	var nav: FilesystemNavigator = context.terminal.navigator
	var target_dir = nav.current_directory
	
	if path != "":
		# Navigate temporarily
		var original_dir = nav.current_directory
		var original_stack = nav.current_path_stack.duplicate()
		var res = nav.change_directory(path)
		if not res.success:
			return CommandResult.new(res.error, false)
		target_dir = nav.current_directory
		# restore
		nav.current_directory = original_dir
		nav.current_path_stack = original_stack
		
	var children = []
	for c in target_dir.children:
		if not c.is_hidden or show_hidden:
			children.append(c)
			
	if children.is_empty():
		return CommandResult.new("", true)
		
	var out = ""
	for c in children:
		var perms = "d" + c.permissions if c.type == FileNode.DIRECTORY else "-" + c.permissions
		var name_str = c.name
		if c.type == FileNode.DIRECTORY:
			name_str = "[color=#00ff41]" + name_str + "[/color]"
		out += "%s  root  %s\n" % [perms, name_str]
		
	return CommandResult.new(out.strip_edges(), true)
