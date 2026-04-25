extends Node

# Autoload for managing machines
var _machines: Dictionary = {} # ip -> MachineResource
var _current_machine: MachineResource = null
var _local_machine: MachineResource = null

func _ready() -> void:
	pass

func register_machine(machine: MachineResource) -> void:
	_machines[machine.ip] = machine
	if machine.network_zone == "local":
		_local_machine = machine

func get_machine(ip: String) -> MachineResource:
	if _machines.has(ip):
		return _machines[ip]
	return null

func get_all_discovered() -> Array[MachineResource]:
	var discovered: Array[MachineResource] = []
	var has_public_connected = false
	
	for ip in _machines:
		var m: MachineResource = _machines[ip]
		if m.is_player_connected and m.network_zone == "public":
			has_public_connected = true
			
	for ip in _machines:
		var m: MachineResource = _machines[ip]
		if m.is_discovered:
			# Check if it's internal and we haven't connected to a public machine yet
			if m.network_zone == "internal" and not has_public_connected:
				continue
			discovered.append(m)
			
	return discovered

func connect_to_machine(ip: String) -> bool:
	var machine: MachineResource = get_machine(ip)
	if machine and machine.is_discovered and not machine.is_locked:
		if _current_machine:
			_current_machine.is_player_connected = false
		_current_machine = machine
		_current_machine.is_player_connected = true
		GlobalSignals.machine_connected.emit(_current_machine)
		return true
	return false

func disconnect_current() -> void:
	if _current_machine and _current_machine.network_zone != "local":
		_current_machine.is_player_connected = false
		var prev = _current_machine
		_current_machine = _local_machine
		if _current_machine:
			_current_machine.is_player_connected = true
		GlobalSignals.machine_disconnected.emit(prev)
		if _current_machine:
			GlobalSignals.machine_connected.emit(_current_machine)

func get_current_machine() -> MachineResource:
	return _current_machine

func is_currently_connected() -> bool:
	return _current_machine != null and _current_machine.network_zone != "local"

func get_local_machine() -> MachineResource:
	return _local_machine
