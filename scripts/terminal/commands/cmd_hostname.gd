extends RefCounted

func execute(_args: Array, _context: Dictionary) -> CommandResult:
	var machine = NetworkManager.get_current_machine()
	if machine:
		return CommandResult.new(machine.hostname)
	return CommandResult.new("unknown")
