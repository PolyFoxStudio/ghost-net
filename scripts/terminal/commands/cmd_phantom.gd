extends RefCounted

func execute(args: Array, context: Dictionary) -> CommandResult:
	if args.is_empty():
		return CommandResult.new("usage: phantom --help", false)

	var flag = args[0]
	var target = args[1] if args.size() > 1 else ""

	if flag == "--help":
		var help_text = """PHANTOM v2.1 — Cipher Systems
Anti-forensics and network intelligence toolkit.
For Ghost's eyes only.

  phantom --trace <ip>       Map route to target, identify intermediate hops
  phantom --ping <ip>        Silent host check — leaves no trace on target
  phantom --cloak            Mask active session from intrusion detection
  phantom --wipe             Purge local session logs and forensic traces
  phantom --map              Render network topology from existing scan data

Type phantom --help to show this reference again."""
		return CommandResult.new(help_text, true)

	if flag == "--trace":
		if "kane" in target.to_lower() or "d.kane" in target.to_lower():
			var out = """phantom v0.9.7 — by Cipher
[running trace on: %s]

Full name:    Daniel Marcus Kane
DOB:          1971-08-03
Current role: Director of Internal Security, Helix Solutions Ltd.
Prior roles:  [REDACTED — government clearance flagged]
Address:      [MASKED — paid suppression service active]
Known aliases: none confirmed

[!] Government clearance history — prior public sector role, classified
[!] Paid suppression on personal data — this guy doesn't want to be found
[!] phantom note: "whoever this is, they know how to hide. careful, ghost."

// phantom v0.9.7 — "still working out the bugs. mostly." — cipher""" % target
			return CommandResult.new(out, true)
		if target == "":
			return CommandResult.new("phantom: --trace requires a target", false)
		return CommandResult.new("phantom v0.9.7 — by Cipher\n[running trace on: %s]\n\n[*] No records found." % target, false)

	elif flag == "--wipe":
		var machine = NetworkManager.get_current_machine()
		if not machine:
			return CommandResult.new("[phantom] --wipe: no active session to clean", false)
		machine.trace_progress = max(0.0, machine.trace_progress - 0.4)
		machine.is_traced = false
		if context.has("terminal"):
			context.terminal.print_output("phantom v0.9.7 — by Cipher")
			context.terminal.print_output("[*] Initiating deep log erasure...")
			await context.terminal.get_tree().create_timer(1.2).timeout
			context.terminal.print_output("[*] Scrubbing access logs...")
			await context.terminal.get_tree().create_timer(1.0).timeout
			context.terminal.print_output("[*] Rewriting timestamps...")
			await context.terminal.get_tree().create_timer(1.0).timeout
			context.terminal.print_output("[OK] Wipe complete. Alert level reduced.")
		return CommandResult.new("", true)

	elif flag == "--ping":
		var ping_target = target if target != "" else "ghostnet"
		return CommandResult.new("phantom v0.9.7 — by Cipher\n[*] Pinging: %s\n[OK] Host reachable. No anomalies detected." % ping_target, true)

	elif flag == "--cloak":
		var traced_machine: MachineResource = null
		for ip in NetworkManager._machines:
			var m: MachineResource = NetworkManager._machines[ip]
			if m.is_traced:
				traced_machine = m
				break
		if not traced_machine:
			return CommandResult.new("[color=#ffaa00][!] no active trace detected — cloak unnecessary[/color]", false)
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
		return CommandResult.new("[color=#ffaa00][!] target machine flagged — 3 minute cooldown before re-engaging[/color]", true)

	elif flag == "--map":
		var out_map = "phantom v0.9.7 — by Cipher\n[*] Quick network map:\n\n"
		for ip in NetworkManager._machines:
			var m: MachineResource = NetworkManager._machines[ip]
			out_map += "  %s  —  %s\n" % [ip, m.hostname]
		return CommandResult.new(out_map.strip_edges(), true)

	return CommandResult.new("phantom: unknown flag '%s'\nAvailable: --trace --wipe --ping --cloak --map" % flag, false)
