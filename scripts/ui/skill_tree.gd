extends PanelContainer

signal closed
const Vintage = preload("res://scripts/ui/vintage_theme.gd")
var graph: Control
var nodes: Dictionary = {}
var links: Array = []

class BranchGraph extends Control:
	var links: Array = []
	func _draw() -> void:
		for link: Array in links:
			var a: Vector2 = link[0]
			var b: Vector2 = link[1]
			if a.y < 36:
				var corner: Vector2 = Vector2(a.x, 30)
				draw_line(a, corner, Color("68717d"), 2)
				draw_line(corner, Vector2(b.x, 30), Color("68717d"), 2)
				draw_line(Vector2(b.x, 30), b, Color("68717d"), 2)
			else:
				var lane: float = a.x + 64
				draw_polyline(PackedVector2Array([a, Vector2(lane, a.y + 3), Vector2(lane, b.y - 4), Vector2(b.x, b.y - 4), b]), Color("68717d"), 2)

func setup(history: Array, definitions: Array, offered: Array = []) -> void:
	theme = Vintage.make()
	position = Vector2(234, 54)
	size = Vector2(684, 612)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var body: VBoxContainer = VBoxContainer.new()
	body.add_theme_constant_override("separation", 8)
	add_child(body)
	var title: Label = Label.new()
	title.text = "  ÁRBOL DE HABILIDADES"
	title.add_theme_stylebox_override("normal", _title_style())
	title.add_theme_color_override("font_color", Color.WHITE)
	body.add_child(title)
	var legend: Label = Label.new()
	legend.text = "● Adquirida   ○ Disponible   ◇ Ofrecida   × Bloqueada\nRamas combinables · una mejora por oleada · pasa el cursor para ver detalles"
	legend.add_theme_font_size_override("font_size", 12)
	body.add_child(legend)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(660, 490)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(scroll)
	graph = BranchGraph.new()
	graph.custom_minimum_size = Vector2(650, 500)
	scroll.add_child(graph)
	var root: Label = Label.new()
	root.text = "EL ARQUERO"
	root.position = Vector2(257, 2)
	root.size = Vector2(130, 24)
	root.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	graph.add_child(root)
	var categories: Array = ["arco", "flechas", "movilidad", "economia", "torre"]
	var positions: Dictionary = {}
	var row_counts: Dictionary = {}
	for category: String in categories:
		var column: int = categories.find(category)
		var label: Label = Label.new()
		label.text = "RECOGIDA" if category == "economia" else category.to_upper()
		label.position = Vector2(column * 130 + 3, 38)
		label.add_theme_font_size_override("font_size", 12)
		graph.add_child(label)
		links.append([Vector2(322, 26), Vector2(column * 130 + 62, 36)])
	for item: Dictionary in definitions:
		var category: String = str(item.category)
		var column: int = categories.find(category)
		var row: int = int(row_counts.get(category, 0))
		row_counts[category] = row + 1
		var at: Vector2 = Vector2(column * 130 + 3, 62 + row * 68)
		positions[str(item.id)] = at
		var count: int = history.count(str(item.id))
		var unlocked: bool = true
		var requirement_names: Array[String] = []
		for prerequisite: String in item.get("requires", []):
			unlocked = unlocked and history.has(prerequisite)
			for parent: Dictionary in definitions:
				if str(parent.id) == prerequisite: requirement_names.append(str(parent.name))
		var state: String = "ADQUIRIDA" if count > 0 else ("OFRECIDA" if offered.has(str(item.id)) else ("DISPONIBLE" if unlocked else "BLOQUEADA"))
		var symbol: String = "●" if count > 0 else ("◇" if state == "OFRECIDA" else ("○" if unlocked else "×"))
		var button: Button = Button.new()
		button.text = "%s %s\n%d/%d" % [symbol, str(item.name), count, int(item.max_rank)]
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.add_theme_font_size_override("font_size", 11)
		button.position = at
		button.size = Vector2(122, 56)
		button.focus_mode = Control.FOCUS_NONE
		button.tooltip_text = "%s · %d/%d\n%s\n%s" % [state, count, int(item.max_rank), str(item.description), "Inicio de rama" if requirement_names.is_empty() else "Requiere: " + ", ".join(requirement_names)]
		button.add_theme_color_override("font_color", Color("174c35") if count > 0 else (Color("64398c") if state == "OFRECIDA" else (Color("20242a") if unlocked else Color("74777c"))))
		graph.add_child(button)
		nodes[str(item.id)] = button
	for item: Dictionary in definitions:
		var at: Vector2 = positions[str(item.id)]
		var requirements: Array = item.get("requires", [])
		if requirements.is_empty():
			links.append([Vector2(at.x + 61, 51), at + Vector2(61, 0)])
		for prerequisite: String in requirements:
			if positions.has(prerequisite):
				links.append([positions[prerequisite] + Vector2(61, 56), at + Vector2(61, 0)])
	graph.links = links
	graph.queue_redraw()
	var close: Button = Button.new()
	close.text = "VOLVER AL QUESO"
	close.pressed.connect(func(): closed.emit())
	body.add_child(close)

func _title_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("182e57")
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	return style

