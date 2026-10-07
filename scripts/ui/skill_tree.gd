extends PanelContainer

signal closed
const Vintage = preload("res://scripts/ui/vintage_theme.gd")
var graph: Control
var nodes: Dictionary = {}
var links: Array = []
var _children: Dictionary = {}
var _layout: Dictionary = {}
var _leaf: float = 0.0

func _place(id: String, depth: int) -> float:
	var descendants: Array = _children.get(id,[])
	var x: float
	if descendants.is_empty():
		x = 90.0 + _leaf * 172.0
		_leaf += 1.0
	else:
		var positions: Array[float] = []
		for child: String in descendants: positions.append(_place(child,depth+1))
		x = (positions.front()+positions.back())*0.5
	_layout[id] = Vector2(x-70,104+depth*104)
	return x

class BranchGraph extends Control:
	var links: Array = []
	func _draw() -> void:
		for link: Array in links:
			var a: Vector2 = link[0]
			var b: Vector2 = link[1]
			var tint: Color = link[2] if link.size()>2 else Color("68717d")
			var middle: float = (a.y+b.y)*0.5
			draw_polyline(PackedVector2Array([a,Vector2(a.x,middle),Vector2(b.x,middle),b]),tint,2)

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
	legend.text = "* Adquirida   o Disponible   + Ofrecida   × Bloqueada\nDesplaza el árbol <-> · ramas combinables · pasa el cursor para ver detalles"
	legend.add_theme_font_size_override("font_size", 12)
	body.add_child(legend)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(660, 490)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(scroll)
	graph = BranchGraph.new()
	for item: Dictionary in definitions:
		var requirements: Array = item.get("requires",[])
		if not requirements.is_empty():
			var parent: String = str(requirements[0])
			if not _children.has(parent): _children[parent] = []
			_children[parent].append(str(item.id))
	var roots: Array[String] = []
	for category: String in ["arco","flechas","movilidad","economia","torre"]:
		for item: Dictionary in definitions:
			if str(item.category)==category and item.get("requires",[]).is_empty():
				roots.append(str(item.id))
				_place(str(item.id),0)
	graph.custom_minimum_size = Vector2(maxf(650,_leaf*172+8),550)
	scroll.add_child(graph)
	var root: Label = Label.new()
	root.text = "EL ARQUERO"
	var center: float = graph.custom_minimum_size.x*0.5
	root.position = Vector2(center-65, 2)
	root.size = Vector2(130, 24)
	root.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	graph.add_child(root)
	var categories: Array = ["arco", "flechas", "movilidad", "economia", "torre"]
	var positions: Dictionary = {}
	for category: String in categories:
		var root_id: String = ""
		for item: Dictionary in definitions:
			if str(item.category)==category and roots.has(str(item.id)): root_id = str(item.id); break
		if root_id.is_empty(): continue
		var branch_at: Vector2 = _layout[root_id]
		var label: Label = Label.new()
		label.text = "RECOGIDA" if category == "economia" else category.to_upper()
		label.position = branch_at+Vector2(0,-23)
		label.add_theme_font_size_override("font_size", 12)
		graph.add_child(label)
		links.append([Vector2(center,26),branch_at+Vector2(70,-28),Color("254b50")])
	for item: Dictionary in definitions:
		var category: String = str(item.category)
		var at: Vector2 = _layout[str(item.id)]
		positions[str(item.id)] = at
		var count: int = history.count(str(item.id))
		var unlocked: bool = true
		var requirement_names: Array[String] = []
		for prerequisite: String in item.get("requires", []):
			unlocked = unlocked and history.has(prerequisite)
			for parent: Dictionary in definitions:
				if str(parent.id) == prerequisite: requirement_names.append(str(parent.name))
		var state: String = "ADQUIRIDA" if count > 0 else ("OFRECIDA" if offered.has(str(item.id)) else ("DISPONIBLE" if unlocked else "BLOQUEADA"))
		var symbol: String = "*" if count > 0 else ("+" if state == "OFRECIDA" else ("o" if unlocked else "×"))
		var button: Button = Button.new()
		button.text = "%s %s\n%d/%d" % [symbol, str(item.name), count, int(item.max_rank)]
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.add_theme_font_size_override("font_size", 11)
		button.position = at
		button.size = Vector2(140, 60)
		button.focus_mode = Control.FOCUS_NONE
		button.tooltip_text = "%s · %d/%d\n%s\n%s" % [state, count, int(item.max_rank), str(item.description), "Inicio de rama" if requirement_names.is_empty() else "Requiere: " + ", ".join(requirement_names)]
		button.add_theme_color_override("font_color", Color("174c35") if count > 0 else (Color("64398c") if state == "OFRECIDA" else (Color("20242a") if unlocked else Color("74777c"))))
		graph.add_child(button)
		nodes[str(item.id)] = button
	for item: Dictionary in definitions:
		var at: Vector2 = positions[str(item.id)]
		var requirements: Array = item.get("requires", [])
		if requirements.is_empty():
			links.append([at+Vector2(70,-20),at+Vector2(70,0)])
		for prerequisite: String in requirements:
			if positions.has(prerequisite):
				var tint: Color = Color("31855c") if history.has(str(item.id)) else (Color("9952be") if offered.has(str(item.id)) else Color("68717d"))
				links.append([positions[prerequisite] + Vector2(70,60), at + Vector2(70,0),tint])
	graph.links = links
	graph.queue_redraw()
	scroll.set_deferred("scroll_horizontal",maxi(0,int(center-330)))
	var close: Button = Button.new()
	close.text = "VOLVER"
	close.pressed.connect(func(): closed.emit())
	body.add_child(close)

func _title_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("182e57")
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	return style

