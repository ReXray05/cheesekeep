extends Control

const Bow = preload("res://scripts/weapons/bow_controller.gd")
const Indicator = preload("res://scripts/weapons/aim_indicator.gd")
const BowArt = preload("res://scripts/weapons/bow_visuals.gd")
const Arrow = preload("res://scripts/projectiles/arrow_physics.gd")
const Enemy = preload("res://scripts/enemies/enemy_controller.gd")
const Player = preload("res://scripts/player/player_controller.gd")
const Router = preload("res://scripts/input/input_controller.gd")
const Ground = preload("res://scripts/game/world_visuals.gd")

@export var prototype: bool = true
var world: Node2D
var viewport: SubViewport
var camera: Camera2D
var player: Node2D
var bow: Node
var indicator: Node2D
var bow_art: Node2D
var ground: Node2D
var router: Node
var enemies: Array[Node2D] = []
var arrows: Array[Node2D] = []
var status: Label
var charge_label: Label
var message: Label
var score: int = 0
var elapsed: float = 0.0
var toast_time: float = 0.0
var aim: Vector2 = Vector2.RIGHT
var config: Dictionary
var field: SubViewportContainer
var left: VBoxContainer
var right: VBoxContainer

func _ready() -> void:
	config = JSON.parse_string(FileAccess.get_file_as_string("res://data/balance.json"))
	_build_screen()
	world = Node2D.new()
	viewport.add_child(world)
	ground = Ground.new()
	ground.z_index = -10
	world.add_child(ground)
	player = Player.new()
	world.add_child(player)
	camera = Camera2D.new()
	camera.position = player.position
	world.add_child(camera)
	bow = Bow.new()
	bow.setup(config.bow)
	add_child(bow)
	bow.shot.connect(_shoot)
	bow.snapped.connect(_snapped)
	indicator = Indicator.new()
	indicator.bow = bow
	indicator.z_index = -1
	world.add_child(indicator)
	bow_art = BowArt.new()
	bow_art.bow = bow
	world.add_child(bow_art)
	router = Router.new()
	router.field = field
	router.viewport = viewport
	add_child(router)
	router.move_requested.connect(_move)
	router.start_requested.connect(_begin)
	router.release_requested.connect(_release)
	_spawn_dummy()
	_toast("Izquierdo: moverse · Derecho: tensar y soltar",8.0)

func _build_screen() -> void:
	var ui_theme: Theme = Theme.new()
	ui_theme.default_font_size = 16
	var normal: StyleBoxFlat = StyleBoxFlat.new()
	normal.bg_color = Color("273a42")
	normal.border_color = Color("537068")
	normal.set_border_width_all(1)
	normal.content_margin_left = 10
	normal.content_margin_right = 10
	normal.content_margin_top = 10
	normal.content_margin_bottom = 10
	ui_theme.set_stylebox("normal","Button",normal)
	var hover: StyleBoxFlat = normal.duplicate()
	hover.bg_color = Color("42685b")
	ui_theme.set_stylebox("hover","Button",hover)
	var pressed: StyleBoxFlat = normal.duplicate()
	pressed.bg_color = Color("b48242")
	ui_theme.set_stylebox("pressed","Button",pressed)
	theme = ui_theme
	var background: ColorRect = ColorRect.new()
	background.color = Color("101a23")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	left = _panel(Vector2(0,0),Vector2(216,720))
	_title(left,"CHEESE\nKEEP",32,Color("ffd775"))
	_title(left,"LA ÚLTIMA CORTEZA",12,Color("83ab9a"))
	_spacer(left,20)
	_title(left,"CAMPO DE PRUEBAS",14,Color("f8d57d"))
	status = _title(left,"",17,Color("e9e6d1"))
	_spacer(left,15)
	charge_label = _title(left,"",16,Color("f8d57d"))
	_spacer(left,15)
	_title(left,"IZQUIERDO\nCaminar al punto\n\nDERECHO\nMantener: cargar\nSoltar: disparar",14,Color("a6bfb1"))
	field = SubViewportContainer.new()
	field.position = Vector2(216,0)
	field.size = Vector2(720,720)
	field.stretch = true
	field.stretch_shrink = 2
	field.mouse_filter = Control.MOUSE_FILTER_IGNORE
	field.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(field)
	viewport = SubViewport.new()
	viewport.size = Vector2i(360,360)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.handle_input_locally = false
	field.add_child(viewport)
	right = _panel(Vector2(936,0),Vector2(216,720))
	_title(right,"EL ARCO",22,Color("ffd775"))
	_title(right,"NARANJA\nCorto, impreciso\n\nVERDE\nCrítico: ¡suelta!\n\nROJO\nPenetra, pero arriesga\nrotura de cuerda",14,Color("b7c6b1"))
	_spacer(right,25)
	_button(right,"REINICIAR PRUEBA",_reset_prototype)
	_spacer(right,20)
	message = _title(right,"",14,Color("ffd775"))

func _panel(at: Vector2, dimensions: Vector2) -> VBoxContainer:
	var margin: MarginContainer = MarginContainer.new()
	margin.position = at
	margin.size = dimensions
	for side in ["left","right","top","bottom"]:
		margin.add_theme_constant_override("margin_"+side,18)
	add_child(margin)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation",12)
	margin.add_child(box)
	return box

func _title(box: VBoxContainer, text: String, font_size: int, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(label)
	return label

func _spacer(box: VBoxContainer, height: float) -> void:
	var spacer: Control = Control.new()
	spacer.custom_minimum_size.y = height
	box.add_child(spacer)

func _button(box: VBoxContainer, text: String, action: Callable) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.add_theme_font_size_override("font_size",14)
	button.pressed.connect(action)
	box.add_child(button)
	return button

func _process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	elapsed += delta
	toast_time -= delta
	if toast_time <= 0.0:
		message.text = ""
	if router.inside:
		var vector: Vector2 = router.mouse_world - player.bow_origin()
		if vector.length() > 1.0:
			aim = vector.normalized()
	player.direction = aim
	bow.tick(delta)
	var shot_state: Dictionary = bow.snapshot()
	player.tick(delta,shot_state.charging)
	camera.position = player.position
	indicator.position = player.bow_origin()
	indicator.direction = aim
	indicator.queue_redraw()
	bow_art.position = player.bow_origin()
	bow_art.aim = aim
	bow_art.rotation = sin(elapsed * 65.0) * 0.09 * float(shot_state.get("excess",0.0))
	bow_art.queue_redraw()
	ground.target = player.destination
	ground.show_target = player.moving
	for arrow in arrows.duplicate():
		if is_instance_valid(arrow) and not arrow.is_queued_for_deletion():
			arrow.tick(delta)
			var screen: Vector2 = viewport.get_canvas_transform() * arrow.position
			if not Rect2(-8,-8,376,376).has_point(screen):
				arrow.queue_free()
	arrows = arrows.filter(func(a: Node2D) -> bool: return is_instance_valid(a) and not a.is_queued_for_deletion())
	enemies = enemies.filter(func(e: Node2D) -> bool: return is_instance_valid(e) and not e.is_queued_for_deletion())
	status.text = "BAJAS      %02d\nEN VUELO   %02d" % [score,arrows.size()]
	charge_label.text = "%s\n%.2f s" % [shot_state.state_label,bow.charge_time]
	charge_label.add_theme_color_override("font_color",shot_state.color)
	if OS.has_feature("web") and prototype:
		var telemetry: Dictionary = {"charge":bow.charge_time,"state":shot_state.state_label,"kills":score,"arrows":arrows.size(),"player_x":player.position.x,"player_y":player.position.y}
		JavaScriptBridge.eval("window.cheesekeepState = " + JSON.stringify(telemetry) + ";",true)

func _move(point: Vector2) -> void:
	player.go_to(point)

func _begin() -> void:
	router.captured = bow.begin_charge()

func _release() -> void:
	bow.release(aim)

func _shoot(data: Dictionary) -> void:
	bow_art.kick()
	var arrow: Node2D = Arrow.new()
	world.add_child(arrow)
	arrow.setup(player.bow_origin(),data)
	arrow.moved_segment.connect(_segment.bind(arrow))
	arrows.append(arrow)
	_toast("¡CRÍTICO!" if data.critical else "Flecha liberada",1.0)

func _segment(from: Vector2, to: Vector2, arrow: Node2D) -> void:
	var candidates: Array[Dictionary] = []
	for enemy in enemies:
		if not is_instance_valid(enemy) or enemy.dead or arrow.hit_ids.has(enemy.get_instance_id()):
			continue
		var nearest: Vector2 = Geometry2D.get_closest_point_to_segment(enemy.position + Vector2(0,-5),from,to)
		if nearest.distance_to(enemy.position + Vector2(0,-5)) <= enemy.radius:
			candidates.append({"enemy":enemy,"distance":from.distance_squared_to(nearest)})
	candidates.sort_custom(func(a: Dictionary,b: Dictionary)->bool: return a.distance < b.distance)
	for candidate in candidates:
		var enemy: Node2D = candidate.enemy
		var result: Dictionary = enemy.take_hit(arrow.shot_data.damage,arrow.shot_data.critical)
		_float_text(enemy.position,str(int(result.dealt)),Color("ffda7b") if arrow.shot_data.critical else Color("f5eee0"))
		if arrow.register_hit(enemy.get_instance_id()):
			arrow.queue_free()
			break

func _float_text(at: Vector2, text: String, color: Color) -> void:
	var label: Label = Label.new()
	label.text = text
	label.position = at + Vector2(-8,-24)
	label.add_theme_font_size_override("font_size",12)
	label.add_theme_color_override("font_color",color)
	world.add_child(label)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label,"position",label.position+Vector2(0,-18),0.7)
	tween.tween_property(label,"modulate:a",0.0,0.7)
	tween.chain().tween_callback(label.queue_free)

func _snapped() -> void:
	router.reset()
	_toast("¡CUERDA ROTA!\nSe repara en 1,5 s",2)

func _spawn_dummy() -> void:
	var enemy: Node2D = Enemy.new()
	enemy.configure("basic",1)
	enemy.position = player.position + Vector2(90,0)
	world.add_child(enemy)
	enemy.died.connect(func(_reward: int) -> void:
		score += 1
		enemy.queue_free()
		get_tree().create_timer(0.8).timeout.connect(_spawn_dummy))
	enemies.append(enemy)

func _toast(text: String,duration: float = 3.0) -> void:
	message.text = text
	toast_time = duration

func _reset_prototype() -> void:
	get_tree().reload_current_scene()
