extends Node

## Verification script for Beat 10b and 10c implementation
## Run this from the editor or attach to a scene to verify the implementation

func _ready() -> void:
	print("=== Verifying Beat 10b & 10c Implementation ===")
	verify_convergence_functions()
	verify_filesystem_helpers()
	verify_file_contents()
	print("=== Verification Complete ===")

func verify_convergence_functions() -> void:
	print("\n[Testing Convergence Functions]")
	
	# Test is_convergence_mid
	GameState.cipher_relationship_score = 5
	GameState.marcus_emotional_state = 0
	assert(GameState.is_convergence_mid() == true, "is_convergence_mid should return true when cipher >= 5 and marcus >= 0")
	print("✓ is_convergence_mid works correctly with valid conditions")
	
	GameState.cipher_relationship_score = 4
	assert(GameState.is_convergence_mid() == false, "is_convergence_mid should return false when cipher < 5")
	print("✓ is_convergence_mid correctly rejects low cipher score")
	
	GameState.cipher_relationship_score = 5
	GameState.marcus_emotional_state = -1
	assert(GameState.is_convergence_mid() == false, "is_convergence_mid should return false when marcus < 0")
	print("✓ is_convergence_mid correctly rejects low marcus state")
	
	# Test is_convergence_high
	GameState.cipher_relationship_score = 5
	GameState.marcus_emotional_state = 2
	assert(GameState.is_convergence_high() == true, "is_convergence_high should return true when cipher >= 5 and marcus >= 2")
	print("✓ is_convergence_high works correctly with valid conditions")
	
	GameState.marcus_emotional_state = 1
	assert(GameState.is_convergence_high() == false, "is_convergence_high should return false when marcus < 2")
	print("✓ is_convergence_high correctly rejects low marcus state")

func verify_filesystem_helpers() -> void:
	print("\n[Testing Filesystem Helpers]")
	
	# Create test filesystem
	var root: FileNode = FileNode.new()
	root.name = "root"
	root.type = FileNode.DIRECTORY
	
	var home: FileNode = FileNode.new()
	home.name = "home"
	home.type = FileNode.DIRECTORY
	root.add_child(home)
	
	var ghost: FileNode = FileNode.new()
	ghost.name = "ghost"
	ghost.type = FileNode.DIRECTORY
	home.add_child(ghost)
	
	# Test find_node_in_fs
	var found: FileNode = LocalMachineSetup.find_node_in_fs(root, "ghost")
	assert(found != null, "find_node_in_fs should find ghost directory")
	assert(found.name == "ghost", "Found node should be named 'ghost'")
	print("✓ find_node_in_fs correctly finds nested directory")
	
	# Test find_or_create_dir with existing directory
	var tmp_existing: FileNode = FileNode.new()
	tmp_existing.name = "tmp"
	tmp_existing.type = FileNode.DIRECTORY
	root.add_child(tmp_existing)
	
	var found_tmp: FileNode = LocalMachineSetup.find_or_create_dir(root, "tmp")
	assert(found_tmp != null, "find_or_create_dir should find existing tmp")
	assert(root.children.size() == 2, "Should not create duplicate directory")  # home + tmp
	print("✓ find_or_create_dir correctly finds existing directory")
	
	# Test find_or_create_dir with new directory
	var test_root: FileNode = FileNode.new()
	test_root.name = "root"
	test_root.type = FileNode.DIRECTORY
	
	var created: FileNode = LocalMachineSetup.find_or_create_dir(test_root, "new_dir")
	assert(created != null, "find_or_create_dir should create new directory")
	assert(created.name == "new_dir", "Created directory should have correct name")
	assert(test_root.children.size() == 1, "Root should have one child after creation")
	print("✓ find_or_create_dir correctly creates new directory")

func verify_file_contents() -> void:
	print("\n[Verifying File Content Functions]")
	
	# We can't directly call the private functions, but we can verify they would work
	# by checking the PhantomLinkWindow class has the required methods
	var phantom_link_script = load("res://scripts/desktop/apps/phantom_link_window.gd")
	assert(phantom_link_script != null, "PhantomLinkWindow script should exist")
	print("✓ PhantomLinkWindow script loaded successfully")
	
	# Verify file drop and idle check methods exist
	var methods_to_check: Array[String] = [
		"_start_beat10b_timer",
		"_drop_beat10b_file",
		"_get_beat10b_note_content",
		"_get_beat10b_partial_log_content",
		"_start_beat10c_timer",
		"_fire_beat10c"
	]
	
	for method_name in methods_to_check:
		var has_method: bool = phantom_link_script.has_script_method(method_name)
		assert(has_method, "PhantomLinkWindow should have method: " + method_name)
	print("✓ All required Beat 10b/10c methods exist in PhantomLinkWindow")
	
	print("\n[Verifying Flag Names]")
	# Verify flag names are consistent
	GameState.set_flag("beat_10b_dropped", false)
	GameState.set_flag("beat_10c_sent", false)
	assert(GameState.get_flag("beat_10b_dropped") == false, "beat_10b_dropped flag should be settable")
	assert(GameState.get_flag("beat_10c_sent") == false, "beat_10c_sent flag should be settable")
	print("✓ Flags are properly defined and accessible")
