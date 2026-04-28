extends RefCounted

func execute(args: Array, context: Dictionary) -> CommandResult:
	var domain = ""
	var i = 0
	while i < args.size():
		if args[i] == "-d" and i + 1 < args.size():
			domain = args[i + 1]
			i += 2
		else:
			i += 1
	if domain == "":
		return CommandResult.new("theHarvester: missing -d [domain]", false)
	if "helixsolutions.com" in domain:
		var out = """[*] Searching across all sources...
[*] Emails found:
    d.kane@helixsolutions.com
    hr@helixsolutions.com
    n.webb@helixsolutions.com
    support@helixsolutions.com

[*] Subdomains found:
    mail.helixsolutions.com
    vpn.helixsolutions.com
    internal.helixsolutions.com
    archive.helixsolutions.com

[*] IPs found:
    185.220.101.47
    185.220.101.48

[!] internal.helixsolutions.com — not publicly indexed. Possible intranet portal."""
		GlobalSignals.senet_unlocked.emit()
		return CommandResult.new(out, true)
	return CommandResult.new("[*] Searching across all sources...\n[*] No results found for '%s'" % domain, false)
