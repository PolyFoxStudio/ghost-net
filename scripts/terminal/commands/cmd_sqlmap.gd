extends RefCounted

func execute(args: Array, context: Dictionary):
	# sqlmap -u "<url>" --dump
	if not "-u" in args or not "--dump" in args:
		return CommandResult.new("usage: sqlmap -u \"<url>\" --dump", false)
		
	var url = ""
	var idx = args.find("-u")
	if idx >= 0 and idx + 1 < args.size():
		url = args[idx + 1]
		
	var url_clean = url.replace("http://", "").replace("\"", "")
	var ip = url_clean.split("/")[0] if "/" in url_clean else url_clean
	if ":" in ip:
		ip = ip.split(":")[0]
		
	if GameState.get_flag("helix_alert_elevated") and ip in HelixConfig.HELIX_IPS:
		if not GameState.get_flag("helix_warning_shown"):
			if context.has("terminal") and context.terminal:
				context.terminal.print_output("[color=#ff6b35]WARNING: Elevated network monitoring detected on target.[/color]")
			GameState.set_flag("helix_warning_shown", true)
		
	var m = NetworkManager.get_machine(ip)
	if not m or not m.is_scanned:
		return CommandResult.new("[CRITICAL] target seems down", false)
		
	if m.cloak_cooldown > 0.0:
		return CommandResult.new("[color=#ffaa00][!] phantom cooldown active - target flagged, re-engage in %d seconds[/color]" % round(m.cloak_cooldown), false)
		
	if m.is_locked:
		return CommandResult.new("[!] service locked - try again in %d seconds" % round(m.lockout_timer), false)
		
	var target_port = null
	for p in m.ports:
		if p.port_number == 80 and p.is_open and p.exploit_type == "sqli":
			target_port = p
			break
			
	if not target_port:
		m.failed_attempts += 1
		CountermeasureManager.check(m)
		return CommandResult.new("[CRITICAL] all tested parameters do not appear to be injectable", false)

	if context.has("terminal"):
		context.terminal.print_output("[INFO] testing connection to the target URL")
		await context.terminal.get_tree().create_timer(0.5).timeout
		context.terminal.print_output("[INFO] testing if the target URL content is stable")
		await context.terminal.get_tree().create_timer(0.5).timeout
		context.terminal.print_output("[INFO] GET parameter 'id' appears to be 'AND boolean-based blind' injectable")
		await context.terminal.get_tree().create_timer(0.5).timeout
		context.terminal.print_output("[INFO] the back-end DBMS is MySQL")
		await context.terminal.get_tree().create_timer(0.5).timeout
		
		context.terminal.print_output("[INFO] fetching data...")
		await context.terminal.get_tree().create_timer(0.5).timeout
		
		# Return dump from path
		if m.db_dump_path != "":
			var temp_nav = FilesystemNavigator.new()
			temp_nav.set_machine(m)
			var dump_node = temp_nav.get_file(m.db_dump_path)
			if dump_node and dump_node.type == FileNode.FILE:
				return CommandResult.new("[color=#00ff41]Database dump:[/color]\n" + dump_node.content, true)
				
		return CommandResult.new("[WARNING] tables found but dump failed", false)

	return CommandResult.new("Error", false)
