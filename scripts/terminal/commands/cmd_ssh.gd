extends RefCounted

func execute(args: Array, context: Dictionary):
	if args.size() < 1:
		return CommandResult.new("usage: ssh user@ip", false)
		
	var target = args[0]
	var parts = target.split("@")
	if parts.size() != 2:
		return CommandResult.new("usage: ssh user@ip", false)
		
	var user = parts[0]
	var ip = parts[1]
	
	var m = NetworkManager.get_machine(ip)
	if not m or not m.is_scanned:
		return CommandResult.new("[simulated error] ssh: connect to host %s port 22: Connection refused" % ip, false)
		
	if m.cloak_cooldown > 0.0:
		return CommandResult.new("[color=#ffaa00][!] phantom cooldown active - target flagged, re-engage in %d seconds[/color]" % round(m.cloak_cooldown), false)
		
	if m.is_locked:
		return CommandResult.new("[!] service locked - try again in %d seconds" % round(m.lockout_timer), false)
		
	var port22 = null
	for p in m.ports:
		if p.port_number == 22 and p.is_open:
			port22 = p
			break
			
	if not port22:
		return CommandResult.new("[simulated error] ssh: connect to host %s port 22: Connection refused" % ip, false)
		
	if context.has("terminal"):
		var password = await context.terminal.request_password(user + "@" + ip + "'s password: ")
		
		# Simulated delay
		await context.terminal.get_tree().create_timer(0.8).timeout
		
		var auth_ok = false
		for cred in m.credentials:
			if cred.username == user and cred.password == password:
				auth_ok = true
				break
				
		if auth_ok:
			NetworkManager.connect_to_machine(ip)
			context.terminal.navigator.set_machine(m)
			var motd = "Welcome to %s (%s)\n\n" % [m.hostname, m.os]
			motd += "Last login: %s from 10.0.0.x" % Time.get_datetime_string_from_system()
			return CommandResult.new(motd, true)
		else:
			m.failed_attempts += 1
			CountermeasureManager.check(m)
			return CommandResult.new("Permission denied (publickey,password).", false)
			
	return CommandResult.new("Error: no terminal context", false)
