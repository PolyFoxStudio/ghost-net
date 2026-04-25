extends RefCounted

func execute(args: Array, context: Dictionary):
	# hydra -l <username> -P <wordlist_path> <protocol>://<ip>
	if args.size() < 5:
		return CommandResult.new("usage: hydra -l <username> -P <wordlist_path> <protocol>://<ip>", false)
		
	var username = ""
	var wordlist_path = ""
	var target_url = ""
	
	var i = 0
	while i < args.size():
		if args[i] == "-l":
			username = args[i+1]
			i += 1
		elif args[i] == "-P":
			wordlist_path = args[i+1]
			i += 1
		elif "://" in args[i]:
			target_url = args[i]
		i += 1
		
	var local_nav = FilesystemNavigator.new()
	local_nav.set_machine(NetworkManager.get_local_machine())
	var wordlist_file = local_nav.get_file(wordlist_path)
	
	if not wordlist_file or wordlist_file.type != FileNode.FILE:
		return CommandResult.new("hydra: wordlist not found: %s" % wordlist_path, false)
		
	var url_parts = target_url.split("://")
	var protocol = url_parts[0]
	var ip = url_parts[1].split(":")[0] if ":" in url_parts[1] else url_parts[1].split("/")[0]
	
	var m = NetworkManager.get_machine(ip)
	if not m or not m.is_scanned:
		return CommandResult.new("[ERROR] target %s seems down" % ip, false)
		
	if m.cloak_cooldown > 0.0:
		return CommandResult.new("[color=#ffaa00][!] phantom cooldown active - target flagged, re-engage in %d seconds[/color]" % round(m.cloak_cooldown), false)
		
	if m.is_locked:
		return CommandResult.new("[!] service locked - try again in %d seconds" % round(m.lockout_timer), false)
		
	var target_port = null
	for p in m.ports:
		if p.service == protocol and p.is_open and p.exploit_type == "bruteforce":
			target_port = p
			break
			
	if not target_port:
		return CommandResult.new("[ERROR] port for %s is closed or not vulnerable" % protocol, false)

	if context.has("terminal"):
		context.terminal.print_output("[DATA] attacking %s" % target_url)
		
		# Simulated brute force
		var words = wordlist_file.content.split("\n", false)
		var total = words.size()
		var attempt = 1
		
		var match_found = false
		var correct_cred = null
		
		for w in words:
			var pwd = w.strip_edges()
			if attempt <= 3 or attempt == total:
				context.terminal.print_output("[ATTEMPT] target %s - login \"%s\" - pass \"%s\" - %d of %d" % [ip, username, pwd, attempt, total])
			elif attempt == 4:
				context.terminal.print_output("...")
			
			for cred in m.credentials:
				if cred.username == username and cred.password == pwd:
					match_found = true
					correct_cred = cred
					break
			
			if match_found:
				break
				
			attempt += 1
			if attempt % 100 == 0:
				await context.terminal.get_tree().create_timer(0.1).timeout
				
		await context.terminal.get_tree().create_timer(1.0).timeout
		
		if match_found:
			correct_cred.is_discovered = true
			GlobalSignals.credential_found.emit(username, correct_cred.password, ip)
			var success_msg = "[color=#00ff41][%s][%s] host: %s   login: %s   password: %s[/color]\n1 valid password found." % [str(target_port.port_number), protocol, ip, username, correct_cred.password]
			return CommandResult.new(success_msg, true)
		else:
			m.failed_attempts += 1
			CountermeasureManager.check(m)
			return CommandResult.new("0 valid passwords found.", false)
			
	return CommandResult.new("Error: no terminal context", false)
