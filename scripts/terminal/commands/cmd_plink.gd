extends RefCounted

func execute(args: Array, context: Dictionary) -> CommandResult:
    if args.is_empty():
        return CommandResult.new("plink: missing flag\nUsage: plink --msg [contact] \"[message]\" | plink --recv | plink --status [contact]", false)

    var flag = args[0]

    if flag == "--status":
        var contact = args[1].to_lower() if args.size() > 1 else ""
        if contact == "":
            return CommandResult.new("plink: --status requires a contact name", false)
        if contact == "cipher":
            return CommandResult.new("[PHANTOMLINK] cipher: ONLINE\n[*] Last active: now", true)
        if contact == "marcus":
            return CommandResult.new("[PHANTOMLINK] marcus: ONLINE\n[*] Last active: recently", true)
        return CommandResult.new("[PHANTOMLINK] %s: UNKNOWN CONTACT" % contact, false)

    elif flag == "--recv":
        return CommandResult.new("[PHANTOMLINK] No new messages.\n[*] Open PHANTOMLINK from the desktop for full conversation history.", true)

    elif flag == "--msg":
        if args.size() < 3:
            return CommandResult.new("plink: --msg requires a contact and a message\nUsage: plink --msg [contact] \"[message]\"", false)
        var contact = args[1]
        var message = " ".join(args.slice(2)).trim_prefix("\"").trim_suffix("\"")
        return CommandResult.new("[PHANTOMLINK] Message sent to %s:\n\"%s\"" % [contact, message], true)

    return CommandResult.new("plink: unknown flag '%s'\nUsage: plink --msg | --recv | --status" % flag, false)