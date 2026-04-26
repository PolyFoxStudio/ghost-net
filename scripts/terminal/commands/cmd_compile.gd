extends RefCounted

func execute(args: Array, context: Dictionary) -> CommandResult:
	if args.is_empty():
		return CommandResult.new("compile v1.0 — by Cipher\nUsage: compile --dossier [folder] --out [filename]", false)

	var folder = ""
	var out_name = ""
	var i = 0
	while i < args.size():
		if args[i] == "--dossier" and i + 1 < args.size():
			folder = args[i + 1]
			i += 2
		elif args[i] == "--out" and i + 1 < args.size():
			out_name = args[i + 1]
			i += 2
		else:
			i += 1

	if folder == "":
		return CommandResult.new("compile: missing --dossier [folder]", false)
	if out_name == "":
		return CommandResult.new("compile: missing --out [filename]", false)

	if context.has("terminal"):
		context.terminal.print_output("compile v1.0 — by Cipher")
		context.terminal.print_output("[*] Compiling dossier from: %s" % folder)
		await context.terminal.get_tree().create_timer(1.0).timeout
		context.terminal.print_output("[*] Indexing files...")
		await context.terminal.get_tree().create_timer(0.8).timeout
		context.terminal.print_output("[*] Generating table of contents...")
		await context.terminal.get_tree().create_timer(0.8).timeout
		context.terminal.print_output("[OK] Dossier compiled: %s.pdf + %s.zip" % [out_name, out_name])
		await context.terminal.get_tree().create_timer(0.3).timeout
		context.terminal.print_output('// compile v1.0 — "i wrote this one at 3am. it shows, probably." — cipher')
	return CommandResult.new("", true)
