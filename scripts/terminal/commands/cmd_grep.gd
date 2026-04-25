extends RefCounted

func execute(args: Array, context: Dictionary) -> CommandResult:
	if args.size() < 2:
		return CommandResult.new("usage: grep [-r] <term> <file_or_path>", false)
		
	var recursive = false
	var term = ""
	var path = ""
	
	if args[0] == "-r":
		if args.size() < 3:
			return CommandResult.new("usage: grep -r <term> <path>", false)
		recursive = true
		term = args[1]
		path = args[2]
	else:
		term = args[0]
		path = args[1]
		
	var nav: FilesystemNavigator = context.terminal.navigator
	
	if recursive:
		var target_dir = nav.current_directory
		if path != "" and path != ".":
			# Get target dir node
			var original_dir = nav.current_directory
			var original_stack = nav.current_path_stack.duplicate()
			var res = nav.change_directory(path)
			if not res.success:
				return CommandResult.new(res.error, false)
			target_dir = nav.current_directory
			nav.current_directory = original_dir
			nav.current_path_stack = original_stack
			
		var matches = nav.grep_files(term, target_dir, path if path != "." else "")
		if matches.is_empty():
			return CommandResult.new("(no matches found)", true)
			
		var out = ""
		for m in matches:
			var matched_line = m.line.replace(term, "[color=#ff3333]" + term + "[/color]")
			out += "%s:%d: %s\n" % [m.path, m.line_num, matched_line]
		return CommandResult.new(out.strip_edges(), true)
	else:
		var file_node = nav.get_file(path)
		if not file_node:
			return CommandResult.new("grep: %s: No such file or directory" % path, false)
		if file_node.type == FileNode.DIRECTORY:
			return CommandResult.new("grep: %s: Is a directory" % path, false)
			
		var lines = file_node.content.split("\n")
		var out = ""
		var line_num = 1
		for line in lines:
			if term in line:
				var matched_line = line.replace(term, "[color=#ff3333]" + term + "[/color]")
				out += "%d: %s\n" % [line_num, matched_line]
			line_num += 1
			
		if out == "":
			return CommandResult.new("(no matches found)", true)
		return CommandResult.new(out.strip_edges(), true)
