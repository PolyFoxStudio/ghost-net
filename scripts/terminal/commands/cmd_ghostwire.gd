extends RefCounted

func execute(args: Array, context: Dictionary) -> CommandResult:
	if args.is_empty() or args[0] == "--help":
		var out = """ghostwire v1.2 — by Cipher
Usage: ghostwire --spoof [identity] --target [platform/system]

Available identities:
  employee_sarah_chen     — Junior Data Analyst, Helix Solutions
  contractor_lee_morgan   — IT Contractor, Helix Solutions

// built for ghost. use it well. — c"""
		return CommandResult.new(out, true)

	var identity = ""
	var target = ""
	var i = 0
	while i < args.size():
		if args[i] == "--spoof" and i + 1 < args.size():
			identity = args[i + 1]
			i += 2
		elif args[i] == "--target" and i + 1 < args.size():
			target = args[i + 1]
			i += 2
		else:
			i += 1

	if identity == "":
		return CommandResult.new("ghostwire: missing --spoof [identity]", false)

	var out = ""
	if "sarah" in identity.to_lower() or "sarah_chen" in identity.to_lower():
		out = """ghostwire v1.2 — by Cipher
[*] Loading identity: employee_sarah_chen
    Name:        Sarah Chen  |  Role: Junior Data Analyst
    Employee ID: HX-4471     |  Email: s.chen@helixsolutions.com

[OK] Identity active. You are now Sarah Chen.
[!] Identity integrity: 94%% — avoid direct video/voice contact
[!] "she's been out sick for 2 weeks. nobody'll notice. you're welcome." — cipher"""
		return CommandResult.new(out, true)

	if "lee" in identity.to_lower() or "morgan" in identity.to_lower():
		out = """ghostwire v1.2 — by Cipher
[*] Loading identity: contractor_lee_morgan
    Name:        Lee Morgan  |  Role: IT Contractor
    Contractor ID: EXT-0293  |  Email: l.morgan.ext@helixsolutions.com

[OK] Identity active. You are now Lee Morgan.
[!] Identity integrity: 88%% — contractor access is limited to IT systems only"""
		return CommandResult.new(out, true)

	return CommandResult.new("ghostwire: unknown identity '%s'\nRun ghostwire --help to list available identities." % identity, false)
