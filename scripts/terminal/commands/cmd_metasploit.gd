extends RefCounted

func execute(args: Array, context: Dictionary) -> CommandResult:
	if args.is_empty():
		return CommandResult.new("metasploit: missing target\nUsage: metasploit [target] [module]", false)

	var target = args[0]
	var module = args[1] if args.size() > 1 else ""

	var m = NetworkManager.get_machine(target)
	if not m or not m.is_scanned:
		return CommandResult.new("[*] Started reverse TCP handler\n[ERROR] No route to host: %s" % target, false)

	if m.cloak_cooldown > 0.0:
		return CommandResult.new("[color=#ffaa00][!] phantom cooldown active — re-engage in %d seconds[/color]" % round(m.cloak_cooldown), false)

	if m.is_locked:
		return CommandResult.new("[!] service locked — try again in %d seconds" % round(m.lockout_timer), false)

	var target_port = null
	for p in m.ports:
		if p.is_open and p.exploit_type == "rce":
			target_port = p
			break

	if not target_port:
		m.failed_attempts += 1
		CountermeasureManager.check(m)
		return CommandResult.new("[*] Started reverse TCP handler\n[*] Sending exploit payload to %s...\n[ERROR] Exploit failed — target not vulnerable to selected module." % target, false)

	if context.has("terminal"):
		context.terminal.print_output("[*] Started reverse TCP handler")
		await context.terminal.get_tree().create_timer(0.8).timeout
		context.terminal.print_output("[*] Sending exploit payload to %s..." % target)
		await context.terminal.get_tree().create_timer(1.5).timeout
		context.terminal.print_output("[*] Command shell session 1 opened")
		await context.terminal.get_tree().create_timer(0.5).timeout
		context.terminal.print_output("[!] Access granted: %s" % m.hostname)
		context.terminal.print_output("[*] Shell type: bash  |  User: www-data  |  Privileges: limited")
		context.terminal.print_output("[!] Escalation required for full file access.")
		m.is_exploited = true
		GlobalSignals.machine_exploited.emit(m.ip)
	return CommandResult.new("", true)
