extends RefCounted

func execute(args: Array, context: Dictionary):
	if args.size() < 1:
		return CommandResult.new("usage: ftp <ip>", false)
		
	var ip = args[0]
	var m = NetworkManager.get_machine(ip)
	if not m or not m.is_scanned:
		return CommandResult.new("ftp: connect: Connection refused", false)
		
	if m.cloak_cooldown > 0.0:
		return CommandResult.new("[color=#ffaa00][!] phantom cooldown active - target flagged, re-engage in %d seconds[/color]" % round(m.cloak_cooldown), false)
		
	if m.is_locked:
		return CommandResult.new("[!] service locked - try again in %d seconds" % round(m.lockout_timer), false)
		
	var port21 = null
	for p in m.ports:
		if p.port_number == 21 and p.is_open:
			port21 = p
			break
			
	if not port21:
		return CommandResult.new("ftp: connect: Connection refused", false)
		
	if port21.exploit_type == "anonymous":
		if context.has("terminal"):
			context.terminal.print_output("Connected to " + ip + ".")
			context.terminal.print_output("220 (vsFTPd 3.0.3)")
			context.terminal.print_output("Name (" + ip + ":ghost): anonymous")
			context.terminal.print_output("331 Please specify the password.")
			context.terminal.print_output("Password:")
			context.terminal.print_output("230 Login successful.")
			
			# Enter FTP mode
			NetworkManager.connect_to_machine(ip)
			context.terminal.navigator.set_machine(m)
			context.terminal.enter_ftp_mode()
			return CommandResult.new("", true)
	else:
		if context.has("terminal"):
			context.terminal.print_output("Connected to " + ip + ".")
			context.terminal.print_output("220 FTP server ready.")
			var user = await context.terminal.request_input("Name (" + ip + ":ghost): ")
			var password = await context.terminal.request_password("Password: ")
			
			var auth_ok = false
			for cred in m.credentials:
				if cred.username == user and cred.password == password:
					auth_ok = true
					break
					
			if auth_ok:
				NetworkManager.connect_to_machine(ip)
				context.terminal.navigator.set_machine(m)
				context.terminal.enter_ftp_mode()
				return CommandResult.new("230 Login successful.", true)
			else:
				m.failed_attempts += 1
				CountermeasureManager.check(m)
				return CommandResult.new("530 Login incorrect.", false)
				
	return CommandResult.new("Error", false)
