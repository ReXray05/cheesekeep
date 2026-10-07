extends Control

signal start_requested
signal pause_requested
signal resume_requested
signal menu_requested
signal settings_changed(data: Dictionary)

const Vintage = preload("res://scripts/ui/vintage_theme.gd")
var settings: Dictionary = {}
var overlay: Control
var screen: String = ""
var return_screen: String = "menu"
var settings_notice: Label

func setup(data: Dictionary) -> void:
	settings = data.duplicate(true)
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = Vintage.make()
	var pause_button: Button = Button.new()
	pause_button.text = "II"
	pause_button.tooltip_text = "Pausa · Esc"
	pause_button.position = Vector2(879,10)
	pause_button.size = Vector2(42,32)
	pause_button.focus_mode = Control.FOCUS_NONE
	pause_button.pressed.connect(func(): pause_requested.emit())
	add_child(pause_button)

func close() -> void:
	if is_instance_valid(overlay):
		remove_child(overlay)
		overlay.queue_free()
	overlay = null
	screen = ""

func _window(title: String, kind: String) -> VBoxContainer:
	close()
	screen = kind
	overlay = Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.02,0.08,0.07,0.25)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(dim)
	var panel: PanelContainer = PanelContainer.new()
	panel.position = Vector2(258,98)
	panel.size = Vector2(636,524)
	overlay.add_child(panel)
	var body: VBoxContainer = VBoxContainer.new()
	body.add_theme_constant_override("separation",12)
	panel.add_child(body)
	var bar: PanelContainer = PanelContainer.new()
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("254b50")
	style.set_content_margin_all(8)
	bar.add_theme_stylebox_override("panel",style)
	body.add_child(bar)
	var label: Label = Label.new()
	label.text = "+  " + title + "                                      CHEESE/OS"
	label.add_theme_color_override("font_color",Color("fff0bc"))
	bar.add_child(label)
	return body

func _text(body: VBoxContainer, text: String, font_size: int = 16) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size",font_size)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(label)
	return label

func _button(body: VBoxContainer, text: String, action: Callable) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.custom_minimum_size.y = 38
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(action)
	body.add_child(button)
	return button

func show_menu() -> void:
	var body: VBoxContainer = _window("Cheesekeep.exe", "menu")
	var heading: Label = _text(body,"CHEESEKEEP",32)
	heading.add_theme_font_override("font",preload("res://assets/fonts/PressStart2P-Regular.ttf"))
	heading.add_theme_font_size_override("font_size",26)
	_text(body,"LA ÚLTIMA CORTEZA\nUn arquero. Un queso. Demasiadas ratas.",18)
	_text(body,"Defiende, baja a recoger y vuelve cuando quieras.\nVerde: rompe defensas. Morado: barre grupos.")
	_button(body,">  NUEVA PARTIDA",func(): start_requested.emit())
	_button(body,"  AJUSTES",func(): return_screen = "menu"; show_settings())
	_button(body,"?  CÓMO JUGAR",func(): return_screen = "menu"; show_help())
	_text(body,"Supervivencia infinita · Una mejora por oleada\nEl queso te revive mientras siga en pie.",13)

func show_pause() -> void:
	var body: VBoxContainer = _window("Partida en pausa", "pause")
	_text(body,"Las ratas también necesitan un descanso.",21)
	_button(body,">  CONTINUAR",func(): resume_requested.emit())
	_button(body,"  AJUSTES",func(): return_screen = "pause"; show_settings())
	_button(body,"?  AYUDA",func(): return_screen = "pause"; show_help())
	_button(body,"  VOLVER AL MENÚ",func(): show_abandon())
	_text(body,"Si soltaste la carga durante la pausa, pulsa y suelta\nel botón de disparo para resolverla al continuar.",14)

func show_abandon() -> void:
	var body: VBoxContainer = _window("Volver al menú", "abandon")
	_text(body,"Se abandonará esta partida.\nLas mejoras conservadas anteriormente siguen guardadas.",20)
	_button(body,"VOLVER AL MENÚ",func(): menu_requested.emit())
	_button(body,"SEGUIR DEFENDIENDO",show_pause)

func _back() -> void:
	if return_screen == "pause": show_pause()
	else: show_menu()

func _change(key: String, value: Variant) -> void:
	settings[key] = value
	settings_changed.emit(settings.duplicate(true))
	if is_instance_valid(settings_notice): settings_notice.text = "Guardado automáticamente."

func show_settings() -> void:
	var body: VBoxContainer = _window("Panel de ajustes", "settings")
	_text(body,"MOVIMIENTO")
	var movement: OptionButton = OptionButton.new()
	movement.add_item("Ratón · clic a destino")
	movement.add_item("WASD · movimiento directo")
	movement.selected = 1 if settings.get("movement_mode","click") == "wasd" else 0
	movement.item_selected.connect(func(index: int): _change("movement_mode","wasd" if index == 1 else "click"))
	body.add_child(movement)
	_text(body,"BOTÓN DE DISPARO · el contrario mueve / interactúa")
	var shoot: OptionButton = OptionButton.new()
	shoot.add_item("Derecho")
	shoot.add_item("Izquierdo")
	shoot.selected = 1 if settings.get("shoot_button","right") == "left" else 0
	shoot.item_selected.connect(func(index: int): _change("shoot_button","left" if index == 1 else "right"))
	body.add_child(shoot)
	_slider(body,"MÚSICA", "music_volume")
	_slider(body,"EFECTOS DE SONIDO", "sfx_volume")
	for entry: Array in [["EFECTOS VISUALES","effects_enabled"],["CONSEJOS EN PANTALLA","help_enabled"]]:
		var check: CheckButton = CheckButton.new()
		check.text = str(entry[0])
		check.button_pressed = bool(settings.get(entry[1],true))
		check.toggled.connect(func(value: bool): _change(str(entry[1]),value))
		body.add_child(check)
	settings_notice = _text(body,"Los controles nuevos se aplican al terminar la carga actual.",13)
	_button(body,"VOLVER",_back)

func _slider(body: VBoxContainer, title: String, key: String) -> void:
	_text(body,title,13)
	var slider: HSlider = HSlider.new()
	slider.min_value = 0
	slider.max_value = 1
	slider.step = 0.05
	slider.value = float(settings.get(key,0.7))
	slider.value_changed.connect(func(value: float): _change(key,value))
	body.add_child(slider)

func show_help() -> void:
	var body: VBoxContainer = _window("Manual de supervivencia", "help")
	_text(body,"1. Mueve con WASD o clic. El botón contrario al disparo\n   interactúa con el suelo y la torre; E también sirve cerca.\n2. Mantén disparo, apunta y suelta. Puedes moverte cargando.\n3. VERDE: crítico y rompe protección. MORADO: flecha gigante.\n   Después del morado queda muy poco tiempo antes de romperse.\n4. Botón central: golpe con arco; empuja a varias ratas.\n   Funciona sin flechas y con el arco roto. No durante carga.\n5. ESPACIO: dash. Desde la torre bajas de un impulso.\n6. Recoge monedas y flechas del suelo. Las bajas con golpe\n   dejan flechas. Los disparos fallados también son recuperables.\n7. Compra y repara cuando quieras. No pausa el combate.\n8. Elige una mejora al terminar; empieza la siguiente tú.\n\nESC pausa. Ahorrar monedas conserva parte del árbol al perder.",15)
	_button(body,"ENTENDIDO",_back)
