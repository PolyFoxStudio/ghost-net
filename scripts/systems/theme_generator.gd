extends SceneTree

func _init():
	var theme = Theme.new()
	
	var font = SystemFont.new()
	font.font_names = ["JetBrains Mono", "Courier New", "Consolas", "monospace"]
	theme.default_font = font
	theme.default_font_size = 13
	
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color("#0a0a0a")
	theme.set_stylebox("panel", "PanelContainer", bg_style)
	theme.set_stylebox("panel", "Panel", bg_style)
	
	ResourceSaver.save(theme, "res://resources/themes/ghostnet_theme.tres")
	
	print("Theme saved.")
	quit()
