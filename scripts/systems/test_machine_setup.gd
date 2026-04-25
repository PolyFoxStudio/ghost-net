extends Node

func _ready() -> void:
	setup()

func setup() -> void:
	var m = MachineResource.new()
	m.ip = "10.0.0.1"
	m.hostname = "TEST-SRV"
	m.os = "Linux Ubuntu 20.04"
	m.network_zone = "public"
	
	var port22 = PortResource.new()
	port22.port_number = 22
	port22.protocol = "tcp"
	port22.service = "ssh"
	port22.version = "OpenSSH 8.2"
	port22.is_open = true
	port22.exploit_type = "bruteforce"
	
	var port80 = PortResource.new()
	port80.port_number = 80
	port80.protocol = "tcp"
	port80.service = "http"
	port80.version = "Apache 2.4.41"
	port80.is_open = true
	port80.exploit_type = "sqli"
	
	m.ports.append(port22)
	m.ports.append(port80)
	
	var cred = CredentialResource.new()
	cred.username = "admin"
	cred.password = "password123"
	cred.source_machine = "TEST-SRV"
	cred.source_path = ""
	cred.is_discovered = false
	
	m.credentials.append(cred)
	
	# Filesystem
	var root = FileNode.new()
	root.name = "root"
	root.type = FileNode.DIRECTORY
	
	var etc = FileNode.new()
	etc.name = "etc"
	etc.type = FileNode.DIRECTORY
	var passwd = FileNode.new()
	passwd.name = "passwd"
	passwd.type = FileNode.FILE
	passwd.content = "root:x:0:0:root:/root:/bin/bash\nadmin:x:1000:1000:admin,,,:/home/admin:/bin/bash\n"
	etc.add_child(passwd)
	
	var var_dir = FileNode.new()
	var_dir.name = "var"
	var_dir.type = FileNode.DIRECTORY
	var www = FileNode.new()
	www.name = "www"
	www.type = FileNode.DIRECTORY
	var html = FileNode.new()
	html.name = "html"
	html.type = FileNode.DIRECTORY
	
	var index = FileNode.new()
	index.name = "index.html"
	index.type = FileNode.FILE
	index.content = "<html><body><h1>Welcome to TEST-SRV</h1></body></html>"
	
	var config = FileNode.new()
	config.name = "config.php"
	config.type = FileNode.FILE
	config.content = "<?php\n$db_user = 'admin';\n$db_pass = 'password123';\n?>"
	
	html.add_child(index)
	html.add_child(config)
	www.add_child(html)
	var_dir.add_child(www)
	
	var home = FileNode.new()
	home.name = "home"
	home.type = FileNode.DIRECTORY
	var admin = FileNode.new()
	admin.name = "admin"
	admin.type = FileNode.DIRECTORY
	
	var bash_hist = FileNode.new()
	bash_hist.name = ".bash_history"
	bash_hist.type = FileNode.FILE
	bash_hist.is_hidden = true
	bash_hist.content = "ls -la\ncd /var/www/html\nnano config.php\n"
	
	var notes = FileNode.new()
	notes.name = "notes.txt"
	notes.type = FileNode.FILE
	notes.content = "Don't forget the admin portal is at /admin. Login is same as ssh.\n"
	
	admin.add_child(bash_hist)
	admin.add_child(notes)
	home.add_child(admin)
	
	root.add_child(etc)
	root.add_child(var_dir)
	root.add_child(home)
	
	m.filesystem = root
	m.db_dump_path = "/var/www/html/config.php" # just for testing sqlmap
	
	NetworkManager.register_machine(m)
