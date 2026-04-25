extends Node

func _ready() -> void:
	setup()

func setup() -> void:
	# Local machine
	var m = MachineResource.new()
	m.ip = "127.0.0.1"
	m.hostname = "local"
	m.os = "GhostNet v2.3.1"
	m.network_zone = "local"
	m.is_discovered = true
	m.is_scanned = true
	m.is_player_connected = true
	
	var root = FileNode.new()
	root.name = "root"
	root.type = FileNode.DIRECTORY
	
	var home = _make_dir("home")
	var ghost = _make_dir("ghost")
	var bash_hist = _make_file(".bash_history", "")
	bash_hist.is_hidden = true
	ghost.add_child(bash_hist)
	home.add_child(ghost)
	
	var tools = _make_dir("tools")
	var wordlists = _make_dir("wordlists")
	
	var common_txt = _make_file("common.txt", _get_common_passwords())
	var usernames_txt = _make_file("usernames.txt", _get_usernames())
	wordlists.add_child(common_txt)
	wordlists.add_child(usernames_txt)
	
	var phantom = _make_dir("phantom")
	tools.add_child(wordlists)
	tools.add_child(phantom)
	
	var evidence = _make_dir("evidence")
	
	var logs = _make_dir("logs")
	var session_log = _make_file("session.log", "")
	session_log.is_hidden = true
	logs.add_child(session_log)
	
	root.add_child(home)
	root.add_child(tools)
	root.add_child(evidence)
	root.add_child(logs)
	
	m.filesystem = root
	
	NetworkManager.register_machine(m)
	
	# Create wordlists on disk as well if needed? The prompt says "populate local filesystem with wordlist files"
	# It likely means in the FileNode structure. Let's write them to actual res://data/wordlists too.
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("data"):
		dir.make_dir("data")
		
	var data_dir = DirAccess.open("res://data")
	if not data_dir.dir_exists("wordlists"):
		data_dir.make_dir("wordlists")
		
	var f1 = FileAccess.open("res://data/wordlists/common.txt", FileAccess.WRITE)
	f1.store_string(_get_common_passwords())
	f1.close()
	
	var f2 = FileAccess.open("res://data/wordlists/usernames.txt", FileAccess.WRITE)
	f2.store_string(_get_usernames())
	f2.close()

func _make_dir(dir_name: String) -> FileNode:
	var d = FileNode.new()
	d.name = dir_name
	d.type = FileNode.DIRECTORY
	return d

func _make_file(file_name: String, content: String) -> FileNode:
	var f = FileNode.new()
	f.name = file_name
	f.type = FileNode.FILE
	f.content = content
	return f

func _get_common_passwords() -> String:
	return "123456\npassword\n12345678\nqwerty\n123456789\n12345\n1234\n111111\n1234567\ndragon\n123123\nbaseball\nmonkey\nletmein\nadmin\npassword123\nwelcome\nwelcome1\nadmin123\nshadow\ntrustno1\nflower\nqwertyuiop\n1234567890\nsecret\nhunter2\n12345678910\niloveyou\nprincess\nstarwars\npassword1\n1234567891\n1234567892"

func _get_usernames() -> String:
	return "admin\nroot\nuser\nguest\ninfo\nadministrator\ntest\npostgres\noracle\nmysql\npi\nubuntu\ndebian\ndocker\nvagrant\ncentos\nsysadmin\nsupport\nwebmaster\nservice"
