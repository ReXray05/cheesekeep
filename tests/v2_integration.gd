extends SceneTree

const GameScene = preload("res://scenes/game/game.tscn")
const Save = preload("res://scripts/systems/persistence.gd")
const Arrow = preload("res://scripts/projectiles/arrow_physics.gd")
const Geometry = preload("res://scripts/systems/tower_geometry.gd")
var checks := 0
var failures := 0
var old_save := ""
var had_save := false

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("V2 integration: " + message)

func fixture() -> Control:
	var game: Control = GameScene.instantiate()
	root.add_child(game)
	game.set_process(false)
	game.router.set_process(false)
	game.router.inside = false
	game.feedback.audio_enabled = false
	return game

func step(game: Control, seconds: float) -> void:
	var left := seconds
	while left > 0.00001:
		var dt := minf(left, 1.0 / 60.0)
		game._process(dt)
		left -= dt

func mouse(game: Control, index: int, pressed: bool, outside := false) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = index
	event.pressed = pressed
	event.position = Vector2(20, 20) if outside else game.field.get_global_rect().get_center()
	if pressed:
		game.router._unhandled_input(event)
	else:
		game.router._input(event)

func key(game: Control, code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = true
	game.router._unhandled_input(event)

func shot(game: Control, origin: Vector2, overrides := {}) -> Node2D:
	var data := {"direction":Vector2.RIGHT,"speed":360.0,"damage":28.0,"critical":false,"pierce":1,"range":210.0,"range_limited":false,"spectral":false,"half_width":0.0,"lifetime":6.0}
	data.merge(overrides,true)
	var arrow: Node2D = Arrow.new()
	game.world.add_child(arrow)
	arrow.setup(origin,data)
	arrow.moved_segment.connect(game._segment.bind(arrow))
	arrow.finished.connect(game._arrow_finished)
	game.arrows.append(arrow)
	return arrow

func run() -> void:
	had_save = FileAccess.file_exists(Save.SAVE_PATH)
	if had_save: old_save = FileAccess.get_file_as_string(Save.SAVE_PATH)
	Save.save([],Save.DEFAULT_SETTINGS)
	var game := fixture()
	check(game.phase == "MENU" and paused,"Boot starts suspended MENU")
	var elapsed: float = game.elapsed
	game._begin()
	game._next_wave()
	game._spawn_enemy("basic",Vector2(100,100))
	step(game,1)
	check(game.enemies.is_empty() and game.arrows.is_empty() and game.elapsed == elapsed,"MENU rejects late gameplay callbacks and freezes time")
	game.start_run()
	check(game.phase == "PREP" and not paused,"Start moves MENU to PREP")
	game.queue_free()
	paused = false
	await process_frame
	for movement: String in ["click","wasd"]:
		for shooting: String in ["left","right"]:
			game = fixture()
			game.start_run()
			game.settings.movement_mode = movement
			game.settings.shoot_button = shooting
			game.router.apply_settings(game.settings)
			game.player.position = Vector2(70,70)
			game.player.destination = game.player.position
			game._process(0)
			if movement == "wasd":
				var origin: Vector2 = game.player.position
				key(game,KEY_D)
				step(game,0.1)
				check(game.player.position.x > origin.x,"WASD unhandled input moves player")
				var up := InputEventKey.new()
				up.keycode = KEY_D
				up.pressed = false
				game.router._input(up)
			else:
				game._move(Vector2(90,70))
				step(game,0.1)
				check(game.player.position.x > 70,"Click-mode move callback advances player")
			var button := MOUSE_BUTTON_LEFT if shooting == "left" else MOUSE_BUTTON_RIGHT
			mouse(game,button,true,true)
			check(not game.bow.snapshot().charging,"Press over side UI cannot start charge")
			mouse(game,button,true)
			step(game,0.2)
			var charge: float = game.bow.charge_time
			check(charge > 0 and game.router.captured,movement+"/"+shooting+" captures charge")
			game.request_pause()
			var before: float = game.elapsed
			var coins: int = game.economy.coins
			game._buy_ammo()
			game._spawn_enemy("basic",Vector2(100,100))
			mouse(game,button,false,true)
			step(game,2)
			check(game.elapsed == before and game.bow.charge_time == charge and game.economy.coins == coins and game.enemies.is_empty(),"Pause freezes charge/time and gates shop/spawns")
			game.resume_game()
			game._process(0)
			check(game.arrows.is_empty() and game.bow.charge_time == charge,"Resume does not auto shoot/reset charge")
			mouse(game,button,true)
			check(game.bow.charge_time == charge and game.router.captured,"Explicit press recaptures preserved charge")
			mouse(game,button,false,true)
			check(game.arrows.size() == 1,"Global release over UI emits one shot")
			step(game,0.01)
			var arrow: Node2D = game.arrows[0]
			var arrow_position: Vector2 = arrow.position
			var life: float = arrow.life_left
			key(game,KEY_SPACE)
			check(game.player.dash_left > 0,"Space requests dash")
			var dash: float = game.player.dash_left
			game._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
			game._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
			step(game,1)
			check(game.phase == "PAUSED" and game.player.dash_left == dash and arrow.life_left == life and arrow.position == arrow_position,"Focus loss freezes dash and flying arrow")
			game.resume_game()
			step(game,1)
			game.bow.reset()
			game.player.position = Vector2(0,45)
			game.player.destination = game.player.position
			if movement == "wasd": key(game,KEY_E)
			else: game._move(Vector2.ZERO)
			step(game,0.5)
			check(game.player.mounted,"Configured interaction mounts nearby tower")
			key(game,KEY_SPACE)
			check(not game.player.mounted,"Dash dismounts tower")
			step(game,1.1)
			var melee: float = game.player.melee_cooldown
			mouse(game,MOUSE_BUTTON_MIDDLE,true)
			check(game.player.melee_cooldown > melee,"Middle button requests melee")
			game.queue_free()
			paused = false
			await process_frame
	game = fixture()
	game.start_run()
	game._next_wave()
	game._process(0.01)
	var spawned: Node2D = game.enemies[0]
	var enemy_position: Vector2 = spawned.position
	var spawn_clock: float = game.wave_manager.spawn_timer
	var world_elapsed: float = game.elapsed
	game.pickups.spawn_pickup("coin",1,Vector2(100,100))
	game.feedback.burst(Vector2.ZERO,1,Color.WHITE,10)
	var particle_life: float = game.feedback.particles[0].life
	game.request_pause()
	step(game,2)
	check(spawned.position == enemy_position and game.wave_manager.spawn_timer == spawn_clock and game.elapsed == world_elapsed and game.feedback.particles[0].life == particle_life,"WAVE pause freezes enemies/spawner/world feedback clocks")
	game.resume_game()
	spawned.queue_free()
	game.enemies.clear()
	game.wave_manager.active = false
	game.phase = "PREP"
	game.pickups.clear()
	await process_frame
	await combat_contracts(game)
	game.queue_free()
	paused = false
	await process_frame
	if had_save:
		var file := FileAccess.open(Save.SAVE_PATH,FileAccess.WRITE)
		file.store_string(old_save)
		file.close()
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(Save.SAVE_PATH))
	print("V2 INTEGRATION checks=",checks," failures=",failures)
	quit(0 if failures == 0 else 1)

func combat_contracts(game: Control) -> void:
	game.economy.coins = 0
	game.economy.ammo = 0
	game.player.position = Vector2(70,70)
	game.player.destination = game.player.position
	game.aim = Vector2.RIGHT
	game._begin()
	check(not game.bow.snapshot().charging,"Zero ammo cannot start charge")
	for kind: String in ["basic","shield"]:
		game._spawn_enemy(kind,Vector2(92,70))
		var enemy: Node2D = game.enemies.back()
		var armor: bool = enemy.armor
		var before: int = game.score
		for _hit in range(120):
			if enemy.dead: break
			enemy.position = Vector2(92,70)
			game._melee()
			game.player.tick(0.5,false)
		check(enemy.dead and enemy.death_source == "melee" and game.score == before + 1,"Zero-resource melee kills "+kind+" exactly once")
		check(not armor or enemy.armor,"Melee respects protection")
		check(game.economy.coins == 0 and game.economy.ammo == 0,"Kill creates physical resources without credit")
		enemy.take_hit(999,true)
		check(game.score == before+1,"Repeated dead hit grants no extra kill")
		await process_frame
		game.enemies.clear()
	var amounts := {"coin":0,"arrow":0}
	for pack: Dictionary in game.pickups.records: amounts[pack.kind] += int(pack.amount)
	check(amounts.arrow == 4 and amounts.coin > 0,"Each melee death drops two arrows plus coins")
	game.pickups.tick(0,Vector2(92,70),true,100,100)
	check(game.economy.ammo == 4 and game.economy.coins == amounts.coin,"Nearby physical resources collect exact amounts")
	game._begin()
	game.bow.tick(0.1)
	game._release()
	check(game.economy.ammo == 3 and game.arrows.size() == 1,"Collected melee arrows restore shooting")
	for arrow: Node2D in game.arrows: arrow.finish("cleanup",arrow.position)
	game.arrows.clear()
	await process_frame
	game.pickups.clear()
	for at: Vector2 in [Vector2(100,100),Vector2(130,112),Vector2(160,90)]: game._spawn_enemy("shield",at)
	var spectral := shot(game,Vector2(60,95),{"spectral":true,"pierce":-1,"half_width":18.0})
	spectral.tick(0.35)
	for enemy: Node2D in game.enemies:
		check(enemy.armor and is_equal_approx(enemy.hp,enemy.max_hp-7),"Spectral corridor hits protected row once without breaking")
	game._segment(Vector2(60,95),Vector2(180,95),spectral)
	for enemy: Node2D in game.enemies: check(is_equal_approx(enemy.hp,enemy.max_hp-7),"Same spectral ID cannot take second damage")
	for enemy: Node2D in game.enemies: enemy.queue_free()
	game.enemies.clear()
	spectral.finish("cleanup",spectral.position)
	game.arrows.clear()
	await process_frame
	# Reverse insertion order deliberately: first geometric collider must win.
	game._spawn_enemy("basic",Vector2(120,100))
	var far: Node2D = game.enemies.back()
	game._spawn_enemy("shield",Vector2(90,100))
	var near: Node2D = game.enemies.back()
	var green := shot(game,Vector2(60,95),{"critical":true,"damage":1.0})
	green.tick(0.25)
	check(not near.armor and far.hp == far.max_hp,"Green breaks first protection; collider order beats insertion order")
	for enemy: Node2D in game.enemies: enemy.queue_free()
	game.enemies.clear()
	game.arrows.clear()
	await process_frame
	game.pickups.clear()
	var low := shot(game,Vector2(60,130),{"range_limited":true,"range":65.0})
	low.tick(1)
	low.finish("boundary",low.position)
	check(game.pickups.records.size() == 1 and game.pickups.records[0].amount == 1,"Low miss yields exactly one pickup")
	var high := shot(game,Vector2(60,-130),{"lifetime":1.0,"speed":900.0})
	high.tick(1)
	check(game.pickups.records.size() == 2,"Boundary plus lifetime in same tick yields one pickup")
	var visible := shot(game,Vector2(200,50),{"speed":10.0})
	game._process(0.1)
	check(not visible.is_finished and visible.position.x > 180,"Green outside viewport survives inside arena")
	game.pickups.spawn_pickup("coin",9,Vector2(-100,-100))
	var records: int = game.pickups.records.size()
	game._next_wave()
	game.wave_manager.active = false
	game.wave_manager.pending = 0
	game._wave_completed(1,10)
	check(game.phase == "CHOICE" and game.pickups.records.size() == records,"Uncollected resources persist through interwave")
	var offers: Array = game.upgrades.offers()
	game._choose_upgrade(str(offers[0].id))
	game.player.invulnerable = 0
	game._attacked("player",10000)
	var respawn: float = game.respawn_left
	game.request_pause()
	step(game,5)
	check(game.respawn_left == respawn and not game.player.alive,"Pause freezes pending respawn")
	game.resume_game()
	step(game,respawn+0.01)
	check(game.player.alive,"Respawn resumes with cheese alive")
	game._attacked("tower",10000)
	check(game.phase == "OVER" and game.arrows.is_empty() and game.pickups.records.is_empty(),"Defeat cleans projectiles and resources")
