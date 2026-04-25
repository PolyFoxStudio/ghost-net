extends RefCounted

func execute(args: Array, context: Dictionary) -> CommandResult:
	var machine = NetworkManager.get_local_machine()
	var out = "eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500\n"
	if machine:
		out += "        inet " + machine.ip + "  netmask 255.255.255.0  broadcast 192.168.255.255\n"
	else:
		out += "        inet 127.0.0.1  netmask 255.0.0.0\n"
	out += "        ether 00:1a:2b:3c:4d:5e  txqueuelen 1000  (Ethernet)"
	return CommandResult.new(out)
