extends RefCounted

func execute(args: Array, _context: Dictionary) -> CommandResult:
	if args.has("-a"):
		return CommandResult.new("GhostNet 2.3.1 ghostnet-kernel #1 SMP x86_64 GNU/Linux", true)
	return CommandResult.new("GhostNet", true)
