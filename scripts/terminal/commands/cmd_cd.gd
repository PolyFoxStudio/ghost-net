extends RefCounted

func execute(args: Array, context: Dictionary) -> CommandResult:
	var path = ""
	if args.size() > 0:
		path = args[0]
		
	var nav: FilesystemNavigator = context.terminal.navigator
	var res = nav.change_directory(path)
	if res.success:
		return CommandResult.new("", true)
	else:
		return CommandResult.new(res.error, false)
