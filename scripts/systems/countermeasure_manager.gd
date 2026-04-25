extends Node

const TIER1_WINDOW = 120.0
const LOCKOUT_TIME = 120.0
const TRACE_TIME = 300.0

var _tier1_timers: Dictionary = {} # machine ip -> time remaining

func _ready() -> void:
	set_process(true)

func _process(delta: float) -> void:
	# Process tier 1 windows
	var ips_to_remove = []
	for ip in _tier1_timers.keys():
		_tier1_timers[ip] -= delta
		if _tier1_timers[ip] <= 0:
			var m = NetworkManager.get_machine(ip)
			if m and m.failed_attempts == 1:
				m.failed_attempts = 0
			ips_to_remove.append(ip)
	for ip in ips_to_remove:
		_tier1_timers.erase(ip)

	# Process machine lockouts and traces
	if not NetworkManager: return
	
	for ip in NetworkManager._machines:
		var m: MachineResource = NetworkManager._machines[ip]
		
		if m.is_locked:
			m.lockout_timer -= delta
			if m.lockout_timer <= 0:
				m.is_locked = false
				GlobalSignals.lockout_expired.emit(m)
				
		if m.cloak_cooldown > 0.0:
			m.cloak_cooldown -= delta
			if m.cloak_cooldown <= 0.0:
				m.cloak_cooldown = 0.0
				GlobalSignals.cloak_expired.emit(m)
				
		if m.is_traced:
			m.trace_progress += (1.0 / 100.0) * delta # 100 seconds to full trace
			GlobalSignals.trace_updated.emit(m, m.trace_progress)
			if m.trace_progress >= 1.0:
				_complete_trace(m)

func check(machine: MachineResource) -> void:
	if machine.is_locked or machine.is_traced:
		return
		
	if machine.failed_attempts == 1:
		_tier1_timers[machine.ip] = TIER1_WINDOW
		GlobalSignals.tier1_triggered.emit(machine)
	elif machine.failed_attempts == 2:
		machine.is_locked = true
		machine.lockout_timer = LOCKOUT_TIME
		GlobalSignals.tier2_triggered.emit(machine)
	elif machine.failed_attempts >= 3:
		trigger_trace(machine)

func trigger_trace(machine: MachineResource) -> void:
	if machine.is_traced: return
	machine.is_traced = true
	machine.trace_progress = 0.0
	GlobalSignals.tier3_triggered.emit(machine)

func halt_trace(machine: MachineResource) -> void:
	if machine.is_traced:
		machine.is_traced = false
		machine.trace_progress = 0.0

func _complete_trace(machine: MachineResource) -> void:
	machine.is_traced = false
	machine.trace_progress = 0.0
	if machine == NetworkManager.get_current_machine():
		NetworkManager.disconnect_current()
	machine.is_locked = true
	machine.lockout_timer = TRACE_TIME
	GlobalSignals.trace_completed.emit(machine)
