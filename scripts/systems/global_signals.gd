extends Node

signal machine_connected(machine: MachineResource)
signal machine_disconnected(machine: MachineResource)
signal machine_discovered(machine: MachineResource)
signal machine_scanned(machine: MachineResource)

signal tier1_triggered(machine: MachineResource)
signal tier2_triggered(machine: MachineResource)
signal tier3_triggered(machine: MachineResource)
signal trace_updated(machine: MachineResource, progress: float)
signal trace_completed(machine: MachineResource)
signal lockout_expired(machine: MachineResource)
signal cloak_expired(machine: MachineResource)

signal window_minimised(app_name: String)
signal window_restored(app_name: String)
signal window_closed(app_name: String)

signal command_executed(command: String, args: Array)
signal file_downloaded(file_node: FileNode, source_machine: String, source_path: String)
signal credential_found(username: String, password: String, ip: String)
