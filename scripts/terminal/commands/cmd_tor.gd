extends RefCounted

var tor_active: bool = false

func execute(args: Array, context: Dictionary) -> CommandResult:
	if args.is_empty():
		return CommandResult.new("tor: missing flag\nUsage: tor --start | tor --stop", false)

	var flag = args[0]

	if flag == "--start":
		if tor_active:
			return CommandResult.new("[*] Tor daemon already running.\n[OK] Dark web mode: ENABLED", true)
		tor_active = true
		if context.has("terminal"):
			context.terminal.print_output("[*] Starting Tor daemon...")
			await context.terminal.get_tree().create_timer(1.5).timeout
			context.terminal.print_output("[OK] Connected to Tor network.")
			await context.terminal.get_tree().create_timer(0.5).timeout
			context.terminal.print_output("[*] NAVIGATOR dark web mode: ENABLED")
			await context.terminal.get_tree().create_timer(0.3).timeout
			context.terminal.print_output("[!] Speed reduced. All traffic anonymised.")
		return CommandResult.new("", true)

	elif flag == "--stop":
		if not tor_active:
			return CommandResult.new("[*] Tor daemon is not running.", false)
		tor_active = false
		if context.has("terminal"):
			context.terminal.print_output("[*] Stopping Tor daemon...")
			await context.terminal.get_tree().create_timer(1.0).timeout
			context.terminal.print_output("[OK] Tor stopped. Standard routing restored.")
			context.terminal.print_output("[*] NAVIGATOR dark web mode: DISABLED")
		return CommandResult.new("", true)

	return CommandResult.new("tor: unknown flag '%s'\nUsage: tor --start | tor --stop" % flag, false)
