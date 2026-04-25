class_name CommandRegistry
extends RefCounted

var commands: Dictionary = {}

func register_command(name: String, script_path: String) -> void:
	var script = load(script_path)
	if script:
		commands[name] = script.new()

func _init():
	register_command("help", "res://scripts/terminal/commands/cmd_help.gd")
	register_command("clear", "res://scripts/terminal/commands/cmd_clear.gd")
	register_command("whoami", "res://scripts/terminal/commands/cmd_whoami.gd")
	register_command("hostname", "res://scripts/terminal/commands/cmd_hostname.gd")
	register_command("ifconfig", "res://scripts/terminal/commands/cmd_ifconfig.gd")
	register_command("ip", "res://scripts/terminal/commands/cmd_ifconfig.gd")
	register_command("nmap", "res://scripts/terminal/commands/cmd_nmap.gd")
	register_command("ssh", "res://scripts/terminal/commands/cmd_ssh.gd")
	register_command("ftp", "res://scripts/terminal/commands/cmd_ftp.gd")
	register_command("disconnect", "res://scripts/terminal/commands/cmd_disconnect.gd")
	register_command("ls", "res://scripts/terminal/commands/cmd_ls.gd")
	register_command("cd", "res://scripts/terminal/commands/cmd_cd.gd")
	register_command("cat", "res://scripts/terminal/commands/cmd_cat.gd")
	register_command("grep", "res://scripts/terminal/commands/cmd_grep.gd")
	register_command("find", "res://scripts/terminal/commands/cmd_find.gd")
	register_command("download", "res://scripts/terminal/commands/cmd_download.gd")
	register_command("hydra", "res://scripts/terminal/commands/cmd_hydra.gd")
	register_command("sqlmap", "res://scripts/terminal/commands/cmd_sqlmap.gd")
	register_command("phantom", "res://scripts/terminal/commands/cmd_phantom.gd")

func execute(command_name: String, args: Array, context: Dictionary) -> CommandResult:
	if commands.has(command_name):
		return await commands[command_name].execute(args, context)
	return CommandResult.new("%s: command not found" % command_name, false)
