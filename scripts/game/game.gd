extends Control

const Bow = preload("res://scripts/weapons/bow_controller.gd")
const Indicator = preload("res://scripts/weapons/aim_indicator.gd")
const BowArt = preload("res://scripts/weapons/bow_visuals.gd")
const Arrow = preload("res://scripts/projectiles/arrow_physics.gd")
const Enemy = preload("res://scripts/enemies/enemy_controller.gd")
const Player = preload("res://scripts/player/player_controller.gd")
const Router = preload("res://scripts/input/input_controller.gd")
const Ground = preload("res://scripts/game/world_visuals.gd")
const Radar = preload("res://scripts/ui/threat_radar.gd")
const Feedback = preload("res://scripts/effects/feedback_controller.gd")
const HUD = preload("res://scripts/ui/hud.gd")
const Wave = preload("res://scripts/waves/wave_manager.gd")
const Economy = preload("res://scripts/economy/economy_manager.gd")
const Upgrades = preload("res://scripts/upgrades/upgrade_manager.gd")
const Persistence = preload("res://scripts/systems/persistence.gd")
const Geometry = preload("res://scripts/systems/tower_geometry.gd")
const Shell = preload("res://scripts/ui/v2_shell.gd")
const Pickups = preload("res://scripts/pickups/pickup_manager.gd")

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
var message: Label
var score: int = 0
var elapsed: float = 0.0
var toast_time: float = 0.0
var aim: Vector2 = Vector2.RIGHT
var config: Dictionary
var field: SubViewportContainer
var hud: Control
var wave_manager: Node
var economy: RefCounted
var upgrades: RefCounted
var base_config: Dictionary
var phase: String = "PREP"
var tower_hp: float = 300.0
var tower_max: float = 300.0
var respawn_left: float = 0.0
var qa_mode: bool = false
var effects_enabled: bool = true
var shake: float = 0.0
var result: Dictionary = {}
var telemetry_timer: float = 0.0
var radar: Node2D
var feedback: Node2D
var chromatic: ColorRect
var float_count: int = 0
var shell: Control
var pickups: Node2D
var settings: Dictionary = {}
var resume_phase: String = "PREP"
var camera_initialized: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	config = JSON.parse_string(FileAccess.get_file_as_string("res://data/balance.json"))
	base_config = config.duplicate(true)
	settings = Persistence.load_settings()
	qa_mode = OS.has_feature("web") and bool(JavaScriptBridge.eval("new URLSearchParams(location.search).has('qa')",true))
	_build_screen()
	world = Node2D.new()
	world.process_mode = Node.PROCESS_MODE_PAUSABLE
	world.y_sort_enabled = true
	viewport.add_child(world)
	ground = Ground.new()
	ground.z_index = 0
	world.add_child(ground)
	feedback = Feedback.new()
	world.add_child(feedback)
	feedback.setup()
	player = Player.new()
	world.add_child(player)
	player.setup(config.player)
	player.melee_started.connect(_melee_started)
	player.dash_started.connect(func():
		feedback.activate()
		feedback.burst(player.position,8,Color("b5f1da"),45)
		feedback.add_ring(player.position,Color("b5f1da"),0.15)
		feedback.shake_strength = maxf(feedback.shake_strength,0.8)
		feedback.play_sound("dash"))
	camera = Camera2D.new()
	camera.position = player.position
	world.add_child(camera)
	bow = Bow.new()
	bow.setup(config.bow)
	add_child(bow)
	bow.shot.connect(_shoot)
	bow.snapped.connect(_snapped)
	bow.recovered.connect(func():
		feedback.burst(player.bow_origin(),8,Color("9bf3b0"),30)
		feedback.add_ring(player.bow_origin(),Color("9bf3b0"),0.15)
		feedback.play_sound("ready")
		_toast("¡ARCO LISTO!",0.7))
	indicator = Indicator.new()
	indicator.bow = bow
	indicator.z_index = -100
	world.add_child(indicator)
	bow_art = BowArt.new()
	bow_art.bow = bow
	world.add_child(bow_art)
	var overlay: CanvasLayer = CanvasLayer.new()
	overlay.layer = 5
	viewport.add_child(overlay)
	radar = Radar.new()
	overlay.add_child(radar)
	var effect_layer: CanvasLayer = CanvasLayer.new()
	effect_layer.layer = 3
	viewport.add_child(effect_layer)
	chromatic = ColorRect.new()
	chromatic.size = Vector2(360,360)
	chromatic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var distortion: ShaderMaterial = ShaderMaterial.new()
	distortion.shader = preload("res://scripts/effects/chromatic.gdshader")
	chromatic.material = distortion
	chromatic.visible = false
	effect_layer.add_child(chromatic)
	router = Router.new()
	router.process_priority = -100
	router.field = field
	router.viewport = viewport
	add_child(router)
	router.move_requested.connect(_move)
	router.start_requested.connect(_begin)
	router.release_requested.connect(_release)
	router.melee_requested.connect(_melee)
	router.dash_requested.connect(_dash)
	router.interact_requested.connect(func():
		if _can_act(): player.request_interact())
	router.pause_requested.connect(request_pause)
	router.apply_settings(settings)
	if prototype:
		_spawn_dummy()
		_toast("Izquierdo: moverse · Derecho: tensar y soltar",8.0)
	else:
		economy = Economy.new()
		economy.setup(config.economy)
		upgrades = Upgrades.new()
		upgrades.expanded = true
		upgrades.setup(Persistence.load_history())
		_apply_upgrades(true)
		player.tower_enabled = true
		player.position = Vector2(0,45)
		player.destination = player.position
		ground.tower_enabled = true
		wave_manager = Wave.new()
		wave_manager.variety_enabled = true
		add_child(wave_manager)
		wave_manager.spawn_requested.connect(_spawn_enemy)
		wave_manager.completed.connect(_wave_completed)
		pickups = Pickups.new()
		world.add_child(pickups)
		pickups.setup(config.economy)
		pickups.collected.connect(func(kind: String, amount: int, at: Vector2):
			if economy.collect(kind,amount):
				feedback.play_sound("purchase",1.3 if kind == "coin" else 0.95)
				feedback.burst(at,3,Color("ffd775") if kind == "coin" else Color("bce7ca"),18))
		_toast("¡Protege el queso!\nInicia la primera oleada cuando quieras.",8.0)
	shell = Shell.new()
	add_child(shell)
	shell.setup(settings)
	shell.start_requested.connect(start_run)
	shell.pause_requested.connect(request_pause)
	shell.resume_requested.connect(resume_game)
	shell.menu_requested.connect(return_to_menu)
	shell.settings_changed.connect(_settings_changed)
	process_mode = Node.PROCESS_MODE_ALWAYS
	hud.process_mode = Node.PROCESS_MODE_ALWAYS
	router.process_mode = Node.PROCESS_MODE_ALWAYS
	_apply_settings()
	if not prototype:
		phase = "MENU"
		router.set_suspended(true)
		shell.show_menu()
		get_tree().paused = true
	hud.update_status(_status_data(bow.snapshot()))

func _build_screen() -> void:
	var background: ColorRect = ColorRect.new()
	background.color = Color("101a23")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
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
	hud = HUD.new()
	add_child(hud)
	hud.setup(prototype)
	hud.buy_ammo_requested.connect(_buy_ammo)
	hud.repair_requested.connect(_repair)
	hud.next_wave_requested.connect(_next_wave)
	hud.upgrade_requested.connect(_choose_upgrade)
	hud.restart_requested.connect(_reset_prototype)
	hud.tree_requested.connect(func() -> void:
		if not prototype and (phase == "PREP" or phase == "CHOICE"):
			request_pause()
			shell.close()
			hud.show_tree(upgrades.history,upgrades.definitions))
	hud.tree_closed.connect(func():
		if phase == "PAUSED": shell.show_pause())
	hud.effects_toggled.connect(func(value: bool) -> void:
		effects_enabled = value
		if is_instance_valid(feedback): feedback.enabled = value)
	hud.audio_toggled.connect(func(value: bool) -> void:
		if is_instance_valid(feedback): feedback.audio_enabled = value)
	message = hud.message

func _process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	if phase == "MENU" or phase == "PAUSED":
		router.enabled = false
		return
	if phase != "OVER":
		elapsed += delta
	toast_time -= delta
	if toast_time <= 0.0:
		message.text = ""
	if router.inside:
		var vector: Vector2 = router.mouse_world - player.aim_anchor()
		if vector.length() > 3.0:
			aim = vector.normalized()
	player.direction = aim
	if phase != "OVER":
		bow.tick(delta)
	var shot_state: Dictionary = bow.snapshot()
	if phase != "OVER":
		player.set_movement_input(router.movement_vector() if router.enabled else Vector2.ZERO,settings.get("movement_mode","click") == "wasd")
		if player.dash_left>0.0:
			player.set_dash_steering(router.movement_vector() if settings.get("movement_mode","click") == "wasd" else router.mouse_world-player.aim_anchor())
		player.tick(delta,shot_state.charging)
	if not camera_initialized:
		camera.position = player.position
		camera_initialized = true
	else:
		camera.position = camera.position.lerp(player.position,1.0-exp(-delta*22.0))
	feedback.tick(delta)
	camera.offset = Vector2(sin(elapsed*119),cos(elapsed*143)) * minf(4,feedback.shake_strength) if effects_enabled else Vector2.ZERO
	chromatic.visible = effects_enabled and feedback.flash_strength > 0.01
	chromatic.material.set_shader_parameter("amount",feedback.flash_strength if effects_enabled else 0.0)
	indicator.position = player.bow_origin()
	indicator.direction = aim
	indicator.queue_redraw()
	bow_art.position = player.bow_origin()
	bow_art.aim = aim
	bow_art.rotation = sin(elapsed * 65.0) * 0.09 * float(shot_state.get("excess",0.0)) if effects_enabled else 0.0
	bow_art.visible = player.alive
	indicator.visible = player.alive
	bow_art.queue_redraw()
	ground.target = player.destination
	ground.show_target = player.moving
	for arrow in arrows.duplicate() if phase != "OVER" else []:
		if is_instance_valid(arrow) and not arrow.is_queued_for_deletion():
			arrow.tick(delta)
	arrows = arrows.filter(func(a: Node2D) -> bool: return is_instance_valid(a) and not a.is_queued_for_deletion())
	enemies = enemies.filter(func(e: Node2D) -> bool: return is_instance_valid(e) and not e.is_queued_for_deletion())
	if not prototype and phase != "OVER":
		for enemy in enemies.duplicate():
			if not enemy.dead:
				enemy.tick(delta,player.position,Vector2.ZERO,player.alive,player.mounted)
		if phase != "OVER":
			wave_manager.tick(delta,enemies.size())
			if not player.alive:
				respawn_left -= delta
				if respawn_left <= 0.0:
					player.revive()
					_toast("¡El queso te devuelve a la vida!",2.0)
	ground.tower_hp = tower_hp
	ground.tower_max = tower_max
	if not prototype and phase != "OVER":
		pickups.tick(delta,player.position,player.alive and not player.mounted,float(config.player.get("collect_radius",12)),float(config.player.get("magnet_radius",12)))
	router.enabled = phase != "OVER" and player.alive and not hud.has_overlay()
	radar_refresh()
	hud.update_status(_status_data(shot_state))
	telemetry_timer -= delta
	if OS.has_feature("web") and (prototype or qa_mode) and (shot_state.charging or telemetry_timer <= 0.0):
		telemetry_timer = 0.1
		var telemetry: Dictionary = _status_data(shot_state)
		telemetry.erase("bow")
		telemetry.merge({"charge":bow.charge_time,"state":shot_state.state_label,"kills":score,"arrows":arrows.size(),"player_x":player.position.x,"player_y":player.position.y,"enemies":enemies.size(),"fps":Engine.get_frames_per_second(),"nodes":int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)),"ticks":Time.get_ticks_msec()})
		var serialized: String = JSON.stringify(telemetry)
		JavaScriptBridge.eval("window.cheesekeepState = " + serialized + "; document.querySelector('canvas').setAttribute('data-qa-state',JSON.stringify(window.cheesekeepState));",true)

func _move(point: Vector2) -> void:
	if _can_act(): player.go_to(point)

func _begin() -> void:
	if not _can_act():
		return
	if player.melee_left>0.0:
		return
	if bool(bow.snapshot().charging):
		router.captured = true
		return
	if not prototype and economy.ammo <= 0:
		_toast("Sin flechas: botón central para golpear; recoge las del suelo.",3)
		return
	if arrows.size() >= int(config.limits.arrows):
		return
	router.captured = bow.begin_charge()

func _release() -> void:
	if _can_act(): bow.release(aim)

func _shoot(data: Dictionary) -> void:
	if not _can_act():
		return
	if not prototype and not economy.consume_arrow():
		return
	bow_art.kick()
	feedback.fire(player.bow_origin(),data.direction,data.damage,data.critical)
	if data.critical:
		feedback.play_sound("perfect")
		feedback.burst(player.bow_origin(),10,Color("9ff28b"),44)
		feedback.add_ring(player.bow_origin(),Color("9ff28b"),0.16)
	if bool(data.get("spectral",false)):
		feedback.burst(player.bow_origin(),12,Color("cd9aff"),55)
		feedback.play_sound("spectral")
		feedback.shake_strength = maxf(feedback.shake_strength,2.4)
	var arrow: Node2D = Arrow.new()
	world.add_child(arrow)
	arrow.setup(player.bow_origin().limit_length(Geometry.ARENA_RADIUS),data)
	arrow.moved_segment.connect(_segment.bind(arrow))
	arrow.finished.connect(_arrow_finished)
	arrows.append(arrow)
	_toast("¡ESPECTRAL!" if bool(data.get("spectral",false)) else ("¡PERFECTO!" if data.critical else "Flecha liberada"),0.7)

func _segment(from: Vector2, to: Vector2, arrow: Node2D) -> void:
	if phase == "OVER":
		return
	var boundary: bool = to.length() > Geometry.ARENA_RADIUS
	if boundary:
		var travel: Vector2 = to-from
		var a: float = travel.length_squared()
		var b: float = 2.0*from.dot(travel)
		var c: float = from.length_squared()-Geometry.ARENA_RADIUS*Geometry.ARENA_RADIUS
		var t: float = clampf((-b+sqrt(maxf(0,b*b-4*a*c)))/(2*a),0,1) if a>0.00001 else 0.0
		to = from.lerp(to,t).limit_length(Geometry.ARENA_RADIUS)
		arrow.position = to
	var candidates: Array[Dictionary] = []
	for enemy in enemies:
		if not is_instance_valid(enemy) or enemy.dead or arrow.hit_ids.has(enemy.get_instance_id()):
			continue
		var nearest: Vector2 = Geometry2D.get_closest_point_to_segment(enemy.position + Vector2(0,-5),from,to)
		var radius: float = enemy.radius + (float(arrow.shot_data.get("half_width",0)) if bool(arrow.shot_data.get("spectral",false)) else 0.0)
		var perpendicular: float = nearest.distance_to(enemy.position+Vector2(0,-5))
		if perpendicular <= radius:
			var distance: float = maxf(0,from.distance_to(nearest)-sqrt(maxf(0,radius*radius-perpendicular*perpendicular)))
			candidates.append({"enemy":enemy,"distance":distance,"at":from.move_toward(to,distance)})
	candidates.sort_custom(func(a: Dictionary,b: Dictionary)->bool: return a.distance < b.distance)
	for candidate in candidates:
		var enemy: Node2D = candidate.enemy
		var result: Dictionary = enemy.take_hit(arrow.shot_data.damage,arrow.shot_data.critical,"spectral" if bool(arrow.shot_data.get("spectral",false)) else "arrow")
		feedback.impact(enemy.position,arrow.shot_data.critical,result.blocked,result.killed)
		_float_text(enemy.position,str(int(result.dealt)),Color("ffda7b") if arrow.shot_data.critical else Color("f5eee0"))
		if arrow.register_hit(enemy.get_instance_id()):
			arrow.finish("hits",candidate.at)
			break
	if boundary and not arrow.is_finished:
		arrow.finish("boundary",to)

func _arrow_finished(data: Dictionary) -> void:
	if not prototype and phase in ["PREP","WAVE","CHOICE"] and bool(data.get("recoverable",false)):
		pickups.spawn_pickup("arrow",1,Geometry.accessible_point(data.position,0,true))

func _can_act() -> bool:
	return is_instance_valid(player) and player.alive and phase in ["PREP","WAVE","CHOICE"] and not hud.has_overlay()

func _melee() -> void:
	if _can_act(): player.request_melee(aim,bool(bow.snapshot().charging))

func _melee_started(data: Dictionary) -> void:
	if not _can_act(): return
	feedback.activate()
	bow_art.play_melee(data)
	feedback.play_sound("melee")
	feedback.burst(data.origin,5,Color("fff0bc"),36)
	feedback.shake_strength = maxf(feedback.shake_strength,0.7)
	var direction: Vector2 = data.direction
	for enemy: Node2D in enemies.duplicate():
		if not is_instance_valid(enemy) or enemy.dead: continue
		var offset: Vector2 = enemy.position-data.origin
		if offset.length()>float(data.range)+enemy.radius: continue
		if offset.length()>0.001 and absf(direction.angle_to(offset))>float(data.half_angle): continue
		var hit: Dictionary = enemy.take_hit(float(data.damage),false,"melee")
		enemy.apply_knockback(direction,float(data.knockback))
		feedback.impact(enemy.position,false,hit.blocked,hit.killed)
		_float_text(enemy.position,str(int(hit.dealt)),Color("f8e3ad"))
		feedback.shake_strength = maxf(feedback.shake_strength,1.5)

func _dash() -> void:
	if not _can_act(): return
	var direction: Vector2 = router.movement_vector()
	if settings.get("movement_mode","click") == "click" and player.moving:
		direction = player.destination-player.position
	if direction.length_squared()<0.001: direction = aim
	player.request_dash(direction.normalized())

func request_pause() -> void:
	if phase == "PAUSED":
		if shell.screen == "pause": resume_game()
		else:
			hud.close_tree()
			shell.show_pause()
		return
	if phase not in ["PREP","WAVE","CHOICE"]: return
	resume_phase = phase
	phase = "PAUSED"
	router.set_suspended(true)
	player.clear_queued_melee()
	get_tree().paused = true
	shell.show_pause()

func resume_game() -> void:
	if phase != "PAUSED": return
	shell.close()
	phase = resume_phase
	get_tree().paused = false
	router.set_suspended(false)

func start_run() -> void:
	if phase != "MENU": return
	shell.close()
	phase = "PREP"
	get_tree().paused = false
	router.set_suspended(false)
	feedback.activate()
	_toast("Verde: crítico · Morado: espectral\nCentral: golpe · Espacio: dash · Esc: pausa",8)

func return_to_menu() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_instance_valid(shell) and phase in ["PREP","WAVE","CHOICE"]:
		request_pause()

func _settings_changed(data: Dictionary) -> void:
	settings = data.duplicate(true)
	_apply_settings()
	if not Persistence.save(Persistence.load_history(),settings):
		_toast("No se pudieron guardar los ajustes.",4)

func _apply_settings() -> void:
	if is_instance_valid(router): router.apply_settings(settings)
	effects_enabled = bool(settings.get("effects_enabled",true))
	if is_instance_valid(feedback):
		feedback.enabled = effects_enabled
		feedback.music_volume = float(settings.get("music_volume",0.7))
		feedback.sfx_volume = float(settings.get("sfx_volume",0.8))

func _float_text(at: Vector2, text: String, color: Color) -> void:
	if float_count >= int(config.limits.effects):
		return
	float_count += 1
	var label: Label = Label.new()
	label.text = text
	label.position = at + Vector2(-8,-24)
	label.add_theme_font_size_override("font_size",8)
	label.add_theme_font_override("font",preload("res://assets/fonts/PressStart2P-Regular.ttf"))
	label.add_theme_color_override("font_outline_color",Color("182025"))
	label.add_theme_constant_override("outline_size",2)
	label.add_theme_color_override("font_color",color)
	label.z_index = 30
	world.add_child(label)
	var tween: Tween = world.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label,"position",label.position+Vector2(0,-18),0.7)
	tween.tween_property(label,"modulate:a",0.0,0.7)
	tween.chain().tween_callback(func() -> void:
		label.queue_free()
		float_count = maxi(0,float_count-1))

func _snapped() -> void:
	router.reset()
	feedback.snap(player.bow_origin())
	_toast("¡CUERDA ROTA!\nSe repara en 1,5 s",2)

func _spawn_dummy() -> void:
	var enemy: Node2D = Enemy.new()
	enemy.configure("basic",1)
	enemy.tower_enabled = false
	enemy.position = player.position + Vector2(90,0)
	world.add_child(enemy)
	enemy.died.connect(func(_reward: int) -> void:
		score += 1
		enemy.queue_free()
		get_tree().create_timer(0.8,false).timeout.connect(_spawn_dummy))
	enemies.append(enemy)

func _toast(text: String,duration: float = 3.0) -> void:
	message.text = text
	toast_time = duration

func _reset_prototype() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _status_data(shot_state: Dictionary) -> Dictionary:
	return {"hp":player.hp,"max_hp":player.max_hp,"ammo":999 if prototype else economy.ammo,"coins":0 if prototype else economy.coins,"tower_hp":tower_hp,"tower_max":tower_max,"wave":0 if prototype else wave_manager.wave,"phase":phase,"kills":score,"mounted":player.mounted,"alive":player.alive,"respawn_left":maxf(0,respawn_left),"bow":shot_state,"elapsed":elapsed,"sweet_start":config.bow.sweet_start,"sweet_end":config.bow.sweet_end,"overcharge_peak":config.bow.overcharge_peak,"ammo_price":config.economy.ammo_price,"ammo_pack":config.economy.ammo_pack,"repair_price":config.economy.repair_price,"repair_hp":config.economy.repair_hp,"mounted_damage":config.tower.mounted_damage,"upgrade_count":0 if prototype else upgrades.history.size(),"retained_preview":0 if prototype else int(floor(upgrades.history.size()*clampf(float(economy.coins)/float(config.economy.retention_coins),0,1))),
		"movement_mode":settings.get("movement_mode","click"),"shoot_button":settings.get("shoot_button","right"),"help_enabled":settings.get("help_enabled",true),
		"spectral_start":config.bow.get("spectral_start",1.55),"spectral_end":config.bow.get("spectral_end",1.67),"break_time":config.bow.get("break_time",1.85),
		"dash_cooldown_left":player.dash_cooldown,"melee_cooldown_left":player.melee_cooldown,"pickups":0 if prototype or not is_instance_valid(pickups) else pickups.records.size()}

func _spawn_enemy(kind: String, at: Vector2) -> void:
	if phase not in ["PREP","WAVE"]:
		return
	var enemy: Node2D = Enemy.new()
	enemy.configure(kind,wave_manager.wave)
	enemy.position = Geometry.accessible_point(at,enemy.radius,true)
	world.add_child(enemy)
	enemy.attack.connect(_attacked)
	enemy.summon_requested.connect(func(summon_kind: String,summon_at: Vector2) -> void:
		if enemies.size() < int(config.limits.enemies):
			_spawn_enemy(summon_kind,summon_at))
	enemy.died.connect(func(reward: int) -> void:
		if phase == "OVER":
			return
		score += 1
		pickups.spawn_pickup("coin",reward,enemy.position)
		if enemy.death_source == "melee":
			pickups.spawn_pickup("arrow",int(config.economy.get("melee_arrows",2)),enemy.position)
		enemy.queue_free())
	enemies.append(enemy)

func _attacked(target: String, amount: float) -> void:
	if phase not in ["PREP","WAVE"]:
		return
	if target == "tower":
		var damage: float = amount * (float(config.tower.mounted_damage) if player.mounted else 1.0)
		tower_hp = maxf(0.0,tower_hp - damage)
		feedback.damage(Vector2.ZERO,damage > 10.0)
		_float_text(Vector2(0,-18),"-%d" % int(damage),Color("ff757b"))
		if tower_hp <= 0.0:
			_game_over()
	else:
		if player.hurt(amount):
			feedback.damage(player.position,amount > 10.0)
			_float_text(player.position,"-%d" % int(amount),Color("ff757b"))
			if not player.alive:
				bow.reset()
				router.reset()
				respawn_left = float(config.player.respawn_time)
				_toast("¡Caíste! Revives si el queso sigue en pie.",3)

func _next_wave() -> void:
	if prototype or phase != "PREP":
		return
	phase = "WAVE"
	wave_manager.start()
	feedback.wave_start()
	_toast("OLEADA %d\n¡Las ratas vienen por todos lados!" % wave_manager.wave,3)

func _wave_completed(number: int, reward: int) -> void:
	if phase != "WAVE":
		return
	economy.earn(reward)
	feedback.wave_clear()
	phase = "CHOICE"
	var offers: Array = upgrades.offers()
	if offers.is_empty():
		phase = "PREP"
		economy.earn(10)
	else:
		hud.show_offers(offers)
	_toast("OLEADA %d COMPLETA\n+%d monedas · Elige una mejora gratis." % [number,reward],8)

func _choose_upgrade(id: String) -> void:
	if prototype or phase != "CHOICE":
		return
	if upgrades.acquire(id):
		_apply_upgrades(false)
		phase = "PREP"
		hud.clear_offers()
		feedback.purchase()
		_toast("Mejora adquirida.\nCompra, repara y comienza cuando quieras.",5)

func _apply_upgrades(full_health: bool) -> void:
	var old_max: float = tower_max
	config = upgrades.rebuild(base_config)
	bow.config = config.bow.duplicate(true)
	player.speed = float(config.player.speed)
	player.setup(config.player)
	if economy != null: economy.config = config.economy.duplicate(true)
	if is_instance_valid(pickups): pickups.setup(config.economy)
	player.charging_slow = float(config.player.charging_slow)
	player.max_hp = float(config.player.hp)
	tower_max = float(config.tower.hp)
	tower_hp = tower_max if full_health else minf(tower_max,tower_hp+maxf(0,tower_max-old_max))

func _buy_ammo() -> void:
	if prototype or phase not in ["PREP","WAVE","CHOICE"]:
		return
	if economy.buy_ammo():
		feedback.purchase()
		_toast("+%d flechas" % int(config.economy.ammo_pack),2)
	else:
		_toast("Faltan monedas para comprar flechas.",2)

func _repair() -> void:
	if prototype or phase not in ["PREP","WAVE","CHOICE"]:
		return
	if tower_hp >= tower_max:
		_toast("El queso ya está intacto.",2)
	elif economy.spend(int(config.economy.repair_price)):
		tower_hp = minf(tower_max,tower_hp + float(config.economy.repair_hp))
		feedback.purchase()
		_toast("Queso reparado",2)
	else:
		_toast("Faltan monedas para reparar el queso.",2)

func _game_over() -> void:
	if phase == "OVER": return
	phase = "OVER"
	feedback.over()
	wave_manager.active = false
	bow.reset()
	router.reset()
	for arrow in arrows:
		if is_instance_valid(arrow):
			arrow.finish("cleanup",arrow.position)
	arrows.clear()
	player.clear_actions()
	if is_instance_valid(pickups): pickups.clear()
	var retained: Array = Persistence.retain(upgrades.history,economy.coins,int(config.economy.retention_coins))
	var saved: bool = Persistence.save(retained,settings)
	result = {"wave":wave_manager.wave,"kills":score,"elapsed":elapsed,"coins":economy.coins,"ratio":clampf(float(economy.coins)/float(config.economy.retention_coins),0,1),"retained":retained.size(),"total":upgrades.history.size()}
	hud.show_game_over(result)
	if not saved:
		_toast("El navegador no ha podido guardar las mejoras. Revisa el almacenamiento local.",8)

func radar_refresh() -> void:
	radar.targets.clear()
	for enemy in enemies:
		if not enemy.dead:
			radar.targets.append(viewport.get_canvas_transform() * enemy.position)
	radar.show_cursor = router.inside and phase != "OVER" and not hud.has_overlay()
	radar.cursor = viewport.get_canvas_transform() * router.mouse_world
	radar.queue_redraw()
