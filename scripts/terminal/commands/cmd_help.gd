extends RefCounted

func execute(args: Array, context: Dictionary) -> CommandResult:
	var output = ""

	output += "SYSTEM\n"
	output += "  help           — show this help message\n"
	output += "  clear          — clear terminal output\n"
	output += "  whoami         — print current user\n"
	output += "  hostname       — show system hostname\n"
	output += "  ifconfig       — show network interfaces\n"
	output += "  uname          — system information\n"
	output += "  history        — show command history\n"
	output += "  echo           — print text to terminal\n"

	output += "\nFILESYSTEM\n"
	output += "  ls             — list directory contents\n"
	output += "  cd             — change directory\n"
	output += "  pwd            — print working directory\n"
	output += "  cat            — print file contents\n"
	output += "  grep           — search within files\n"
	output += "  find           — search for files\n"
	output += "  mkdir          — create directory\n"
	output += "  touch          — create empty file\n"
	output += "  rm             — remove file or directory\n"
	output += "  cp             — copy file\n"
	output += "  mv             — move or rename file\n"
	output += "  head           — print first lines of file\n"
	output += "  tail           — print last lines of file\n"
	output += "  zip            — package folder into archive\n"

	output += "\nNETWORK\n"
	output += "  nmap           — network scanner and port mapper\n"
	output += "  ssh            — remote login client\n"
	output += "  ftp            — file transfer protocol client\n"
	output += "  netstat        — show active network connections\n"
	output += "  traceroute     — trace network route to host\n"
	output += "  disconnect     — close current session\n"
	output += "  download       — download file to evidence folder\n"

	output += "\nINVESTIGATION\n"
	output += "  whois          — domain registration lookup\n"
	output += "  theHarvester   — email, subdomain and IP harvester\n"
	output += "  sherlock       — username search across platforms\n"
	output += "  wayback        — retrieve cached web pages\n"
	output += "  maltego        — visual entity relationship mapper\n"

	output += "\nEXPLOITATION\n"
	output += "  hydra          — network login brute-forcer\n"
	output += "  sqlmap         — SQL injection tool\n"
	output += "  metasploit     — remote code execution framework\n"

	output += "\nANONYMITY\n"
	output += "  proxychains    — route traffic through proxy chain\n"
	output += "  tor            — Tor daemon toggle (--start / --stop)\n"
	output += "  bleachbit      — wipe logs and clear traces\n"

	output += "\nCIPHER'S TOOLS\n"
	output += "  phantom        — trace, wipe, ping, cloak, map\n"
	output += "  ghostwire      — identity spoofing\n"
	output += "  deadrop        — secure untraceable file transfer\n"
	output += "  compile        — build evidence dossier\n"

	output += "\nCOMMUNICATION\n"
	output += "  plink          — PhantomLink CLI (--msg / --recv / --status)\n"

	return CommandResult.new(output, true)
