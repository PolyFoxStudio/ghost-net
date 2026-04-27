extends "res://scripts/desktop/ghost_window.gd"

# ─────────────────────────────────────────────
#  SENET — Social Engineering Network Exploitation Toolkit
#
#  Three-panel layout:
#    Left   — Template library
#    Centre — Compose window (manual blank entry)
#    Right  — Engagement log
#
#  All fields are free-text. The player must supply every value
#  manually. No autocomplete. No contact lists.
# ─────────────────────────────────────────────

# ── Node refs ──────────────────────────────────
@onready var template_list:    ItemList      = $VBoxContainer/AppContainer/SenetLayout/TemplatePanel/TemplateList
@onready var compose_panel:    VBoxContainer = $VBoxContainer/AppContainer/SenetLayout/ComposePanel
@onready var to_field:         LineEdit      = $VBoxContainer/AppContainer/SenetLayout/ComposePanel/Fields/ToRow/ToField
@onready var from_field:       LineEdit      = $VBoxContainer/AppContainer/SenetLayout/ComposePanel/Fields/FromRow/FromField
@onready var subject_field:    LineEdit      = $VBoxContainer/AppContainer/SenetLayout/ComposePanel/Fields/SubjectRow/SubjectField
@onready var body_container:   VBoxContainer = $VBoxContainer/AppContainer/SenetLayout/ComposePanel/BodyContainer
@onready var send_btn:         Button        = $VBoxContainer/AppContainer/SenetLayout/ComposePanel/SendBtn
@onready var validation_label: Label         = $VBoxContainer/AppContainer/SenetLayout/ComposePanel/ValidationLabel
@onready var log_list:         ItemList      = $VBoxContainer/AppContainer/SenetLayout/LogPanel/LogList
@onready var log_detail:       RichTextLabel = $VBoxContainer/AppContainer/SenetLayout/LogPanel/LogDetail
@onready var log_placeholder:   Label         = $VBoxContainer/AppContainer/SenetLayout/LogPanel/LogPlaceholder

# ── Template definitions ───────────────────────
const TEMPLATES := [
	{
		"id": 0,
		"label": "[IT SUPPORT]  Template 01",
		"subject": "RE: [SUBJECT_CONTEXT] — IT Support Ticket #[TICKET_NUMBER]",
		"blanks": [
			{"key": "SUBJECT_CONTEXT",   "prompt": "Subject context (e.g. Server Migration Verification)"},
			{"key": "TICKET_NUMBER",     "prompt": "Ticket number (e.g. 4471)"},
			{"key": "TARGET_NAME",       "prompt": "Target's first name"},
			{"key": "SENDER_NAME",       "prompt": "Your name (GhostWire identity)"},
			{"key": "SENDER_ORG",        "prompt": "Your organisation"},
			{"key": "SYSTEM_OR_ISSUE",   "prompt": "System or issue referenced"},
			{"key": "REQUEST",           "prompt": "What you are asking them to confirm"},
		],
		"body": """Hi [TARGET_NAME],

This is [SENDER_NAME] from [SENDER_ORG]. We're following up on a support request logged for [SYSTEM_OR_ISSUE].

Could you confirm [REQUEST] so we can progress the ticket?

We're aiming to resolve this by end of day — any detail you can provide would be appreciated.

Thanks,
[SENDER_NAME]
IT Support — [SENDER_ORG]"""
	},
	{
		"id": 1,
		"label": "[EXTERNAL AUDIT]  Template 02",
		"subject": "Audit Verification — [COMPANY_NAME] — Ref: [REF_NUMBER]",
		"blanks": [
			{"key": "COMPANY_NAME",      "prompt": "Company name being audited"},
			{"key": "REF_NUMBER",        "prompt": "Reference number (e.g. AV-2024-0391)"},
			{"key": "TARGET_NAME",       "prompt": "Target's full name"},
			{"key": "SENDER_ORG",        "prompt": "Your organisation"},
			{"key": "SENDER_NAME",       "prompt": "Your name (GhostWire identity)"},
			{"key": "SENDER_TITLE",      "prompt": "Your job title"},
			{"key": "SPECIFIC_DETAIL",   "prompt": "What you need them to verify"},
			{"key": "REQUEST",           "prompt": "Your specific question or ask"},
		],
		"body": """Dear [TARGET_NAME],

I'm contacting you from [SENDER_ORG] in relation to an ongoing compliance review of [COMPANY_NAME].

As part of this review, we need to verify [SPECIFIC_DETAIL]. This is a routine verification — no action is required on your part beyond a brief confirmation.

Could you confirm [REQUEST] at your earliest convenience?

Many thanks,
[SENDER_NAME]
[SENDER_TITLE]
[SENDER_ORG]
Ref: [REF_NUMBER]"""
	},
	{
		"id": 2,
		"label": "[VENDOR / SUPPLIER]  Template 03",
		"subject": "Supplier Account Query — [ACCOUNT_REF]",
		"blanks": [
			{"key": "ACCOUNT_REF",       "prompt": "Account reference"},
			{"key": "TARGET_NAME",       "prompt": "Target's first name"},
			{"key": "SENDER_ORG",        "prompt": "Your organisation"},
			{"key": "SENDER_NAME",       "prompt": "Your name (GhostWire identity)"},
			{"key": "SENDER_TITLE",      "prompt": "Your job title"},
			{"key": "SERVICE_PRODUCT",   "prompt": "Service or product in question"},
			{"key": "STATED_ISSUE",      "prompt": "The issue you're raising"},
			{"key": "REQUEST",           "prompt": "What you are asking them to check"},
		],
		"body": """Hi [TARGET_NAME],

I'm reaching out from [SENDER_ORG] regarding our supplier account for [SERVICE_PRODUCT].

We've had a flag on our records for [STATED_ISSUE] and wanted to check [REQUEST] before we raise it formally.

Happy to take a call if easier — just let me know a good time.

Best,
[SENDER_NAME]
[SENDER_TITLE]
[SENDER_ORG]"""
	},
	{
		"id": 3,
		"label": "[HR / COMPLIANCE]  Template 04",
		"subject": "Employee Welfare Check — Confidential",
		"blanks": [
			{"key": "TARGET_NAME",       "prompt": "Target's full name"},
			{"key": "EMPLOYEE_NAME",     "prompt": "Employee name (subject of enquiry)"},
			{"key": "COMPANY_NAME",      "prompt": "Company name"},
			{"key": "SENDER_ORG",        "prompt": "Your organisation"},
			{"key": "SENDER_NAME",       "prompt": "Your name (GhostWire identity)"},
			{"key": "SENDER_TITLE",      "prompt": "Your job title"},
			{"key": "REQUEST",           "prompt": "What you are asking them to share"},
		],
		"body": """Dear [TARGET_NAME],

I'm writing confidentially in relation to a welfare concern involving [EMPLOYEE_NAME], who was employed at [COMPANY_NAME].

We are conducting a routine follow-up and would appreciate any information you are able to share about [REQUEST].

Please be assured that this communication is entirely confidential and is not related to any disciplinary matter.

Kind regards,
[SENDER_NAME]
[SENDER_TITLE]
[SENDER_ORG]"""
	},
	{
		"id": 4,
		"label": "[PRESS ENQUIRY]  Template 05",
		"subject": "Press Enquiry — [PUBLICATION]",
		"blanks": [
			{"key": "TARGET_NAME",       "prompt": "Target's full name"},
			{"key": "PUBLICATION",       "prompt": "Publication name"},
			{"key": "SENDER_NAME",       "prompt": "Your name (GhostWire identity)"},
			{"key": "SENDER_ROLE",       "prompt": "Your role (e.g. Journalist, Editor)"},
			{"key": "COMPANY_NAME",      "prompt": "Company being enquired about"},
			{"key": "TOPIC",             "prompt": "Topic of the piece"},
			{"key": "SPECIFIC_AREA",     "prompt": "Specific area of questioning"},
			{"key": "REQUEST",           "prompt": "What you are asking them to confirm"},
			{"key": "DEADLINE",          "prompt": "Publication deadline"},
		],
		"body": """Dear [TARGET_NAME],

My name is [SENDER_NAME] and I'm a [SENDER_ROLE] at [PUBLICATION]. I'm currently working on a piece about [TOPIC].

I wanted to give [COMPANY_NAME] the opportunity to respond to a number of questions before publication. These relate to [SPECIFIC_AREA].

Could you confirm [REQUEST], or direct me to the appropriate press contact?

We are working to a deadline of [DEADLINE].

Regards,
[SENDER_NAME]
[PUBLICATION]"""
	},
	{
		"id": 5,
		"label": "[PERSONAL]  Template 06",
		"subject": "",
		"blanks": [],
		"body": ""
	},
]

# ── Valid GhostWire identities ─────────────────
const VALID_IDENTITIES := ["sarah chen", "lee morgan"]

# ── Known strings for outcome evaluation ───────
const KNOWN_COMPANIES := ["helix solutions", "holt-vane", "shieldhost", "vaultpay"]
const KNOWN_PEOPLE    := ["nadia webb", "diane marsh", "kane", "patricia cole", "james fairfax", "sarah chen", "lee morgan"]
const KNOWN_SYSTEMS   := ["helix_audit_archive", "archive", "shieldhost", "185.220", "internal.helixsolutions", "nw_private"]

# ── Flagged contacts (persistent this session) ─
var flagged_contacts: Array[String] = []

# ── Engagement log ─────────────────────────────
var log_entries: Array[Dictionary] = []

# ── Current template state ─────────────────────
var current_template_id: int = -1
var blank_fields: Array = []

# ── Colour constants ───────────────────────────
const C_GREEN := "[color=#00ff41]"
const C_AMBER := "[color=#ffb000]"
const C_RED   := "[color=#ff3333]"
const C_DIM   := "[color=#4a4a4a]"
const C_WHITE := "[color=#cccccc]"
const C_CLOSE := "[/color]"

# ══════════════════════════════════════════════
func _ready() -> void:
	app_name = "SENET"
	super._ready()
	_populate_template_list()
	template_list.item_selected.connect(_on_template_selected)
	send_btn.pressed.connect(_on_send_pressed)
	log_list.item_selected.connect(_on_log_selected)
	validation_label.text = ""
	send_btn.disabled = true
	_show_placeholder()

# ── Template list ──────────────────────────────
func _populate_template_list() -> void:
	template_list.clear()
	for t in TEMPLATES:
		template_list.add_item(t["label"])

func _on_template_selected(index: int) -> void:
	current_template_id = index
	_build_compose(TEMPLATES[index])

func _build_compose(template: Dictionary) -> void:
	for child in body_container.get_children():
		child.queue_free()
	blank_fields.clear()
	validation_label.text = ""

	subject_field.text     = template["subject"]
	subject_field.editable = (template["id"] == 5)

	if template["id"] == 5:
		_add_label(body_container, "MESSAGE BODY")
		var body_edit := TextEdit.new()
		body_edit.placeholder_text       = "Write your message here..."
		body_edit.custom_minimum_size    = Vector2(0, 260)
		body_edit.size_flags_vertical    = Control.SIZE_EXPAND_FILL
		body_edit.wrap_mode              = TextEdit.LINE_WRAPPING_BOUNDARY
		_style_text_edit(body_edit)
		body_container.add_child(body_edit)
		blank_fields.append(body_edit)
	else:
		_add_label(body_container, "FILL IN THE BLANKS")
		for blank in template["blanks"]:
			var row  := HBoxContainer.new()
			var lbl  := Label.new()
			lbl.text = blank["key"] + ":"
			lbl.custom_minimum_size = Vector2(180, 0)
			lbl.add_theme_color_override("font_color", Color(0.0, 1.0, 0.255, 1))
			lbl.add_theme_font_size_override("font_size", 12)
			row.add_child(lbl)

			var field := LineEdit.new()
			field.placeholder_text       = blank["prompt"]
			field.size_flags_horizontal  = Control.SIZE_EXPAND_FILL
			_style_line_edit(field)
			field.set_meta("blank_key", blank["key"])
			row.add_child(field)
			body_container.add_child(row)
			blank_fields.append(field)

		var sep := HSeparator.new()
		sep.add_theme_color_override("color", Color(0.0, 0.4, 0.1, 1))
		body_container.add_child(sep)

		_add_label(body_container, "TEMPLATE PREVIEW")
		var preview := RichTextLabel.new()
		preview.bbcode_enabled = true
		preview.fit_content    = true
		preview.text           = C_DIM + template["body"] + C_CLOSE
		preview.add_theme_font_size_override("font_size", 11)
		body_container.add_child(preview)

	send_btn.disabled = false

# ── Send ───────────────────────────────────────
func _on_send_pressed() -> void:
	var to_addr := to_field.text.strip_edges().to_lower()
	var from_id := from_field.text.strip_edges().to_lower()
	var subj    := subject_field.text.strip_edges()

	if to_addr.is_empty() or from_id.is_empty() or subj.is_empty():
		_set_validation("[!] TO, FROM, and SUBJECT fields are required.", true)
		return

	if not "@" in to_addr:
		_set_validation("[!] TO field must be a valid email address.", true)
		return

	var identity_valid := false
	for id in VALID_IDENTITIES:
		if from_id.contains(id):
			identity_valid = true
			break
	if not identity_valid:
		_set_validation("[!] GhostWire: Identity not recognised. Run 'ghostwire --list' in the terminal.", true)
		return

	if to_addr in flagged_contacts:
		_set_validation("[!] This contact has been flagged — prior contact detected. No response expected.", true)
		return

	var all_filled := true
	var body_text  := ""

	if current_template_id == 5:
		if blank_fields.size() > 0 and blank_fields[0] is TextEdit:
			body_text = blank_fields[0].text.strip_edges()
			if body_text.is_empty():
				all_filled = false
	else:
		var filled_body: String = TEMPLATES[current_template_id]["body"]
		for field in blank_fields:
			if field is LineEdit:
				var key := str(field.get_meta("blank_key"))
				var val: String = field.text.strip_edges()
				if val.is_empty():
					all_filled = false
				filled_body = filled_body.replace("[" + key + "]", val if not val.is_empty() else "[___]")
		body_text = filled_body

	if not all_filled:
		_set_validation("[!] Template incomplete — missing fields will weaken the approach.", false)

	var outcome := _evaluate_outcome(to_addr, from_id, body_text)

	var entry := {
		"to":        to_addr,
		"from":      from_field.text.strip_edges(),
		"subject":   subj,
		"body":      body_text,
		"template":  current_template_id,
		"outcome":   outcome["status"],
		"response":  outcome["response"],
		"timestamp": Time.get_datetime_string_from_system(),
	}
	log_entries.append(entry)
	_refresh_log()
	_apply_outcome(to_addr, outcome)
	_set_validation("[OK] Message sent. Awaiting response...", false)
	GlobalSignals.senet_engagement_sent.emit(to_addr, current_template_id)

# ── Outcome evaluation ─────────────────────────
func _evaluate_outcome(to: String, from_id: String, body: String) -> Dictionary:
	var body_lower := body.to_lower()
	var score      := 0

	if current_template_id == 0 and from_id.contains("sarah chen"): score += 2
	if current_template_id == 1 and from_id.contains("lee morgan"):  score += 2
	if current_template_id == 3 and from_id.contains("lee morgan"):  score += 2
	if current_template_id == 4:                                      score += 1

	for s in KNOWN_COMPANIES:
		if body_lower.contains(s): score += 1
	for s in KNOWN_PEOPLE:
		if body_lower.contains(s): score += 1
	for s in KNOWN_SYSTEMS:
		if body_lower.contains(s): score += 2

	var status        := ""
	var response_text := ""

	if "d.marsh" in to:
		if current_template_id == 5 and score >= 4:
			status = "SUCCESS_RICH"; response_text = _diane_personal_response()
		elif score >= 3:
			status = "SUCCESS";      response_text = _diane_audit_response()
		elif score >= 1:
			status = "PARTIAL";      response_text = _diane_partial_response()
		else:
			status = "FLAGGED";      response_text = _diane_flagged_response()

	elif "sysadmin" in to:
		if current_template_id == 0 and from_id.contains("sarah chen") and score >= 4:
			status = "SUCCESS";      response_text = _sysadmin_success_response()
		elif current_template_id == 0 and score >= 2:
			status = "PARTIAL";      response_text = _sysadmin_partial_response()
		else:
			status = "NO_RESPONSE";  response_text = "[System] No response received."

	elif "p.cole" in to:
		if score >= 3:
			status = "PARTIAL";      response_text = _patricia_response()
		else:
			status = "NO_RESPONSE";  response_text = "[System] No response received."

	elif "d.kane" in to:
		status = "NO_RESPONSE"
		response_text = "[System] No response received.\n\n[!] Note: Alert activity detected on target's servers shortly after send."

	elif "helixsolutions.com" in to:
		if score >= 3:
			status = "PARTIAL"
			response_text = "[Helix Solutions]\nThank you for your email. Your message has been passed to the relevant team."
		else:
			status = "NO_RESPONSE";  response_text = "[System] No response received."

	else:
		status = "NO_RESPONSE";      response_text = "[System] No response received. Unknown domain."

	return {"status": status, "response": response_text}

# ── Response strings ───────────────────────────
func _diane_audit_response() -> String:
	return """FROM: d.marsh@helixsolutions.com

Hi,

I'm not sure I should be responding to this, but I will.

Yes, Nadia was working on the audit archive project. She'd been on it for about three months. Towards the end she seemed distracted — stressed. She mentioned once that she thought some of the numbers didn't add up, but I told her she was probably misreading the scope.

I wish I'd taken it more seriously.

The database she was working on was called helix_audit_archive. I don't know if that helps.

I don't know who you are or what this review is actually about. But if something happened to Nadia because of what she found — I'd rather you knew.

Please don't contact me again at this address.

Diane"""

func _diane_personal_response() -> String:
	return """FROM: d.marsh@helixsolutions.com

I don't know who you are. I'm not sure why I'm replying.

Nadia mentioned the audit archive to me once — she said there was a column in the Q3 reconciliation that showed transfers to an external account she didn't recognise. She'd been checking it for weeks. She was careful. She didn't say anything to management because she wanted to be sure first.

Three weeks before she disappeared she stopped talking about it. I thought she'd dropped it.

I should have asked.

Do you know where she is? I keep checking the news.

Please find her.

Diane"""

func _diane_partial_response() -> String:
	return """FROM: d.marsh@helixsolutions.com

Hello,

I'm afraid I'm not in a position to comment on internal project matters.

If this relates to a formal audit process, please contact our compliance team directly.

Diane Marsh
Senior Analyst, Helix Solutions Ltd."""

func _diane_flagged_response() -> String:
	return """FROM: d.marsh@helixsolutions.com

Please do not contact me.

I've already been approached about this and I don't want to be involved. If there's an actual investigation, it needs to go through proper channels.

I'm not responding further."""

func _sysadmin_success_response() -> String:
	return """FROM: sysadmin@helixsolutions.com

Hi Sarah,

I don't have a record of this ticket in our system — can you check which helpdesk this was logged through? We migrated most of the infrastructure to the new ShieldHost instance last month (185.220.101.x range), so if it's related to the pre-migration environment that might be why it's not showing.

Let me know and I'll look into it.

Thanks"""

func _sysadmin_partial_response() -> String:
	return """FROM: sysadmin@helixsolutions.com

Hi,

I'm not finding this in our system. Can you raise it again through the normal helpdesk portal? I don't handle external requests directly.

Thanks"""

func _patricia_response() -> String:
	return """FROM: p.cole@helixsolutions.com

Dear Mr Morgan,

Thank you for your enquiry. I can confirm that Nadia Webb was employed within our data and compliance division. Any matters relating to her employment status would need to be directed to our HR function.

I'm not in a position to discuss individual cases further.

Kind regards,
Patricia Cole
Head of Client Services
Helix Solutions Ltd."""

# ── Apply consequences ─────────────────────────
func _apply_outcome(to: String, outcome: Dictionary) -> void:
	if outcome["status"] == "FLAGGED":
		flagged_contacts.append(to)
		GlobalSignals.senet_contact_flagged.emit(to)
		if "helixsolutions.com" in to:
			GlobalSignals.tier1_triggered.emit(null)

	if outcome["status"] == "NO_RESPONSE" and "d.kane" in to:
		GlobalSignals.tier1_triggered.emit(null)

	GlobalSignals.senet_response_received.emit(to, outcome["status"])

# ── Log UI ─────────────────────────────────────
func _refresh_log() -> void:
	log_list.clear()
	for i in range(log_entries.size() - 1, -1, -1):
		var entry := log_entries[i]
		log_list.add_item(_status_display(entry["outcome"]) + "  →  " + entry["to"])
	if log_list.item_count > 0:
		log_placeholder.hide()
		log_list.select(0)
		_on_log_selected(0)
	else:
		log_placeholder.show()
		log_detail.text = ""

func _on_log_selected(index: int) -> void:
	var real_index := (log_entries.size() - 1) - index
	if real_index < 0 or real_index >= log_entries.size():
		return
	var entry  := log_entries[real_index]
	var detail := ""
	detail += C_DIM  + entry["timestamp"] + C_CLOSE + "\n"
	detail += C_GREEN + "TO:      " + C_CLOSE + entry["to"]      + "\n"
	detail += C_GREEN + "FROM:    " + C_CLOSE + entry["from"]    + "\n"
	detail += C_GREEN + "SUBJECT: " + C_CLOSE + entry["subject"] + "\n"
	detail += C_GREEN + "STATUS:  " + C_CLOSE + _status_color(entry["outcome"]) + _status_display(entry["outcome"]) + C_CLOSE + "\n"
	detail += "\n" + C_DIM + "─────────────────────────────────\n" + C_CLOSE
	detail += C_WHITE + entry["response"] + C_CLOSE
	log_detail.bbcode_enabled = true
	log_detail.text           = detail

func _status_display(status: String) -> String:
	match status:
		"SUCCESS", "SUCCESS_RICH": return "RESPONDED"
		"PARTIAL":                 return "PARTIAL"
		"FLAGGED":                 return "FLAGGED"
		"NO_RESPONSE":             return "NO RESPONSE"
		_:                         return "PENDING"

func _status_color(status: String) -> String:
	match status:
		"SUCCESS", "SUCCESS_RICH": return C_GREEN
		"PARTIAL":                 return C_AMBER
		"FLAGGED":                 return C_RED
		_:                         return C_DIM

# ── UI helpers ─────────────────────────────────
func _show_placeholder() -> void:
	for child in body_container.get_children():
		child.queue_free()
	blank_fields.clear()
	var lbl := Label.new()
	lbl.text = "← Select a template to begin."
	lbl.add_theme_color_override("font_color", Color(0.45, 0.45, 0.45, 1))
	lbl.add_theme_font_size_override("font_size", 13)
	body_container.add_child(lbl)

func _set_validation(msg: String, is_error: bool) -> void:
	validation_label.text = msg
	validation_label.add_theme_color_override("font_color",
		Color(1.0, 0.2, 0.2, 1) if is_error else Color(0.0, 1.0, 0.255, 1))

func _add_label(parent: Control, text: String) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_color_override("font_color", Color(0.0, 1.0, 0.255, 0.6))
	lbl.add_theme_font_size_override("font_size", 11)
	parent.add_child(lbl)

func _style_line_edit(field: LineEdit) -> void:
	field.add_theme_color_override("font_color",             Color(0.8, 0.8, 0.8, 1))
	field.add_theme_color_override("font_placeholder_color", Color(0.35, 0.35, 0.35, 1))
	field.add_theme_color_override("caret_color",            Color(0.0, 1.0, 0.255, 1))
	field.add_theme_font_size_override("font_size", 12)

func _style_text_edit(field: TextEdit) -> void:
	field.add_theme_color_override("font_color",             Color(0.8, 0.8, 0.8, 1))
	field.add_theme_color_override("font_placeholder_color", Color(0.35, 0.35, 0.35, 1))
	field.add_theme_color_override("caret_color",            Color(0.0, 1.0, 0.255, 1))
	field.add_theme_font_size_override("font_size", 12)
