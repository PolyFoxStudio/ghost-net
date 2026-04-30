extends RefCounted

func execute(args: Array, context: Dictionary):
	if args.size() == 0:
		return CommandResult.new("nmap: missing arguments", false)
	
	var ip = args[args.size() - 1]
	
	if "-sn" in args:
		if context.has("terminal"):
			await context.terminal.get_tree().create_timer(1.5).timeout
			
		var out = "Starting Nmap scan...\n"
		var count = 0
		for m in NetworkManager._machines.values():
			if m.network_zone != "local" and m.network_zone == "public":
				m.is_discovered = true
				out += "Nmap scan report for " + m.hostname + " (" + m.ip + ")\nHost is up.\n"
				count += 1
		out += "\nNmap done: " + str(count) + " hosts up."
		return CommandResult.new(out)
		
	if "-sV" in args:
		if context.has("terminal"):
			await context.terminal.get_tree().create_timer(2.5).timeout
			
		var m = NetworkManager.get_machine(ip)
		if not m or not m.is_discovered:
			return CommandResult.new("Note: Host seems down. If it is really up, but blocking our probes, try -Pn")
			
		m.is_scanned = true
		var out2 = "Starting Nmap scan...\n\n"
		out2 += "Nmap scan report for %s (%s)\n" % [m.hostname, m.ip]
		out2 += "Host is up (0.0021s latency).\n\n"
		out2 += "PORT     STATE  SERVICE  VERSION\n"
		for port in m.ports:
			var port_str = str(port.port_number) + "/" + port.protocol
			var state = "open" if port.is_open else "closed"
			var service = port.service
			var version = port.version
			out2 += "%-8s %-6s %-8s %s\n" % [port_str, state, service, version]
			
		out2 += "\nNmap done: 1 IP address (1 host up) scanned in 2.48 seconds"
		return CommandResult.new(out2)
		
	return CommandResult.new("nmap: unrecognised flag. Try nmap -sn <target> or nmap -sV <target>", false)
