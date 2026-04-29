extends "res://scripts/desktop/ghost_window.gd"

# ─────────────────────────────────────────────
#  NAVIGATOR — In-game browser
# ─────────────────────────────────────────────

@onready var address_bar:   LineEdit       = $VBoxContainer/AppContainer/BrowserLayout/BrowserChrome/AddressBar
@onready var back_btn:      Button         = $VBoxContainer/AppContainer/BrowserLayout/BrowserChrome/NavButtons/BackBtn
@onready var forward_btn:   Button         = $VBoxContainer/AppContainer/BrowserLayout/BrowserChrome/NavButtons/ForwardBtn
@onready var go_btn:        Button         = $VBoxContainer/AppContainer/BrowserLayout/BrowserChrome/GoBtn
@onready var page_container: PanelContainer   = $VBoxContainer/AppContainer/BrowserLayout/PageContainer
@onready var status_bar:    Label          = $VBoxContainer/AppContainer/BrowserLayout/StatusBar

# ── State ──────────────────────────────────────
var history:        Array[String] = []
var history_index:  int           = -1
var tor_active:     bool          = false
var current_url:    String        = ""

# Colour constants
const COLOR_GREEN      := "[color=#00ff41]"
const COLOR_DIM        := "[color=#4a4a4a]"
const COLOR_AMBER      := "[color=#ffb000]"
const COLOR_RED        := "[color=#ff3333]"
const COLOR_WHITE      := "[color=#cccccc]"
const COLOR_SUBHEADING := "[color=#888888]"
const COLOR_LINK       := "[color=#00cfff]"
const COLOR_CLOSE      := "[/color]"

# ── Ready ──────────────────────────────────────
func _ready() -> void:
	app_name = "NAVIGATOR"
	super._ready()

	back_btn.pressed.connect(_on_back)
	forward_btn.pressed.connect(_on_forward)
	go_btn.pressed.connect(_on_go_pressed)
	address_bar.text_submitted.connect(_on_address_submitted)

	GlobalSignals.tor_state_changed.connect(_on_tor_state_changed)
	GlobalSignals.navigator_navigate.connect(_navigate_to)

	_navigate_to("ghostnet://home")

# ── Navigation ─────────────────────────────────
func _on_go_pressed() -> void:
	_navigate_to(address_bar.text.strip_edges().to_lower())

func _on_address_submitted(url: String) -> void:
	_navigate_to(url.strip_edges().to_lower())

func _on_back() -> void:
	if history_index > 0:
		history_index -= 1
		_load_page(history[history_index])

func _on_forward() -> void:
	if history_index < history.size() - 1:
		history_index += 1
		_load_page(history[history_index])

func _on_link_clicked(meta: Variant) -> void:
	var meta_str = str(meta)
	match meta_str:
		"contact_form_submit":
			# TODO: implement inline message if needed, for now just return
			return
		"msg_no_auth":
			# TODO: implement inline message if needed, for now just return
			return
		"msg_ghostwire_check":
			# TODO: Check GameState.ghostwire_active and GameState.ghostwire_identity
			# For now, just assume they can't message
			return
		_:
			_navigate_to(meta_str)

func _navigate_to(url: String) -> void:
	if url.ends_with("/") and url.length() > 1:
		url = url.left(url.length() - 1)
	if history_index < history.size() - 1:
		history = history.slice(0, history_index + 1)
	history.append(url)
	history_index = history.size() - 1
	_load_page(url)

func _load_page(url: String) -> void:
	current_url = url
	address_bar.text = url

	if tor_active:
		address_bar.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
	else:
		address_bar.add_theme_color_override("font_color", Color(0.0, 1.0, 0.255))

	back_btn.disabled    = history_index <= 0
	forward_btn.disabled = history_index >= history.size() - 1

	for child in page_container.get_children():
		child.queue_free()

	var scene_path = _resolve_scene(url)
	if scene_path == "":
		_load_error_page(url)
		return

	var packed = load(scene_path)
	if packed == null:
		_load_error_page(url)
		return

	var page = packed.instantiate()
	page_container.add_child(page)

	# Evidence flags — set when player visits key pages
	match url:
		"pronet.io/in/nadia-webb":
			GameState.set_flag("viewed_nadia_pronet")
		"pronet.io/in/diane-marsh":
			GameState.set_flag("viewed_diane_pronet")
		"pronet.io/in/richard-holt-helix":
			GameState.set_flag("holt_pronet_visited", true)
		"pronet.io/company/helix-solutions":
			GameState.set_flag("viewed_helix_pronet")
		"helixsolutions.com":
			GameState.set_flag("viewed_helix_home")
		"helixsolutions.com/team":
			GameState.set_flag("viewed_helix_team")
		"helixsolutions.com/services":
			GameState.set_flag("viewed_helix_services")

	status_bar.text = url
	_on_page_loaded(url)

func _resolve_scene(url: String) -> String:
	var registry = {
		"pronet.io/in/nadia-webb": "res://scenes/navigator/pronet_nadia_webb.tscn",
		"pronet.io/in/diane-marsh": "res://scenes/navigator/pronet_diane_marsh.tscn",
		"pronet.io/in/diane-marsh-helix": "res://scenes/navigator/pronet_diane_marsh.tscn",
		"pronet.io/in/richard-holt-helix": "res://scenes/navigator/pronet_richard_holt.tscn",
		"pronet.io/company/helix-solutions": "res://scenes/navigator/pronet_helix_company.tscn",
		"helixsolutions.com": "res://scenes/navigator/helix_home.tscn",
		"helixsolutions.com/about": "res://scenes/navigator/helix_about.tscn",
		"helixsolutions.com/team": "res://scenes/navigator/helix_team.tscn",
		"helixsolutions.com/services": "res://scenes/navigator/helix_services.tscn",
		"helixsolutions.com/contact": "res://scenes/navigator/helix_contact.tscn",
	}
	return registry.get(url, "")

func _load_error_page(url: String) -> void:
	var label = Label.new()
	label.text = "Cannot connect to: " + url
	label.add_theme_color_override("font_color", Color("#ff4444"))
	page_container.add_child(label)
	status_bar.text = "Error: page not found"

func _on_page_loaded(url: String) -> void:
	if url == "pronet.io/in/nadia-webb" and not GameState.get_flag("E01_discovered"):
		GameState.set_flag("E01_discovered", true)
		if GameState.cipher_relationship >= 5:
			GlobalSignals.emit_signal("phantomlink_message", "cipher",
				"nadia webb. data analyst. she was good at her job — the kind of good that makes people nervous. her boss endorsed her for 'finding things that don't add up'. read that endorsement again.")
		else:
			GlobalSignals.emit_signal("phantomlink_message", "cipher",
				"found her. data analyst, compliance division. she was good at her job.")

	if url == "pronet.io/in/diane-marsh-helix" and not GameState.get_flag("E08_contact_identified"):
		GameState.set_flag("E08_contact_identified", true)

	if url == "pronet.io/in/richard-holt-helix" and not GameState.get_flag("holt_pronet_cipher_fired"):
		GameState.set_flag("holt_pronet_cipher_fired", true)
		GlobalSignals.emit_signal("phantomlink_message", "cipher",
			"Holt's been on ProNet recently — 19 days ago. Right around when things went sideways at Helix. And that gap in his CV between 2016 and 2018... two years of nothing. Worth digging.")

	if url == "helixsolutions.com/team":
		if GameState.get_flag("E04_kane_identified") and not GameState.get_flag("team_page_cipher_fired"):
			GameState.set_flag("team_page_cipher_fired", true)
			if GameState.cipher_relationship >= 5:
				GlobalSignals.emit_signal("phantomlink_message", "cipher",
					"director of internal security isn't on the team page. for a company that's running internal surveillance on its own staff. interesting omission.")
			else:
				GlobalSignals.emit_signal("phantomlink_message", "cipher",
					"no security director on the team page. kane doesn't exist here.")

	if url == "helixsolutions.com/contact":
		if GameState.get_flag("E03_registry_visited") and not GameState.get_flag("E02_address_confirmed"):
			GameState.set_flag("E02_address_confirmed", true)

# ── Tor state ──────────────────────────────────
func _on_tor_state_changed(active: bool) -> void:
	tor_active = active
	_load_page(current_url)
