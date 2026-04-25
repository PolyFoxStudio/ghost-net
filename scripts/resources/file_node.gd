class_name FileNode
extends Resource

const FILE = 0
const DIRECTORY = 1

@export var name: String
@export var type: int = FILE # 0 = FILE, 1 = DIRECTORY
@export var content: String = "" # readable text content, empty for directories
@export var children: Array[FileNode] = [] # only populated for directories
@export var is_hidden: bool = false # hidden files shown with ls -la but not ls
@export var permissions: String = "rwxr-xr-x" # cosmetic only
@export var is_tripwire: bool = false # If player runs cat on this, trigger Tier 3

func add_child(node: FileNode) -> void:
	if type == DIRECTORY:
		children.append(node)
