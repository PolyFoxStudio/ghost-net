extends RefCounted

func execute(args: Array, context: Dictionary) -> CommandResult:
	if args.size() < 1 or args[0] != "--cloak":
		return CommandResult.new("[phantom] unknown directive - available: --cloak", false)

	var traced_machine: MachineResource = null
	for ip in NetworkManager._machines:
		var m: MachineResource = NetworkManager._machines[ip]
		if m.is_traced:
			traced_machine = m
			break
			
	if not traced_machine:
		return CommandResult.new("[color=#ffaa00][!] no active trace detected - cloak unnecessary[/color]", false)
		
	traced_machine.is_traced = false
	traced_machine.trace_progress = 0.0
	traced_machine.cloak_cooldown = 180.0
	
	if context.has("terminal"):
		context.terminal.trace_bar.hide()
		context.terminal.print_output("[phantom] engaging cloak protocol...")
		await context.terminal.get_tree().create_timer(1.0).timeout
		context.terminal.print_output("[phantom] scrubbing outbound signatures...")
		await context.terminal.get_tree().create_timer(1.0).timeout
		context.terminal.print_output("[phantom] trace neutralised.")
		await context.terminal.get_tree().create_timer(1.0).timeout
		
	return CommandResult.new("[color=#ffaa00][!] target machine flagged - 3 minute cooldown before re-engaging[/color]", true)
