extends RefCounted

func execute(args: Array, context: Dictionary) -> CommandResult:
	var output = "Available commands:\n"
	output += "  help       - show this help message\n"
	output += "  clear      - clear terminal output\n"
	output += "  whoami     - print effective userid\n"
	output += "  hostname   - show system hostname\n"
	output += "  ifconfig   - show network interface configuration\n"
	output += "  nmap       - network exploration tool and security / port scanner\n"
	output += "  ssh        - OpenSSH remote login client\n"
	output += "  ftp        - Internet file transfer program\n"
	output += "  hydra      - very fast network logon cracker\n"
	output += "  sqlmap     - automatic SQL injection and database takeover tool\n"
	output += "  phantom    - advanced ghostnet tool\n"
	
	if NetworkManager.is_currently_connected() or NetworkManager.get_current_machine() == NetworkManager.get_local_machine():
		output += "\nFilesystem commands:\n"
		output += "  ls         - list directory contents\n"
		output += "  cd         - change directory\n"
		output += "  cat        - concatenate files and print on the standard output\n"
		output += "  grep       - print lines that match patterns\n"
		output += "  find       - search for files in a directory hierarchy\n"
		
	if NetworkManager.is_currently_connected():
		output += "\nSession commands:\n"
		output += "  download   - download file to local evidence folder\n"
		output += "  disconnect - close current connection\n"
		
	return CommandResult.new(output)
