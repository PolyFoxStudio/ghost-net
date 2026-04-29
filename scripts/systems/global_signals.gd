extends Node

signal senet_unlocked

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

signal tor_state_changed(is_active: bool)
signal phantomlink_message(sender: String, message: String)
signal phantomlink_message_received(thread: String, beat_id: String)
signal phantomlink_beat_trigger(beat_id: String)
signal open_senet_compose(recipient_email: String, recipient_name: String)

signal navigator_navigate(url: String)
