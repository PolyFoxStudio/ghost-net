extends RefCounted

func execute(args: Array, context: Dictionary) -> CommandResult:
    if args.is_empty():
        return CommandResult.new("maltego: missing target\nUsage: maltego [domain/IP]", false)

    var target = args[0]

    if "helixsolutions" in target:
        var out = """[*] Building entity graph for: helixsolutions.com
[*] Resolving connections...

helixsolutions.com
├── d.kane@helixsolutions.com    ──► Director: D. Kane
├── internal.helixsolutions.com  ──► Intranet Portal (auth required)
├── archive.helixsolutions.com   ──► File Archive (auth required)
├── 185.220.101.47               ──► Registered: ShieldHost LLC (offshore)
│                                         ──► Also hosts: vaultpay-offshore.net [!]
└── hr@helixsolutions.com        ──► LinkedIn: 3 current employees listed"""
        return CommandResult.new(out, true)

    if context.has("terminal"):
        context.terminal.print_output("[*] Building entity graph for: %s" % target)
        context.terminal.print_output("[*] Resolving connections...")
        await context.terminal.get_tree().create_timer(1.5).timeout

    return CommandResult.new("[*] No connections found for '%s'" % target, false)