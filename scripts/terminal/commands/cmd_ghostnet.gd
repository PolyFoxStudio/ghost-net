extends RefCounted

func execute(args: Array, _context: Dictionary) -> CommandResult:
	if args.size() == 0:
		return CommandResult.new("ghostnet: missing arguments\nUsage: ghostnet --wallpaper [default|cipher]", false)
	
	if args[0] == "--wallpaper":
		if args.size() < 2:
			return CommandResult.new("ghostnet: missing wallpaper option", false)
		
		var option = args[1].to_lower()
		if option == "default":
			GameState.wallpaper_default = true
			return CommandResult.new("Wallpaper set to default.", true)
		elif option == "cipher":
			GameState.wallpaper_default = false
			return CommandResult.new("Wallpaper set to cipher.", true)
		else:
			return CommandResult.new("ghostnet: invalid wallpaper option '%s'" % option, false)
			
	return CommandResult.new("ghostnet: invalid argument '%s'" % args[0], false)
