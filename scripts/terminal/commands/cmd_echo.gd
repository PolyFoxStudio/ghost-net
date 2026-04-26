extends RefCounted

func execute(args: Array, context: Dictionary) -> CommandResult:
	if args.is_empty():
		return CommandResult.new("", true)
	return CommandResult.new(" ".join(args), true)
