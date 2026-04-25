class_name MachineResource
extends Resource

@export var ip: String # e.g. "192.168.4.12"
@export var hostname: String # e.g. "HELIX-SRV-01"
@export var os: String # e.g. "Linux Ubuntu 20.04"
@export var network_zone: String = "public" # "local", "public", "internal"
@export var ports: Array[PortResource] = []
@export var filesystem: FileNode # root node of the filesystem tree
@export var credentials: Array[CredentialResource] = [] # valid on this machine
@export var db_dump_path: String = "" # for sqlmap --dump

# State flags
@export var is_discovered: bool = false
@export var is_scanned: bool = false
@export var is_player_connected: bool = false
@export var is_locked: bool = false # true when countermeasure tier 2 is active
@export var is_traced: bool = false # true when countermeasure tier 3 is active

# Countermeasure tracking
@export var failed_attempts: int = 0
@export var lockout_timer: float = 0.0 # seconds remaining on lockout
@export var trace_progress: float = 0.0 # 0.0 to 1.0
@export var cloak_cooldown: float = 0.0 # cooldown timer for phantom cloak
