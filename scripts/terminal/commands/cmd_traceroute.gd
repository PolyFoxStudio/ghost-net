extends RefCounted

func execute(args: Array, context: Dictionary) -> CommandResult:
    if args.is_empty():
        return CommandResult.new("traceroute: missing target", false)
    var target = args[0]

    if "helixsolutions" in target or "185.220.101" in target:
        var out = """traceroute to 185.220.101.47, 30 hops max
 1  10.0.0.1         1.2ms
 2  tor-exit-node    14.7ms  [proxychains active]
 3  185.99.44.12     31.2ms  Amsterdam, NL
 4  185.220.101.1    44.8ms  ShieldHost LLC
 5  185.220.101.47   45.1ms  [internal.helixsolutions.com]

[*] Traffic routed through ShieldHost LLC (offshore hosting)
[!] Non-standard routing for a domestic company. Deliberate obfuscation likely."""
        return CommandResult.new(out, true)

    var out = """traceroute to %s, 30 hops max
 1  10.0.0.1         1.1ms
 2  94.45.12.1       8.3ms
 3  172.16.254.2     12.7ms
 4  * * *
 5  * * *

[*] Route incomplete — host unreachable or blocking ICMP.""" % target
    return CommandResult.new(out, true)