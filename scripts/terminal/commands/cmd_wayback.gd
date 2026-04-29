extends RefCounted

func execute(args: Array, _context: Dictionary) -> CommandResult:
	if args.is_empty():
		return CommandResult.new("wayback: missing URL", false)
	var url = args[0]
	if "nadia_webb" in url or "nadia-webb" in url:
		var out = """[*] Querying archive index for: reddit.com/user/nadia_webb
[*] Snapshots found: 14
[*] Most recent: 47 days ago

--- CACHED CONTENT ---
Post by u/nadia_webb — 47 days ago
[r/corporatewatch]
"Has anyone else worked for a company where the audit data just... doesn't add up?
 Asking for a friend. (Not asking for a friend.)"
3 upvotes | 1 comment | [DELETED BY USER]
--- END CACHE ---"""
		return CommandResult.new(out, true)
	return CommandResult.new("[*] Querying archive index for: %s\n[*] No snapshots found." % url, false)
