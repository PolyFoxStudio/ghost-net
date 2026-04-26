extends RefCounted

func execute(args: Array, context: Dictionary) -> CommandResult:
    if args.is_empty():
        return CommandResult.new("proxychains: missing command\nUsage: proxychains [command] [args]", false)

    var chained_command = args[0]
    var chained_args = args.slice(1)

    if context.has("terminal"):
        context.terminal.print_output("[proxychains] Dynamic chain: GhostNet → TOR → NL-EXIT → DE-RELAY → target")
        context.terminal.print_output("[proxychains] Active. Proceeding with command...")
        await context.terminal.get_tree().create_timer(0.6).timeout

    var registry = context.terminal.command_registry
    if registry.commands.has(chained_command):
        return await registry.commands[chained_command].execute(chained_args, context)

    return CommandResult.new("proxychains: '%s': command not found" % chained_command, false)