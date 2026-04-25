class_name FilesystemNavigator
extends RefCounted

var current_machine: MachineResource
var current_directory: FileNode
var current_path_stack: Array[String] = []

func set_machine(machine: MachineResource) -> void:
	current_machine = machine
	if machine and machine.filesystem:
		current_directory = machine.filesystem
		current_path_stack = []

func get_current_path() -> String:
	if current_path_stack.is_empty():
		return "/"
	return "/" + "/".join(current_path_stack)

func change_directory(path: String) -> Dictionary:
	if not current_machine or not current_machine.filesystem:
		return {"success": false, "error": "No filesystem found."}
		
	if path == "" or path == "~":
		current_directory = current_machine.filesystem
		current_path_stack = []
		return {"success": true, "error": ""}
		
	var target_node: FileNode
	var new_stack: Array[String]
	
	if path.begins_with("/"):
		target_node = current_machine.filesystem
		new_stack = []
		path = path.substr(1)
	else:
		target_node = current_directory
		new_stack = current_path_stack.duplicate()
		
	if path == "":
		current_directory = target_node
		current_path_stack = new_stack
		return {"success": true, "error": ""}
		
	var parts = path.split("/", false)
	for part in parts:
		if part == ".":
			continue
		elif part == "..":
			if new_stack.size() > 0:
				new_stack.pop_back()
				# Re-navigate from root to build node state
				target_node = current_machine.filesystem
				for s in new_stack:
					target_node = _get_child_dir(target_node, s)
		else:
			var next_node = _get_child_dir(target_node, part)
			if next_node:
				target_node = next_node
				new_stack.append(part)
			else:
				var child = _get_child(target_node, part)
				if child and child.type == FileNode.FILE:
					return {"success": false, "error": "cd: %s: Not a directory" % path}
				return {"success": false, "error": "cd: %s: No such file or directory" % path}
				
	current_directory = target_node
	current_path_stack = new_stack
	return {"success": true, "error": ""}

func _get_child_dir(node: FileNode, dir_name: String) -> FileNode:
	if not node or node.type != FileNode.DIRECTORY:
		return null
	for child in node.children:
		if child.name == dir_name and child.type == FileNode.DIRECTORY:
			return child
	return null

func _get_child(node: FileNode, child_name: String) -> FileNode:
	if not node or node.type != FileNode.DIRECTORY:
		return null
	for child in node.children:
		if child.name == child_name:
			return child
	return null

func list_directory(show_hidden: bool) -> Array[FileNode]:
	if not current_directory: return []
	var result: Array[FileNode] = []
	for child in current_directory.children:
		if not child.is_hidden or show_hidden:
			result.append(child)
	return result

func get_file(name: String) -> FileNode:
	var path_parts = name.split("/")
	if path_parts.size() == 1:
		return _get_child(current_directory, name)
	else:
		# Need to traverse
		var original_dir = current_directory
		var original_stack = current_path_stack.duplicate()
		
		var filename = path_parts[path_parts.size() - 1]
		var dir_path = name.substr(0, name.length() - filename.length() - 1)
		
		var cd_res = change_directory(dir_path)
		var file_node = null
		if cd_res.success:
			file_node = _get_child(current_directory, filename)
			
		# Restore
		current_directory = original_dir
		current_path_stack = original_stack
		
		return file_node

func find_files(pattern: String, search_root: FileNode, current_path: String = "") -> Array:
	var results: Array = []
	if not search_root: return results
	
	if search_root.type == FileNode.FILE:
		if search_root.name.match(pattern):
			results.append({"path": current_path, "node": search_root})
	elif search_root.type == FileNode.DIRECTORY:
		for child in search_root.children:
			var child_path = current_path + "/" + child.name if current_path != "" and current_path != "/" else "/" + child.name
			results.append_array(find_files(pattern, child, child_path))
			
	return results

func grep_files(term: String, search_root: FileNode, current_path: String = "") -> Array:
	var results: Array = []
	if not search_root: return results
	
	if search_root.type == FileNode.FILE:
		var lines = search_root.content.split("\n")
		for i in range(lines.size()):
			if term in lines[i]:
				results.append({"path": current_path, "line_num": i + 1, "line": lines[i]})
	elif search_root.type == FileNode.DIRECTORY:
		for child in search_root.children:
			var child_path = current_path + "/" + child.name if current_path != "" and current_path != "/" else "/" + child.name
			results.append_array(grep_files(term, child, child_path))
			
	return results
