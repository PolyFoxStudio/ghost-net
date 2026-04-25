extends RefCounted

func execute(args: Array, context: Dictionary) -> CommandResult:
	var m = NetworkManager.get_current_machine()
	if not m or m.network_zone == "local":
		return CommandResult.new("disconnect: not connected to any remote machine", false)
		
	NetworkManager.disconnect_current()
	if context.has("terminal"):
		context.terminal.navigator.set_machine(NetworkManager.get_local_machine())
		
	return CommandResult.new("connection closed.", true)
