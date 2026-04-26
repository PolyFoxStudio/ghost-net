extends RefCounted

func execute(args: Array, context: Dictionary) -> CommandResult:
	if args.is_empty():
		return CommandResult.new("deadrop v2.0 — by Cipher\nUsage: deadrop --send [file] --to [address]", false)

	var file_path = ""
	var recipient = ""
	var i = 0
	while i < args.size():
		if args[i] == "--send" and i + 1 < args.size():
			file_path = args[i + 1]
			i += 2
		elif args[i] == "--to" and i + 1 < args.size():
			recipient = args[i + 1]
			i += 2
		else:
			i += 1

	if file_path == "":
		return CommandResult.new("deadrop: missing --send [file]", false)
	if recipient == "":
		return CommandResult.new("deadrop: missing --to [address]", false)

	if context.has("terminal"):
		context.terminal.print_output("deadrop v2.0 — by Cipher")
		context.terminal.print_output("[*] Encrypting package...")
		await context.terminal.get_tree().create_timer(1.2).timeout
		context.terminal.print_output("[*] Fragmenting across 7 relay nodes...")
		await context.terminal.get_tree().create_timer(1.5).timeout
		context.terminal.print_output("[OK] Package sent. No return address. No trace.")
		await context.terminal.get_tree().create_timer(0.5).timeout
		context.terminal.print_output('[!] "once it\'s gone, it\'s gone. no recalls. be sure." — cipher')
	return CommandResult.new("", true)
