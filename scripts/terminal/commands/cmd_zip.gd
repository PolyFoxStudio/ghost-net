extends RefCounted

func execute(args: Array, context: Dictionary) -> CommandResult:
    if args.size() < 3 or args[0] != "-r":
        return CommandResult.new("zip: usage: zip -r [archive.zip] [folder]", false)

    var archive_name = args[1]
    var source_folder = args[2]

    if context.has("terminal"):
        context.terminal.print_output("  adding: %s/ (stored 0%%)" % source_folder)
        await context.terminal.get_tree().create_timer(0.8).timeout
        context.terminal.print_output("  adding: %s/contents (deflated 74%%)" % source_folder)
        await context.terminal.get_tree().create_timer(0.5).timeout
        context.terminal.print_output("[OK] Archive created: %s" % archive_name)
    return CommandResult.new("", true)