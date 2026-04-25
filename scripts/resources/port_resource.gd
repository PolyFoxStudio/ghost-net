class_name PortResource
extends Resource

@export var port_number: int
@export var protocol: String = "tcp" # "tcp" or "udp"
@export var service: String # e.g. "ssh", "http", "ftp", "mysql"
@export var version: String # e.g. "OpenSSH 8.2", "Apache 2.4.41"
@export var is_open: bool = true
@export var exploit_type: String = "none" # "bruteforce", "sqli", "anonymous", "rce", "none"
