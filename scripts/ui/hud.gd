extends Control

signal buy_ammo_requested
signal repair_requested
signal next_wave_requested
signal upgrade_requested(id: String)
signal restart_requested
signal effects_toggled(enabled: bool)
signal audio_toggled(enabled: bool)

const CHEESE: Color = Color("ffd775")
const MUTED: Color = Color("a6bfb1")
var message: Label
var _prototype: bool = false
var _hp: ProgressBar
var _cheese: ProgressBar
var _hp_label: Label
var _cheese_label: Label
var _status: Label
var _charge_label: Label
var _charge: ChargeGauge
var _mount_label: Label
var _ammo_buy: Button
var _repair: Button
var _next: Button
var _offers: VBoxContainer
var _offer_scroll: ScrollContainer
var _game_over: PanelContainer
var _toast_left: float = 0.0

class ChargeGauge extends Control:
	var time: float = 0.0
	var tint: Color = Color("ff9b42")
	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color("233139"))
		draw_rect(Rect2(0, 0, size.x * clampf(time / 2.2, 0, 1), size.y), tint)
		var green: Rect2 = Rect2(size.x * 0.85 / 2.2, 0, size.x * 0.13 / 2.2, size.y)
		draw_rect(green, Color("91ed70"), false, 2.0)

func setup(is_prototype: bool) -> void:
	_prototype = is_prototype
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var ui_theme: Theme = Theme.new()
	ui_theme.default_font_size = 15
	var normal: StyleBoxFlat = StyleBoxFlat.new()
	normal.bg_color = Color("273a42")
	normal.border_color = Color("537068")
	normal.set_border_width_all(1)
	for side in ["left", "right", "top", "bottom"]:
		normal.set("content_margin_" + side, 8.0)
	for state in ["normal", "hover", "pressed", "disabled"]:
		var style: StyleBoxFlat = normal.duplicate()
		if state == "hover": style.bg_color = Color("42685b")
		if state == "pressed": style.bg_color = Color("b48242")
		if state == "disabled": style.bg_color = Color("19282e")
		ui_theme.set_stylebox(state, "Button", style)
	theme = ui_theme
	var left: VBoxContainer = _panel(0)
	_title(left, "CHEESE\nKEEP", 26, CHEESE)
	_title(left, "LA ÚLTIMA CORTEZA", 11, Color("83ab9a"))
	_hp_label = _title(left, "ARQUERO", 14, MUTED)
	_hp = _bar(left, Color("a5d485"))
	_cheese_label = _title(left, "QUESO", 14, CHEESE)
	_cheese = _bar(left, CHEESE)
	_cheese_label.visible = not _prototype
	_cheese.visible = not _prototype
	_status = _title(left, "", 16, Color("e9e6d1"))
	_mount_label = _title(left, "", 13, CHEESE)
	_charge_label = _title(left, "LISTO", 16, CHEESE)
	_charge = ChargeGauge.new()
	_charge.custom_minimum_size = Vector2(0, 14)
	_charge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	left.add_child(_charge)
	_title(left, "VERDE 0,85–0,98 s: crítico\nROJO: penetra; puede romper", 12, MUTED)
	_title(left, "IZQUIERDO: caminar\nDERECHO: mantener carga\nSOLTAR DERECHO: disparar\nTORRE / SUELO: subir / bajar", 13, MUTED)
	var help: Label = _title(left, "Cargar ralentiza.\nTorre: inmune; queso +50 %.\nTienda sin pausa.\nEntre oleadas: elige y compra.", 12, MUTED)
	help.visible = false
	var tutorial: Button = _button(left, "AYUDA", func(): help.visible = not help.visible)
	tutorial.tooltip_text = "Mostrar u ocultar consejos"
	var right: VBoxContainer = _panel(936)
	_title(right, "EL ARCO" if _prototype else "PROVISIONES", 21, CHEESE)
	if _prototype:
		_title(right, "NARANJA\nCorto, impreciso\n\nVERDE\nCrítico: ¡suelta!\n\nROJO\nPenetra, pero arriesga\nrotura de cuerda", 14, MUTED)
		_button(right, "REINICIAR PRUEBA", func(): restart_requested.emit())
	else:
		_ammo_buy = _button(right, "10 FLECHAS · 6 MONEDAS", func(): buy_ammo_requested.emit())
		_repair = _button(right, "+30 QUESO · 12 MONEDAS", func(): repair_requested.emit())
		_title(right, "Comprar no pausa el combate", 12, MUTED)
		_next = _button(right, "EMPEZAR OLEADA", func(): next_wave_requested.emit())
		_offer_scroll = ScrollContainer.new()
		_offer_scroll.custom_minimum_size.y = 280
		_offer_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		_offer_scroll.visible = false
		right.add_child(_offer_scroll)
		_offers = VBoxContainer.new()
		_offers.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_offers.add_theme_constant_override("separation", 8)
		_offer_scroll.add_child(_offers)
	var effects: CheckButton = _toggle(right, "EFECTOS", true)
	effects.toggled.connect(func(enabled: bool): effects_toggled.emit(enabled))
	var audio: CheckButton = _toggle(right, "SONIDO", true)
	audio.toggled.connect(func(enabled: bool): audio_toggled.emit(enabled))
	message = _title(right, "", 13, CHEESE)

func update_status(data: Dictionary) -> void:
	if _hp == null: return
	_hp.max_value = maxf(1, float(data.get("max_hp", 100)))
	_hp.value = float(data.get("hp", 100))
	_hp_label.text = "ARQUERO %d / %d" % [int(_hp.value), int(_hp.max_value)]
	_cheese.max_value = maxf(1, float(data.get("tower_max", 200)))
	_cheese.value = float(data.get("tower_hp", 200))
	_cheese_label.text = "QUESO %d / %d" % [int(_cheese.value), int(_cheese.max_value)]
	var phase: String = str(data.get("phase", "PREP"))
	var alive: bool = bool(data.get("alive", true))
	var mounted: bool = bool(data.get("mounted", false))
	if _prototype:
		_status.text = "CAMPO DE PRUEBAS\nRatas: %d" % int(data.get("kills", 0))
	else:
		_status.text = "OLEADA %d\nFlechas: %d\nMonedas: %d\nBajas: %d · %s" % [int(data.get("wave", 1)), int(data.get("ammo", 0)), int(data.get("coins", 0)), int(data.get("kills", 0)), _time_text(float(data.get("elapsed", 0)))]
	_mount_label.text = "REFUGIO: QUESO +50 % DAÑO" if mounted else ""
	if not alive: _mount_label.text = "REVIVES EN %.1f s" % float(data.get("respawn_left", 0))
	var bow: Dictionary = data.get("bow", {})
	_charge_label.text = "%s · %.2f s" % [str(bow.get("state_label", "LISTO")), float(bow.get("charge", 0))]
	var color: Color = bow.get("color", CHEESE)
	_charge_label.add_theme_color_override("font_color", color)
	_charge.time = float(bow.get("charge", 0))
	_charge.tint = color
	_charge.queue_redraw()
	if str(bow.get("state_label", "")) == "REPARANDO":
		_charge_label.text = "REPARANDO · %.1f s" % float(bow.get("cooldown", 0))
	if not _prototype:
		_ammo_buy.disabled = int(data.get("coins", 0)) < 6 or phase == "OVER"
		_repair.disabled = int(data.get("coins", 0)) < 12 or _cheese.value >= _cheese.max_value or phase == "OVER"
		_next.visible = phase == "PREP" or phase == "CHOICE"
		_next.disabled = phase != "PREP"
		_next.text = "ELIGE UNA MEJORA" if phase == "CHOICE" else "EMPEZAR OLEADA"

func toast(text: String) -> void:
	if message == null: return
	message.text = text
	_toast_left = 3.5

func _process(delta: float) -> void:
	if _toast_left > 0:
		_toast_left -= delta
		if _toast_left <= 0 and message != null: message.text = ""

func show_offers(offers: Array[Dictionary]) -> void:
	clear_offers()
	if _offers == null: return
	_offer_scroll.visible = not offers.is_empty()
	for offer in offers:
		var id: String = str(offer.get("id", ""))
		var button: Button = _button(_offers, str(offer.get("name", id)) + "\n" + str(offer.get("description", "")), func(): upgrade_requested.emit(id))
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.custom_minimum_size = Vector2(172, 64)
		button.tooltip_text = str(offer.get("description", ""))

func clear_offers() -> void:
	if _offers != null:
		for child in _offers.get_children():
			_offers.remove_child(child)
			child.queue_free()
		_offer_scroll.visible = false
	if is_instance_valid(_game_over):
		_game_over.queue_free()
		_game_over = null

func show_game_over(data: Dictionary) -> void:
	clear_offers()
	_game_over = PanelContainer.new()
	_game_over.position = Vector2(336, 180)
	_game_over.size = Vector2(480, 360)
	var background: StyleBoxFlat = StyleBoxFlat.new()
	background.bg_color = Color("13272b")
	background.border_color = CHEESE
	background.set_border_width_all(3)
	for side in ["left", "right", "top", "bottom"]: background.set("content_margin_" + side, 24.0)
	_game_over.add_theme_stylebox_override("panel", background)
	add_child(_game_over)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	_game_over.add_child(box)
	_title(box, "SE ACABÓ EL QUESO", 26, CHEESE)
	_title(box, "Oleada %d · %s\nRatas vencidas: %d" % [int(data.get("wave", 1)), _time_text(float(data.get("elapsed", 0))), int(data.get("kills", 0))], 18, MUTED)
	_title(box, "Monedas restantes: %d\nConservas %d / %d mejoras (%d %%)" % [int(data.get("coins", 0)), int(data.get("retained", 0)), int(data.get("total", 0)), roundi(float(data.get("ratio", 0)) * 100)], 16, Color("e9e6d1"))
	_button(box, "VOLVER A DEFENDER", func(): restart_requested.emit())

func _panel(x: float) -> VBoxContainer:
	var background: ColorRect = ColorRect.new()
	background.color = Color("101a23")
	background.position = Vector2(x, 0)
	background.size = Vector2(216, 720)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var margin: MarginContainer = MarginContainer.new()
	margin.position = Vector2(x, 0)
	margin.size = Vector2(216, 720)
	for side in ["left", "right", "top", "bottom"]: margin.add_theme_constant_override("margin_" + side, 18)
	add_child(margin)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 9)
	margin.add_child(box)
	return box

func _title(box: VBoxContainer, text: String, font_size: int, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.custom_minimum_size.x = 180
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(label)
	return label

func _bar(box: VBoxContainer, color: Color) -> ProgressBar:
	var bar: ProgressBar = ProgressBar.new()
	bar.custom_minimum_size.y = 12
	bar.show_percentage = false
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fill: StyleBoxFlat = StyleBoxFlat.new()
	fill.bg_color = color
	bar.add_theme_stylebox_override("fill", fill)
	box.add_child(bar)
	return bar

func _button(box: VBoxContainer, text: String, action: Callable) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.add_theme_font_size_override("font_size", 12)
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(action)
	box.add_child(button)
	return button

func _toggle(box: VBoxContainer, text: String, enabled: bool) -> CheckButton:
	var button: CheckButton = CheckButton.new()
	button.text = text
	button.button_pressed = enabled
	button.focus_mode = Control.FOCUS_NONE
	box.add_child(button)
	return button

func _time_text(seconds: float) -> String:
	return "%02d:%02d" % [int(seconds) / 60, int(seconds) % 60]


