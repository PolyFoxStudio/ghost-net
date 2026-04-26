extends RefCounted

func execute(args: Array, context: Dictionary) -> CommandResult:
	if args.is_empty():
		return CommandResult.new("sherlock: missing username", false)
	var username = args[0]
	if "nadia" in username.to_lower():
		var out = """[*] Checking 320 platforms for: %s
[+] Twitter/X:    https://x.com/nadia_webb [ACTIVE]
[+] LinkedIn:     https://linkedin.com/in/nadia-webb [ACTIVE]
[+] Reddit:       https://reddit.com/user/nadia_webb [ACTIVE]
[-] Instagram:    not found
[-] GitHub:       not found
[+] DataLeakDB:   record found — breach: CreditFlow 2023

[!] Reddit account: last post 47 days ago. Sudden stop.""" % username
		return CommandResult.new(out, true)
	return CommandResult.new("[*] Checking 320 platforms for: %s\n[*] No accounts found." % username, false)
