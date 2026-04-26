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
	_navigate_to(str(meta))

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

	page_view.scroll_to_line(0)

func _resolve_page(url: String) -> Callable:
	if url.ends_with(".onion") and not tor_active:
		return func(): return _tor_required_page(url)

	match url:
		"ghostnet://home":                        return _page_home
		"pronet.io/in/nadia-webb":                return _page_pronet_nadia
		"pronet.io/in/diane-marsh-helix":         return _page_pronet_diane
		"helixsolutions.com":                     return _page_helix_home
		"helixsolutions.com/about":               return _page_helix_about
		"helixsolutions.com/team":                return _page_helix_team
		"helixsolutions.com/services":            return _page_helix_services
		"helixsolutions.com/contact":             return _page_helix_contact
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
		+ _dim("  [E01 — Nadia's professional background, Diane Marsh connection]")
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
		+ _dim("  [E08 — Diane as a contact, corroborates Nadia's role]")
	)

func _page_helix_home() -> String:
	return (
		"\n"
		+ _tag("HELIXSOLUTIONS.COM", "#0a3d6b") + "\n\n"
		+ _divider()
		+ COLOR_WHITE + "[b]Data you can trust. Compliance you can count on.[/b]" + COLOR_CLOSE + "\n"
		+ _sub("Helix Solutions delivers bespoke financial data management and regulatory compliance services for ambitious businesses.")
		+ "\n"
		+ "  " + _link("About", "helixsolutions.com/about")
		+ "   " + _link("Services", "helixsolutions.com/services")
		+ "   " + _link("Team", "helixsolutions.com/team")
		+ "   " + _link("Contact", "helixsolutions.com/contact")
		+ "\n\n"
		+ _h("OUR SERVICES")
		+ _body("  ■  Audit Services")
		+ _body("  ■  Data Management")
		+ _body("  ■  Regulatory Compliance")
		+ "\n"
		+ _body("Trusted by over 40 businesses across the UK.")
		+ "\n"
		+ _divider()
		+ _dim("  Nothing suspicious here. That's the point.")
	)

func _page_helix_about() -> String:
	return (
		"\n"
		+ _tag("HELIXSOLUTIONS.COM/ABOUT", "#0a3d6b") + "\n\n"
		+ _divider()
		+ _h("ABOUT HELIX SOLUTIONS")
		+ _body("\"Founded in 2019, Helix Solutions has grown from a small compliance consultancy\nto a trusted partner for over 40 businesses across the UK.\"")
		+ "\n"
		+ _body("\"Our team brings decades of combined experience in financial auditing,\ndata governance, and regulatory frameworks.\"")
		+ "\n"
		+ "  " + _link("← helixsolutions.com", "helixsolutions.com")
		+ "   " + _link("Meet the team →", "helixsolutions.com/team")
		+ "\n"
	)

func _page_helix_team() -> String:
	return (
		"\n"
		+ _tag("HELIXSOLUTIONS.COM/TEAM", "#0a3d6b") + "\n\n"
		+ _divider()
		+ _h("OUR TEAM")
		+ "\n"
		+ COLOR_WHITE + "[b]Richard Holt[/b]" + COLOR_CLOSE + "  " + _sub("Director of Operations")
		+ _body("  \"Richard founded Helix Solutions with a vision to make compliance accessible\n  for growing businesses.\"")
		+ "\n"
		+ COLOR_WHITE + "[b]Sandra Vane[/b]" + COLOR_CLOSE + "  " + _sub("Director of Business Development")
		+ _body("  \"Sandra leads our client relationships and strategic partnerships.\"")
		+ "\n"
		+ COLOR_WHITE + "[b]Patricia Cole[/b]" + COLOR_CLOSE + "  " + _sub("Head of Client Services")
		+ _body("  Standard corporate bio.")
		+ "\n"
		+ COLOR_WHITE + "[b]James Fairfax[/b]" + COLOR_CLOSE + "  " + _sub("Lead Analyst")
		+ _body("  Standard corporate bio.")
		+ "\n"
		+ _divider()
		+ _dim("  No Director of Internal Security listed.")
		+ _dim("  No IT or security function mentioned anywhere.")
		+ _dim("  No Daniel Kane.")
	)

func _page_helix_services() -> String:
	return (
		"\n"
		+ _tag("HELIXSOLUTIONS.COM/SERVICES", "#0a3d6b") + "\n\n"
		+ _divider()
		+ _h("AUDIT SERVICES")
		+ _body("Comprehensive financial audit support for regulated industries.")
		+ "\n"
		+ _h("DATA MANAGEMENT")
		+ _body("End-to-end data governance, storage, and compliance reporting.")
		+ "\n"
		+ _h("REGULATORY COMPLIANCE")
		+ _body("Keeping your business ahead of UK and EU regulatory requirements.")
		+ "\n"
		+ "  " + _link("← helixsolutions.com", "helixsolutions.com")
	)

func _page_helix_contact() -> String:
	return (
		"\n"
		+ _tag("HELIXSOLUTIONS.COM/CONTACT", "#0a3d6b") + "\n\n"
		+ _divider()
		+ _h("CONTACT US")
		+ _body("  Email:    info@helixsolutions.com")
		+ _body("  Phone:    +44 20 7946 0321")
		+ _body("  Address:  Meridian House, 14 Canary Lane, London EC2")
		+ "\n"
		+ _dim("  Address also appears in CompanyRegistry filing — ")
		+ "  " + _link("verify on companyregistry.gov", "companyregistry.gov/company/11884762")
		+ "\n"
		+ "  " + _link("← helixsolutions.com", "helixsolutions.com")
	)

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