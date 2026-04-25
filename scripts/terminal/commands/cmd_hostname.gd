extends RefCounted

func execute(args: Array, context: Dictionary) -> CommandResult:
	var machine = NetworkManager.get_current_machine()
	if machine:
		return CommandResult.new(machine.hostname)
	return CommandResult.new("unknown")
