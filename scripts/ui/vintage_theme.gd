extends RefCounted

static func make() -> Theme:
	var result: Theme = Theme.new()
	result.default_font_size = 14
	for state: String in ["normal", "hover", "pressed", "disabled", "focus"]:
		var style: StyleBoxFlat = StyleBoxFlat.new()
		style.bg_color = Color("d9dfd7") if state != "pressed" else Color("aeb8ad")
		if state == "hover": style.bg_color = Color("eef0df")
		if state == "disabled": style.bg_color = Color("bbc2b8")
		style.border_color = Color("fcfff1") if state != "pressed" else Color("4e6058")
		style.set_border_width_all(2)
		style.shadow_color = Color("334c48")
		style.shadow_size = 2
		style.shadow_offset = Vector2(2,2)
		for edge: String in ["left", "right", "top", "bottom"]:
			style.set("content_margin_" + edge, 8.0)
		result.set_stylebox(state, "Button", style)
		result.set_color("font_" + state + "_color", "Button", Color("243b3b"))
	result.set_color("font_color", "Button", Color("243b3b"))
	result.set_color("font_color", "Label", Color("243b3b"))
	result.set_color("font_color", "CheckButton", Color("243b3b"))
	var panel: StyleBoxFlat = StyleBoxFlat.new()
	panel.bg_color = Color("c6cec3")
	panel.border_color = Color("f6f9e9")
	panel.set_border_width_all(2)
	panel.shadow_color = Color("213c38")
	panel.shadow_size = 4
	panel.shadow_offset = Vector2(4,4)
	for edge: String in ["left", "right", "top", "bottom"]:
		panel.set("content_margin_" + edge, 14.0)
	result.set_stylebox("panel", "PanelContainer", panel)
	return result
