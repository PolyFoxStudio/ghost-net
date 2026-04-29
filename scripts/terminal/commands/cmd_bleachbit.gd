extends RefCounted

func execute(args: Array, context: Dictionary) -> CommandResult:
	if args.is_empty() or args[0] != "--clean":
		return CommandResult.new("bleachbit: missing flag\nUsage: bleachbit --clean [target]", false)

	var target = args[1] if args.size() > 1 else "system.logs"

	var machine = NetworkManager.get_current_machine()
	if machine:
		machine.trace_progress = max(0.0, machine.trace_progress - 0.2)

	if context.has("terminal"):
		context.terminal.print_output("[*] Cleaning: %s" % target)
		await context.terminal.get_tree().create_timer(1.0).timeout
		var entries = randi_range(400, 1200)
		context.terminal.print_output("[*] Removed: %d log entries" % entries)
		await context.terminal.get_tree().create_timer(0.5).timeout
		context.terminal.print_output("[OK] Traces cleared.")
		await context.terminal.get_tree().create_timer(0.4).timeout
		context.terminal.print_output("[!] Warning: some entries may be retained in remote backup systems.")
		context.terminal.print_output("    Use phantom --wipe for deeper coverage.")
	return CommandResult.new("", true)
