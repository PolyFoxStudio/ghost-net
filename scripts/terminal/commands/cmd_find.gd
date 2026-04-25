extends RefCounted

func execute(args: Array, context: Dictionary) -> CommandResult:
	if args.size() < 3 or args[1] != "-name":
		return CommandResult.new("usage: find <path> -name <pattern>", false)
		
	var path = args[0]
	var pattern = args[2]
	
	var nav: FilesystemNavigator = context.terminal.navigator
	
	var target_dir = nav.current_directory
	if path != "" and path != ".":
		var original_dir = nav.current_directory
		var original_stack = nav.current_path_stack.duplicate()
		var res = nav.change_directory(path)
		if not res.success:
			return CommandResult.new(res.error, false)
		target_dir = nav.current_directory
		nav.current_directory = original_dir
		nav.current_path_stack = original_stack
		
	var results = nav.find_files(pattern, target_dir, path if path != "." else "")
	
	if results.is_empty():
		return CommandResult.new("", true)
		
	var out = ""
	for r in results:
		out += r.path + "\n"
		
	return CommandResult.new(out.strip_edges(), true)
