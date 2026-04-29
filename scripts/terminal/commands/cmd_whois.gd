extends RefCounted

func execute(args: Array, _context: Dictionary) -> CommandResult:
	if args.is_empty():
		return CommandResult.new("whois: missing operand", false)
	var target = args[0]
	if "helixsolutions.com" in target:
		var out = """Domain: helixsolutions.com
Registrar: NameShield Inc.
Registered: 2019-03-14
Expires: 2027-03-14
Owner: Helix Solutions Ltd.
Admin Email: admin@helixsolutions.com
Nameservers: ns1.helixsolutions.com
             ns2.helixsolutions.com
Status: clientTransferProhibited

[!] Note: Privacy protection partially active. Admin contact masked."""
		return CommandResult.new(out, true)
	return CommandResult.new("whois: no record found for '%s'" % target, false)
