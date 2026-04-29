extends RefCounted

func execute(_args: Array, _context: Dictionary) -> CommandResult:
	var machine = NetworkManager.get_current_machine()
	if not machine or machine.hostname == "localhost":
		var out = """Active connections on: localhost

Proto  Local Address       Foreign Address     State
TCP    127.0.0.1:22        0.0.0.0:*           LISTEN
TCP    127.0.0.1:80        0.0.0.0:*           LISTEN"""
		return CommandResult.new(out, true)
	if "HELIX" in machine.hostname.to_upper() or "archive" in machine.hostname.to_lower():
		var out = """Active connections on: %s

Proto  Local Address              Foreign Address            State
TCP    185.220.101.48:443         203.44.12.9:51204          ESTABLISHED
TCP    185.220.101.48:3306        185.220.101.47:49812       ESTABLISHED
TCP    185.220.101.48:22          [GHOST SESSION]            ESTABLISHED

[!] 203.44.12.9 — unrecognised external connection. Not Helix infrastructure.
[!] Reverse lookup: 203.44.12.9 resolves to vaultpay-offshore.net""" % machine.hostname
		return CommandResult.new(out, true)
	return CommandResult.new("Active connections on: %s\n\nNo active connections." % machine.hostname, true)
