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
	register_command("whois", "res://scripts/terminal/commands/cmd_whois.gd")
	register_command("theHarvester", "res://scripts/terminal/commands/cmd_theharvester.gd")
	register_command("sherlock", "res://scripts/terminal/commands/cmd_sherlock.gd")
	register_command("wayback", "res://scripts/terminal/commands/cmd_wayback.gd")
	register_command("traceroute", "res://scripts/terminal/commands/cmd_traceroute.gd")
	register_command("netstat", "res://scripts/terminal/commands/cmd_netstat.gd")
	register_command("pwd", "res://scripts/terminal/commands/cmd_pwd.gd")
	register_command("ghostwire", "res://scripts/terminal/commands/cmd_ghostwire.gd")
	register_command("deadrop", "res://scripts/terminal/commands/cmd_deadrop.gd")
	register_command("compile", "res://scripts/terminal/commands/cmd_compile.gd")
	register_command("echo", "res://scripts/terminal/commands/cmd_echo.gd")
	register_command("mkdir", "res://scripts/terminal/commands/cmd_mkdir.gd")
	register_command("touch", "res://scripts/terminal/commands/cmd_touch.gd")
	register_command("rm", "res://scripts/terminal/commands/cmd_rm.gd")
	register_command("cp", "res://scripts/terminal/commands/cmd_cp.gd")
	register_command("mv", "res://scripts/terminal/commands/cmd_mv.gd")
	register_command("head", "res://scripts/terminal/commands/cmd_head.gd")
	register_command("tail", "res://scripts/terminal/commands/cmd_tail.gd")
	register_command("uname", "res://scripts/terminal/commands/cmd_uname.gd")
	register_command("history", "res://scripts/terminal/commands/cmd_history.gd")
	register_command("proxychains", "res://scripts/terminal/commands/cmd_proxychains.gd")
	register_command("tor", "res://scripts/terminal/commands/cmd_tor.gd")
	register_command("bleachbit", "res://scripts/terminal/commands/cmd_bleachbit.gd")
	register_command("maltego", "res://scripts/terminal/commands/cmd_maltego.gd")
	register_command("metasploit", "res://scripts/terminal/commands/cmd_metasploit.gd")
	register_command("plink", "res://scripts/terminal/commands/cmd_plink.gd")
	register_command("zip", "res://scripts/terminal/commands/cmd_zip.gd")

func execute(command_name: String, args: Array, context: Dictionary) -> CommandResult:
	if commands.has(command_name):
		return await commands[command_name].execute(args, context)
	return CommandResult.new("%s: command not found" % command_name, false)
