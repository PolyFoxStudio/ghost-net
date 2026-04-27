extends "res://scripts/desktop/ghost_window.gd"

# ─────────────────────────────────────────────
#  NAVIGATOR — In-game browser
#  Renders static BBCode pages from a page registry.
#  Supports back/forward history, Tor mode, and
#  clickable [url] links between pages.
# ─────────────────────────────────────────────

@onready var address_bar:   LineEdit       = $VBoxContainer/AppContainer/BrowserLayout/BrowserChrome/AddressBar
@onready var back_btn:      Button         = $VBoxContainer/AppContainer/BrowserLayout/BrowserChrome/NavButtons/BackBtn
@onready var forward_btn:   Button         = $VBoxContainer/AppContainer/BrowserLayout/BrowserChrome/NavButtons/ForwardBtn
@onready var go_btn:        Button         = $VBoxContainer/AppContainer/BrowserLayout/BrowserChrome/GoBtn
@onready var page_view:     RichTextLabel  = $VBoxContainer/AppContainer/BrowserLayout/PageView
@onready var status_bar:    Label          = $VBoxContainer/AppContainer/BrowserLayout/StatusBar

const PAGE_PRONET_NADIA = """
[bgcolor=#f3f2ef][color=#000000]

[table=2]
[cell][bgcolor=#0a66c2][color=#ffffff][b]  ProNet  [/b][/color][/bgcolor]  [color=#666666]Home   My Network   Jobs   Messaging[/color][/cell]
[cell][color=#666666]                                         [url=pronet.io/in/nadia-webb][color=#0a66c2]Nadia[/color][/url] Webb ▾[/color][/cell]
[/table]

[indent]
[table=2]
[cell=2]
[bgcolor=#b6cde0][color=#b6cde0]............................................................[/color][/bgcolor]
[/cell]
[cell]
[color=#555555][b][ photo ][/b][/color]
[b][font_size=18]Nadia Webb[/font_size][/b]
[color=#333333]Data Analyst | Financial Compliance | Helix Solutions Ltd.[/color]
[color=#666666]London, United Kingdom · [url=pronet.io/company/helix-solutions][color=#0a66c2]Helix[/color][/url] Solutions Ltd.[/color]

[color=#555555]214 connections[/color]

[bgcolor=#0a66c2][color=#ffffff]  [url=msg_no_auth] Message [/url]  [/color][/bgcolor]   [bgcolor=#ffffff][color=#0a66c2]  More ▾  [/color][/bgcolor]
[/cell]
[cell]
[/cell]
[/table]
[/indent]

[indent]
─────────────────────────────────────────────────

[b]About[/b]

[color=#333333]Data analyst with five years' experience in financial auditing and compliance reporting. I care about getting things right — not just technically correct, but genuinely right. Currently working in audit data management at Helix Solutions.

Outside work: amateur baker, reluctant runner, very enthusiastic about good coffee.[/color]

─────────────────────────────────────────────────

[b]Activity[/b]

[color=#888888]214 followers[/color]

[bgcolor=#fff3cd][color=#856404]  Last active: 47 days ago · No recent posts or activity.  [/color][/bgcolor]

─────────────────────────────────────────────────

[b]Experience[/b]

[b]Data Analyst[/b]
[url=pronet.io/company/helix-solutions][color=#0a66c2]Helix[/color][/url] Solutions Ltd. · Full-time
[color=#666666]Sep 2022 – Present · 2 yrs 4 mos · London, United Kingdom[/color]

[color=#444444]Working within the audit and compliance division, maintaining and analysing financial datasets for client reporting. Responsible for archive management, discrepancy identification, and regulatory compliance documentation.[/color]

[color=#888888]──────[/color]

[b]Junior Data Analyst[/b]
[color=#333333]Meridian Accounting Partners[/color] · Full-time
[color=#666666]Jun 2019 – Aug 2022 · 3 yrs 2 mos · London, United Kingdom[/color]

[color=#444444]Entry-level financial analysis supporting senior audit team. Prepared client-facing compliance reports and maintained internal data records.[/color]

─────────────────────────────────────────────────

[b]Education[/b]

[b]University of Leeds[/b]
[color=#444444]BSc Mathematics with Statistics · 2015 – 2019[/color]

─────────────────────────────────────────────────

[b]Skills[/b]

[bgcolor=#e8f0fe][color=#1a73e8]  Data Auditing  [/color][/bgcolor]   [bgcolor=#e8f0fe][color=#1a73e8]  Financial Reconciliation  [/color][/bgcolor]   [bgcolor=#e8f0fe][color=#1a73e8]  Compliance Reporting  [/color][/bgcolor]

[bgcolor=#e8f0fe][color=#1a73e8]  Microsoft Excel  [/color][/bgcolor]   [bgcolor=#e8f0fe][color=#1a73e8]  SQL  [/color][/bgcolor]   [bgcolor=#e8f0fe][color=#1a73e8]  Data Governance  [/color][/bgcolor]   [bgcolor=#e8f0fe][color=#1a73e8]  Regulatory Frameworks  [/color][/bgcolor]

─────────────────────────────────────────────────

[b]Recommendations received (1)[/b]

[bgcolor=#f9f9f9]
[b][url=pronet.io/in/diane-marsh-helix][color=#0a66c2]Diane[/color][/url] Marsh[/b] · Senior Data Analyst, Helix Solutions Ltd.
[color=#666666]Colleague · worked with Nadia on the same team[/color]

[color=#333333][i]"Nadia is meticulous and thorough. One of the best analysts I've worked with. She has an instinct for finding things that don't quite add up — which is exactly what you want in this field."[/i][/color]
[/bgcolor]

─────────────────────────────────────────────────

[b]People also viewed[/b]

[url=pronet.io/in/diane-marsh-helix][color=#0a66c2]Diane[/color][/url] Marsh · Senior Data Analyst · Helix Solutions Ltd.
[color=#888888]Colleague[/color]

[/indent]

[color=#aaaaaa][font_size=10]ProNet · About · Accessibility · Privacy Policy · Terms · © 2024[/font_size][/color]

[/color][/bgcolor]
"""

const PAGE_PRONET_DIANE = """
[bgcolor=#f3f2ef][color=#000000]

[table=2]
[cell][bgcolor=#0a66c2][color=#ffffff][b]  ProNet  [/b][/color][/bgcolor]  [color=#666666]Home   My Network   Jobs   Messaging[/color][/cell]
[cell][color=#666666]                                         [url=pronet.io/in/nadia-webb][color=#0a66c2]Nadia[/color][/url] Webb ▾[/color][/cell]
[/table]

[indent]
[table=2]
[cell=2]
[bgcolor=#8aacbe][color=#8aacbe]............................................................[/color][/bgcolor]
[/cell]
[cell]
[color=#555555][b][ photo ][/b][/color]
[b][font_size=18]Diane Marsh[/font_size][/b]
[color=#333333]Senior Data Analyst | Helix Solutions Ltd.[/color]
[color=#666666]London, United Kingdom · [url=pronet.io/company/helix-solutions][color=#0a66c2]Helix[/color][/url] Solutions Ltd.[/color]

[color=#555555]312 connections[/color]

[bgcolor=#0a66c2][color=#ffffff]  [url=msg_ghostwire_check] Message [/url]  [/color][/bgcolor]   [bgcolor=#ffffff][color=#0a66c2]  More ▾  [/color][/bgcolor]

[color=#888888][font_size=10]→ GhostWire identity required to send messages[/font_size][/color]
[/cell]
[cell]
[/cell]
[/table]
[/indent]

[indent]
─────────────────────────────────────────────────

[b]Activity[/b]

[color=#888888]312 followers[/color]

[color=#555555]Last active: 12 days ago · No recent posts or activity.[/color]

─────────────────────────────────────────────────

[b]Experience[/b]

[b]Senior Data Analyst[/b]
[url=pronet.io/company/helix-solutions][color=#0a66c2]Helix[/color][/url] Solutions Ltd. · Full-time
[color=#666666]Mar 2019 – Present · 7 yrs 1 mo · London, United Kingdom[/color]

[color=#444444]Senior analyst within the audit compliance division. Managing and mentoring junior analysts, overseeing data integrity across client portfolios.[/color]

[color=#888888]──────[/color]

[b]Senior Analyst[/b]
[color=#333333]Carver Financial Services[/color] · Full-time
[color=#666666]Jan 2015 – Feb 2019 · 4 yrs 1 mo[/color]

[color=#888888]──────[/color]

[b]Data Analyst[/b]
[color=#333333]Beacon Compliance Group[/color] · Full-time
[color=#666666]Jun 2011 – Dec 2014[/color]

─────────────────────────────────────────────────

[b]Education[/b]

[b]University of Manchester[/b]
[color=#444444]BSc Accounting and Finance · 2005 – 2008[/color]

─────────────────────────────────────────────────

[b]Skills[/b]

[bgcolor=#e8f0fe][color=#1a73e8]  Data Auditing  [/color][/bgcolor]   [bgcolor=#e8f0fe][color=#1a73e8]  Team Management  [/color][/bgcolor]   [bgcolor=#e8f0fe][color=#1a73e8]  Compliance Reporting  [/color][/bgcolor]

[bgcolor=#e8f0fe][color=#1a73e8]  Data Governance  [/color][/bgcolor]   [bgcolor=#e8f0fe][color=#1a73e8]  Regulatory Frameworks  [/color][/bgcolor]

─────────────────────────────────────────────────

[b]People also viewed[/b]

[url=pronet.io/in/nadia-webb][color=#0a66c2]Nadia[/color][/url] Webb · Data Analyst · Helix Solutions Ltd.
[color=#888888]Colleague · [color=#e8a000]Last active 47 days ago[/color][/color]

[/indent]

[color=#aaaaaa][font_size=10]ProNet · About · Accessibility · Privacy Policy · Terms · © 2024[/font_size][/color]

[/color][/bgcolor]
"""

	# ─── LOC-02: helixsolutions.com ───────────────────────────────────────────────

const PAGE_HELIX_HOME = """
[bgcolor=#1a2744][color=#ffffff]

[table=2]
[cell][color=#ffffff][b]  HELIX SOLUTIONS  [/b][/color][/cell]
[cell][color=#aaaacc]  [url=helixsolutions.com/about]About[/url]   [url=helixsolutions.com/team]Team[/url]   [url=helixsolutions.com/services]Services[/url]   [url=helixsolutions.com/contact]Contact[/url][/color][/cell]
[/table]

[center]
[font_size=26][b]Data you can trust.[/b][/font_size]
[font_size=26][b]Compliance you can count on.[/b][/font_size]

[color=#aab4cc]Helix Solutions delivers bespoke financial data management and regulatory
compliance services for ambitious businesses.[/color]

[bgcolor=#ffffff][color=#1a2744][b]  [url=helixsolutions.com/contact]Get in touch →[/url]  [/b][/color][/bgcolor]
[/center]

─────────────────────────────────────────────────

[table=3]
[cell]
[b]Audit Services[/b]
[color=#aab4cc]Comprehensive financial auditing that goes beyond the numbers. We identify risks, resolve discrepancies, and give you a complete picture of your financial health.[/color]
[/cell]
[cell]
[b]Data Management[/b]
[color=#aab4cc]From archive strategy to live data governance, we manage your information assets with precision and care — so you can focus on your business.[/color]
[/cell]
[cell]
[b]Regulatory Compliance[/b]
[color=#aab4cc]Navigating regulatory requirements shouldn't be a burden. Our compliance experts keep you ahead of the curve and out of trouble.[/color]
[/cell]
[/table]

─────────────────────────────────────────────────

[center][color=#aab4cc]Trusted by over 40 businesses across the UK[/color][/center]

[table=3]
[cell][color=#667788]  Meridian Capital Partners  [/color][/cell]
[cell][color=#667788]  Farrow & Cole Group  [/color][/cell]
[cell][color=#667788]  Ashdown Infrastructure  [/color][/cell]
[/table]
[table=3]
[cell][color=#667788]  NovaBridge Technologies  [/color][/cell]
[cell][color=#667788]  Sentinel Risk Advisory  [/color][/cell]
[cell][color=#667788]  Kestrel Property Holdings  [/color][/cell]
[/table]

─────────────────────────────────────────────────

[color=#445566][font_size=10]© 2024 Helix Solutions Ltd. · Registered in England and Wales No. 11884762 · Meridian House, 14 Canary Lane, London EC2 · info@helixsolutions.com[/font_size][/color]

[/color][/bgcolor]
"""

const PAGE_HELIX_ABOUT = """
[bgcolor=#1a2744][color=#ffffff]

[table=2]
[cell][color=#ffffff][b]  HELIX SOLUTIONS  [/b][/color][/cell]
[cell][color=#aaaacc]  [url=helixsolutions.com]Home[/url]   [url=helixsolutions.com/team]Team[/url]   [url=helixsolutions.com/services]Services[/url]   [url=helixsolutions.com/contact]Contact[/url][/color][/cell]
[/table]

[indent]
[font_size=20][b]About Helix Solutions[/b][/font_size]

[color=#aab4cc]Founded in 2019, Helix Solutions has grown from a small compliance consultancy into a trusted partner for businesses across the UK. We believe that good data governance isn't just a regulatory requirement — it's a competitive advantage.

Our team brings decades of combined experience in financial auditing, data management, and regulatory frameworks. We work closely with our clients to understand their specific needs and deliver tailored solutions that stand up to scrutiny.[/color]

─────────────────────────────────────────────────

[b]Our values[/b]

[table=3]
[cell]
[b]Accuracy[/b]
[color=#aab4cc]We get it right. Every time. No shortcuts, no approximations — just precise, reliable work our clients can stand behind.[/color]
[/cell]
[cell]
[b]Integrity[/b]
[color=#aab4cc]We hold ourselves to the same standards we apply to our clients' data. Transparent, honest, and accountable at every stage.[/color]
[/cell]
[cell]
[b]Discretion[/b]
[color=#aab4cc]Our clients trust us with sensitive information. That trust is the foundation of everything we do. It is never taken lightly.[/color]
[/cell]
[/table]

─────────────────────────────────────────────────

[color=#aab4cc]We're proud of the relationships we've built — and the results we've delivered.[/color]

[bgcolor=#ffffff][color=#1a2744][b]  [url=helixsolutions.com/team]Meet the team →[/url]  [/b][/color][/bgcolor]

[/indent]

[color=#445566][font_size=10]© 2024 Helix Solutions Ltd. · Registered in England and Wales No. 11884762 · Meridian House, 14 Canary Lane, London EC2[/font_size][/color]

[/color][/bgcolor]
"""

const PAGE_HELIX_TEAM = """
[bgcolor=#1a2744][color=#ffffff]

[table=2]
[cell][color=#ffffff][b]  HELIX SOLUTIONS  [/b][/color][/cell]
[cell][color=#aaaacc]  [url=helixsolutions.com]Home[/url]   [url=helixsolutions.com/about]About[/url]   [url=helixsolutions.com/services]Services[/url]   [url=helixsolutions.com/contact]Contact[/url][/color][/cell]
[/table]

[indent]
[font_size=20][b]Our Team[/b][/font_size]

[color=#aab4cc]The people behind Helix Solutions.[/color]

─────────────────────────────────────────────────

[table=2]
[cell]
[color=#667788][b][ photo ][/b][/color]
[b]Richard Holt[/b]
[color=#aab4cc]Director of Operations[/color]

[color=#889aaa]Richard co-founded Helix Solutions with a clear vision: to make high-quality compliance services accessible to growing businesses. With over 20 years in financial services, he brings deep expertise and a practical approach to every client engagement.[/color]
[/cell]
[cell]
[color=#667788][b][ photo ][/b][/color]
[b]Sandra Vane[/b]
[color=#aab4cc]Director of Business Development[/color]

[color=#889aaa]Sandra leads client relationships and strategic partnerships at Helix. She is passionate about understanding client needs and building long-term partnerships built on trust and results.[/color]
[/cell]
[/table]

[color=#334455]──────[/color]

[table=2]
[cell]
[color=#667788][b][ photo ][/b][/color]
[b]Patricia Cole[/b]
[color=#aab4cc]Head of Client Services[/color]

[color=#889aaa]Patricia oversees our client services team, ensuring every engagement delivers against its objectives. She has been with Helix since 2020 and brings a background in financial services operations.[/color]
[/cell]
[cell]
[color=#667788][b][ photo ][/b][/color]
[b]James Fairfax[/b]
[color=#aab4cc]Lead Analyst[/color]

[color=#889aaa]James leads our analyst team, managing data projects from scoping through delivery. He holds a First in Mathematics from the University of Edinburgh and a postgraduate qualification in data governance.[/color]
[/cell]
[/table]

─────────────────────────────────────────────────

[color=#aab4cc]Helix Solutions is supported by a wider team of analysts, compliance specialists, and client managers. [url=helixsolutions.com/contact][color=#7799bb]Get in touch[/color][/url] to find out more.[/color]

[/indent]

[color=#445566][font_size=10]© 2024 Helix Solutions Ltd. · Registered in England and Wales No. 11884762 · Meridian House, 14 Canary Lane, London EC2[/font_size][/color]

[/color][/bgcolor]
"""

const PAGE_HELIX_SERVICES = """
[bgcolor=#1a2744][color=#ffffff]

[table=2]
[cell][color=#ffffff][b]  HELIX SOLUTIONS  [/b][/color][/cell]
[cell][color=#aaaacc]  [url=helixsolutions.com]Home[/url]   [url=helixsolutions.com/about]About[/url]   [url=helixsolutions.com/team]Team[/url]   [url=helixsolutions.com/contact]Contact[/url][/color][/cell]
[/table]

[indent]
[font_size=20][b]Services[/b][/font_size]

[color=#aab4cc]We offer a focused range of financial data and compliance services, tailored to the needs of each client.[/color]

─────────────────────────────────────────────────

[b]Audit Data Management[/b]
[color=#aab4cc]We specialise in the management, organisation, and analysis of financial audit data. Whether you're preparing for a regulatory review or cleaning up legacy records, our team delivers accurate, reliable results.[/color]

[color=#445566]──────[/color]

[b]Compliance Reporting[/b]
[color=#aab4cc]Our compliance reporting service takes the complexity out of regulatory documentation. We produce clear, accurate reports that meet the requirements of UK financial regulators — on time, every time.[/color]

[color=#445566]──────[/color]

[b]Data Governance Consulting[/b]
[color=#aab4cc]Good data governance starts with a clear strategy. We work with your team to develop frameworks, policies, and processes that protect your data assets and ensure regulatory compliance.[/color]

[color=#445566]──────[/color]

[b]Archive Management[/b]
[color=#aab4cc]Financial records need to be managed, stored, and retrieved with precision. Our archive management service ensures your historical data is secure, organised, and accessible when you need it.[/color]

─────────────────────────────────────────────────

[color=#aab4cc]Not sure which service is right for you?[/color]

[bgcolor=#ffffff][color=#1a2744][b]  [url=helixsolutions.com/contact]Talk to us →[/url]  [/b][/color][/bgcolor]

[/indent]

[color=#445566][font_size=10]© 2024 Helix Solutions Ltd. · Registered in England and Wales No. 11884762 · Meridian House, 14 Canary Lane, London EC2[/font_size][/color]

[/color][/bgcolor]
"""

const PAGE_HELIX_CONTACT = """
[bgcolor=#1a2744][color=#ffffff]

[table=2]
[cell][color=#ffffff][b]  HELIX SOLUTIONS  [/b][/color][/cell]
[cell][color=#aaaacc]  [url=helixsolutions.com]Home[/url]   [url=helixsolutions.com/about]About[/url]   [url=helixsolutions.com/team]Team[/url]   [url=helixsolutions.com/services]Services[/url][/color][/cell]
[/table]

[indent]
[font_size=20][b]Contact Us[/b][/font_size]

[color=#aab4cc]We'd love to hear from you.[/color]

─────────────────────────────────────────────────

[table=2]
[cell]
[b]Get in touch[/b]

[color=#aab4cc]Email:[/color]   [color=#7799bb]info@helixsolutions.com[/color]
[color=#aab4cc]Phone:[/color]   [color=#ffffff]+44 20 7946 0821[/color]
[color=#aab4cc]Address:[/color] [color=#ffffff]Meridian House, 14 Canary Lane[/color]
		  [color=#ffffff]London EC2 4RQ[/color]

[color=#667788][font_size=10]We aim to respond to all enquiries within one business day.[/font_size][/color]
[/cell]
[cell]
[b]Send a message[/b]

[color=#667788]Name ──────────────────────[/color]
[color=#667788]Company ────────────────────[/color]
[color=#667788]Email ──────────────────────[/color]
[color=#667788]Message ────────────────────[/color]
[color=#667788]        ────────────────────[/color]
[color=#667788]        ────────────────────[/color]

[bgcolor=#ffffff][color=#1a2744][b]  [url=contact_form_submit]Send message →[/url]  [/b][/color][/bgcolor]

[color=#556677][font_size=10]This form is for general enquiries only.[/font_size][/color]
[/cell]
[/table]

─────────────────────────────────────────────────

[color=#aab4cc]Our office is located in the heart of the City of London, a short walk from Canary Wharf DLR and Monument Underground station.[/color]

[/indent]

[color=#445566][font_size=10]© 2024 Helix Solutions Ltd. · Registered in England and Wales No. 11884762 · Meridian House, 14 Canary Lane, London EC2[/font_size][/color]

[/color][/bgcolor]
"""

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
	page_view.meta_clicked.connect(_on_link_clicked)

	GlobalSignals.tor_state_changed.connect(_on_tor_state_changed)

	_navigate_to("ghostnet://home")

# ── Navigation ─────────────────────────────────
func _on_go_pressed() -> void:
	_navigate_to(address_bar.text.strip_edges().to_lower())

func _on_address_submitted(url: String) -> void:
	_navigate_to(url.strip_edges().to_lower())

func _on_back() -> void:
	if history_index > 0:
		history_index -= 1
		_load_page(history[history_index], false)

func _on_forward() -> void:
	if history_index < history.size() - 1:
		history_index += 1
		_load_page(history[history_index], false)

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
	_load_page(url, true)

func _load_page(url: String, update_bar: bool) -> void:
	current_url = url
	if update_bar:
		address_bar.text = url

	if tor_active:
		address_bar.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
	else:
		address_bar.add_theme_color_override("font_color", Color(0.0, 1.0, 0.255))

	back_btn.disabled    = history_index <= 0
	forward_btn.disabled = history_index >= history.size() - 1

	var page_func := _resolve_page(url)
	if page_func == null:
		page_view.text = _page_not_found(url)
		status_bar.text = "404 — page not found"
	else:
		page_view.text = page_func.call()
		status_bar.text = url

	_on_page_loaded(url)
	page_view.scroll_to_line(0)

func _apply_page_background(url: String) -> void:
	var style = StyleBoxFlat.new()
	if url.begins_with("pronet.io"):
		style.bg_color = Color("#f3f2ef")
		page_view.add_theme_stylebox_override("normal", style)
		page_view.add_theme_color_override("default_color", Color("#000000"))
	else:
		style.bg_color = Color("#0d0d0d")
		page_view.add_theme_stylebox_override("normal", style)
		page_view.add_theme_color_override("default_color", Color("#00ff41"))

func _on_page_loaded(url: String) -> void:
	_apply_page_background(url)
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

func _resolve_page(url: String) -> Callable:
	if url.ends_with(".onion") and not tor_active:
		return func(): return _tor_required_page(url)

	match url:
		"ghostnet://home":                        return _page_home
		"pronet.io/in/nadia-webb":                return _page_pronet_nadia
		"pronet.io/in/diane-marsh-helix":         return _page_pronet_diane
		"pronet.io/company/helix-solutions":      return func(): return PAGE_PRONET_HELIX_COMPANY
		"helixsolutions.com":                     return func(): return PAGE_HELIX_HOME
		"helixsolutions.com/about":               return func(): return PAGE_HELIX_ABOUT
		"helixsolutions.com/team":                return func(): return PAGE_HELIX_TEAM
		"helixsolutions.com/services":            return func(): return PAGE_HELIX_SERVICES
		"helixsolutions.com/contact":             return func(): return PAGE_HELIX_CONTACT
		"companyregistry.gov":                    return _page_companyreg_home
		"companyregistry.gov/company/11884762":   return _page_helix_filing
		"companyregistry.gov/company/09941123":   return _page_holtvane_filing
		"pulse.social/nadia_webb":                return _page_pulse_nadia
		_:                                        return Callable()

# ── Tor state ──────────────────────────────────
func _on_tor_state_changed(active: bool) -> void:
	tor_active = active
	_load_page(current_url, false)

# ═══════════════════════════════════════════════
#  PAGE HELPERS
# ═══════════════════════════════════════════════

func _h(text: String) -> String:
	return COLOR_GREEN + "[b]" + text + "[/b]" + COLOR_CLOSE + "\n"

func _sub(text: String) -> String:
	return COLOR_SUBHEADING + text + COLOR_CLOSE + "\n"

func _body(text: String) -> String:
	return COLOR_WHITE + text + COLOR_CLOSE + "\n"

func _dim(text: String) -> String:
	return COLOR_DIM + text + COLOR_CLOSE + "\n"

func _link(label: String, url: String) -> String:
	return COLOR_LINK + "[url=" + url + "]" + label + "[/url]" + COLOR_CLOSE

func _divider() -> String:
	return COLOR_DIM + "─────────────────────────────────────────────────────\n" + COLOR_CLOSE

func _tag(text: String, color: String = "#444444") -> String:
	return "[color=" + color + "][" + text + "][/color]"

# ═══════════════════════════════════════════════
#  PAGES
# ═══════════════════════════════════════════════

func _page_home() -> String:
	return (
		"\n"
		+ COLOR_GREEN + "[b]NAVIGATOR v1.0[/b]" + COLOR_CLOSE + "  "
		+ COLOR_SUBHEADING + "secure browser — built by Cipher" + COLOR_CLOSE + "\n\n"
		+ _divider()
		+ _body("Enter a URL in the address bar or use a link below.")
		+ "\n"
		+ _sub("QUICK LINKS")
		+ "  " + _link("pronet.io", "pronet.io/in/nadia-webb") + "\n"
		+ "  " + _link("helixsolutions.com", "helixsolutions.com") + "\n"
		+ "  " + _link("companyregistry.gov", "companyregistry.gov") + "\n"
		+ "\n"
		+ _dim("Tor is " + ("ACTIVE — dark web accessible" if tor_active else "inactive — .onion addresses unavailable"))
	)

func _page_pronet_nadia() -> String:
	return (
		"\n"
		+ _tag("PRONET", "#1a6e3c") + "  " + COLOR_SUBHEADING + "pronet.io/in/nadia-webb" + COLOR_CLOSE + "\n\n"
		+ _divider()
		+ COLOR_GREEN + "[b]Nadia Webb[/b]" + COLOR_CLOSE + "\n"
		+ _sub("Data Analyst | Financial Compliance | Helix Solutions Ltd.")
		+ _sub("London, United Kingdom  ·  214 connections")
		+ "\n"
		+ _h("EXPERIENCE")
		+ _body("Helix Solutions Ltd. — Data Analyst")
		+ _dim("  September 2022 – Present (2 yrs 4 mos) · London")
		+ _body("  \"Working within the audit and compliance division, maintaining and\n  analysing financial data sets for client reporting.\"")
		+ "\n"
		+ _body("Meridian Accounting Partners — Junior Analyst")
		+ _dim("  June 2019 – August 2022 (3 yrs 2 mos) · London")
		+ _body("  \"Entry-level financial analysis supporting senior audit team.\"")
		+ "\n"
		+ _h("SKILLS")
		+ _body("Data Auditing · Financial Reconciliation · Compliance Reporting · SQL")
		+ "\n"
		+ _h("ENDORSEMENTS")
		+ _body(_link("Diane Marsh", "pronet.io/in/diane-marsh-helix") + " endorsed Nadia for Data Auditing:")
		+ _body("  \"Nadia is meticulous and thorough. One of the best analysts I've worked with.\"")
		+ "\n"
		+ _h("ACTIVITY")
		+ _dim("  Last active: 47 days ago  ·  No recent posts")
		+ "\n"
		+ _divider()
	)

func _page_pronet_diane() -> String:
	return (
		"\n"
		+ _tag("PRONET", "#1a6e3c") + "  " + COLOR_SUBHEADING + "pronet.io/in/diane-marsh-helix" + COLOR_CLOSE + "\n\n"
		+ _divider()
		+ COLOR_GREEN + "[b]Diane Marsh[/b]" + COLOR_CLOSE + "\n"
		+ _sub("Senior Data Analyst | Helix Solutions Ltd.")
		+ _sub("London, United Kingdom")
		+ "\n"
		+ _h("EXPERIENCE")
		+ _body("Helix Solutions Ltd. — Senior Data Analyst")
		+ _dim("  March 2019 – Present (7 yrs 1 mo) · London")
		+ _body("  \"Senior analyst within the audit compliance division.\"")
		+ "\n"
		+ _h("ACTIVITY")
		+ _dim("  Last active: 12 days ago  ·  No recent posts")
		+ "\n"
		+ _h("MESSAGE")
		+ _body("  " + _link("[Send message]", "action://ghostwire_message_diane"))
		+ _dim("  Requires GhostWire identity to message external contacts.")
		+ "\n"
		+ _divider()
	)

const PAGE_PRONET_HELIX_COMPANY = """
[bgcolor=#f3f2ef][color=#000000]

[table=2]
[cell][bgcolor=#0a66c2][color=#ffffff][b]  ProNet  [/b][/color][/bgcolor]  [color=#666666]Home   My Network   Jobs   Messaging[/color][/cell]
[cell][color=#666666]                                         [url=pronet.io/in/nadia-webb][color=#0a66c2]Nadia[/color][/url] Webb ▾[/color][/cell]
[/table]

[indent]
[bgcolor=#1a2744][color=#1a2744]............................................................[/color][/bgcolor]

[b][font_size=18]Helix Solutions Ltd.[/font_size][/b]
[color=#555555]Financial Services · London, United Kingdom · 12 employees on ProNet[/color]

[url=helixsolutions.com][color=#0a66c2]helixsolutions.com[/color][/url]

─────────────────────────────────────────────────

[b]About[/b]

[color=#333333]Helix Solutions delivers bespoke financial data management and regulatory compliance services for ambitious businesses. Founded 2019.[/color]

─────────────────────────────────────────────────

[b]People (12 on ProNet)[/b]

[url=pronet.io/in/nadia-webb][color=#0a66c2]Nadia[/color][/url] Webb · Data Analyst
[color=#e8a000]Last active 47 days ago[/color]

[url=pronet.io/in/diane-marsh-helix][color=#0a66c2]Diane[/color][/url] Marsh · Senior Data Analyst
[color=#888888]Last active 12 days ago[/color]

[color=#444444]Richard Holt[/color] · Director of Operations
[color=#888888]Last active 3 days ago[/color]

[color=#444444]Sandra Vane[/color] · Director of Business Development
[color=#888888]Last active 5 days ago[/color]

[color=#444444]Patricia Cole[/color] · Head of Client Services
[color=#888888]Last active 8 days ago[/color]

[color=#444444]James Fairfax[/color] · Lead Analyst
[color=#888888]Last active 2 days ago[/color]

[color=#888888]+ 6 more employees[/color]

[/indent]

[color=#aaaaaa][font_size=10]ProNet · About · Accessibility · Privacy Policy · Terms · © 2024[/font_size][/color]

[/color][/bgcolor]
"""
func _page_companyreg_home() -> String:
	return (
		"\n"
		+ _tag("COMPANYREGISTRY.GOV", "#2b4a6f") + "  " + COLOR_SUBHEADING + "UK Company Filing Database" + COLOR_CLOSE + "\n\n"
		+ _divider()
		+ _sub("Search results for: helix solutions")
		+ "\n"
		+ COLOR_GREEN + "[b]Helix Solutions Ltd.[/b]" + COLOR_CLOSE
		+ "  " + _dim("Company No. 11884762  ·  Status: Active  ·  Incorporated: 14 March 2019") + "\n"
		+ "  " + _link("View filing →", "companyregistry.gov/company/11884762")
		+ "\n"
	)

func _page_helix_filing() -> String:
	return (
		"\n"
		+ _tag("COMPANYREGISTRY.GOV", "#2b4a6f") + "\n\n"
		+ _divider()
		+ _h("HELIX SOLUTIONS LTD.")
		+ _body("  Company number:   11884762")
		+ _body("  Status:           Active")
		+ _body("  Type:             Private limited company")
		+ _body("  Incorporated:     14 March 2019")
		+ _body("  Registered office: Meridian House, 14 Canary Lane, London EC2")
		+ "\n"
		+ _h("DIRECTORS")
		+ _body("  Richard James Holt   —  appointed 14/03/2019")
		+ _body("  Sandra Marie Vane    —  appointed 14/03/2019")
		+ "\n"
		+ _h("SHAREHOLDERS")
		+ COLOR_AMBER + "[b]  Holt-Vane Holdings Ltd.   100% ordinary shares[/b]" + COLOR_CLOSE + "\n"
		+ "  " + _link("Search Holt-Vane Holdings →", "companyregistry.gov/company/09941123")
		+ "\n\n"
		+ _h("ACCOUNTS")
		+ _body("  Last filed: 31 December 2024  ·  Status: Filed on time")
		+ "\n"
		+ _divider()
		+ _dim("  [E03 — Holt-Vane Holdings as sole shareholder]")
	)

func _page_holtvane_filing() -> String:
	return (
		"\n"
		+ _tag("COMPANYREGISTRY.GOV", "#2b4a6f") + "\n\n"
		+ _divider()
		+ _h("HOLT-VANE HOLDINGS LTD.")
		+ _body("  Company number:   09941123")
		+ _body("  Status:           Active")
		+ _body("  Type:             Private limited company")
		+ _body("  Incorporated:     22 November 2018")
		+ "\n"
		+ _h("DIRECTORS")
		+ COLOR_AMBER + "  Nominee Director Services Ltd.   —  appointed 22/11/2018\n" + COLOR_CLOSE
		+ _dim("  [Note: nominee arrangement — true beneficial owner not disclosed]")
		+ "\n"
		+ _h("REGISTERED OFFICE")
		+ COLOR_RED + "[b]  PO Box 4471, Road Town, Tortola, British Virgin Islands[/b]" + COLOR_CLOSE + "\n"
		+ "\n"
		+ _h("INCOME")
		+ _body("  Management fees received from subsidiaries")
		+ _dim("  [No other stated income — minimal BVI disclosure]")
		+ "\n"
		+ _divider()
		+ _dim("  [E10 — Holt-Vane Holdings as shell company, BVI connection]")
	)

func _page_pulse_nadia() -> String:
	return (
		"\n"
		+ _tag("PULSE", "#1d3a5c") + "  " + COLOR_SUBHEADING + "pulse.social/nadia_webb" + COLOR_CLOSE + "\n\n"
		+ _divider()
		+ COLOR_GREEN + "[b]Nadia Webb[/b]" + COLOR_CLOSE + "  " + COLOR_SUBHEADING + "@nadia_webb" + COLOR_CLOSE + "\n"
		+ _sub("Data nerd. Coffee dependent. London.  ·  Joined April 2018")
		+ _dim("  Following: 312  ·  Followers: 89")
		+ "\n"
		+ _h("RECENT POSTS")
		+ COLOR_SUBHEADING + "50 days ago" + COLOR_CLOSE + "\n"
		+ _body("  \"Long week. Ready for the weekend. 🍷\"")
		+ _dim("  4 likes  ·  0 replies")
		+ "\n"
		+ COLOR_SUBHEADING + "58 days ago" + COLOR_CLOSE + "\n"
		+ _body("  \"Finally tried that ramen place on Brick Lane. 10/10 would\n  recommend to anyone within walking distance.\"")
		+ _dim("  11 likes  ·  2 replies")
		+ "\n"
		+ COLOR_SUBHEADING + "71 days ago" + COLOR_CLOSE + "\n"
		+ _body("  \"Anyone else find that the more you understand how data\n  compliance works, the more anxious you get? Just me?\"")
		+ _dim("  6 likes  ·  1 reply")
		+ "\n"
		+ _h("DELETED CONTENT")
		+ COLOR_RED + "  [Post deleted — 68 days ago]" + COLOR_CLOSE + "\n"
		+ _dim("  Retweeted article: \"Whistleblower protections in the UK:\n  what employees need to know\" — The Signal")
		+ _dim("  Use 'wayback pulse.social/nadia_webb' in terminal to recover.")
		+ "\n"
		+ _divider()
		+ _dim("  [E07 — Last post 50 days ago, deleted whistleblower retweet]")
	)

func _page_not_found(url: String) -> String:
	return (
		"\n"
		+ COLOR_RED + "[b]404 — Page not found[/b]" + COLOR_CLOSE + "\n\n"
		+ _body("The address [b]" + url + "[/b] could not be resolved.")
		+ "\n"
		+ _dim("Check the URL or try a different address.")
		+ "\n\n"
		+ "  " + _link("← ghostnet://home", "ghostnet://home")
	)

func _tor_required_page(url: String) -> String:
	return (
		"\n"
		+ COLOR_RED + "[b]CONNECTION REFUSED[/b]" + COLOR_CLOSE + "\n\n"
		+ _body("The address [b]" + url + "[/b] is a .onion address.")
		+ _body("Tor routing is not active.")
		+ "\n"
		+ COLOR_AMBER + "  Run 'tor --start' in the terminal to enable dark web access." + COLOR_CLOSE + "\n\n"
		+ "  " + _link("← ghostnet://home", "ghostnet://home")
	)
