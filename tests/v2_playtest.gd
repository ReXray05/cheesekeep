extends SceneTree

# Deterministic technical bot, not evidence of human enjoyment or browser FPS.
const GameScene = preload("res://scenes/game/game.tscn")
const Save = preload("res://scripts/systems/persistence.gd")
var checks := 0
var failures := 0
var frames := 0
var saw_boss := false
var excursions := 0
var purchases := 0
var old_save := ""
var had_save := false

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("V2 playtest: "+label)

func fixture() -> Control:
	var game: Control = GameScene.instantiate()
	root.add_child(game)
	game.set_process(false)
	game.router.set_process(false)
	game.router.inside = false
	game.feedback.audio_enabled = false
	game.start_run()
	game.wave_manager.rng.seed = 1042
	game.upgrades.rng.seed = 77
	game.bow.rng.seed = 991
	return game

func step(game: Control) -> void:
	game._process(1.0/60.0)
	frames += 1

func target(game: Control) -> Node2D:
	var best: Node2D = null
	var priority := INF
	for enemy: Node2D in game.enemies:
		if not is_instance_valid(enemy) or enemy.dead or enemy.is_queued_for_deletion(): continue
		if enemy.kind == "boss": saw_boss = true
		var score: float = enemy.position.length()+enemy.hp*0.04
		if score < priority:
			priority = score
			best = enemy
	return best

func run() -> void:
	had_save = FileAccess.file_exists(Save.SAVE_PATH)
	if had_save: old_save = FileAccess.get_file_as_string(Save.SAVE_PATH)
	Save.save([],Save.DEFAULT_SETTINGS)
	var game := fixture()
	game.player.go_to(Vector2.ZERO)
	for _frame in 60: step(game)
	for wave in range(1,6):
		game._next_wave()
		var started: int = frames
		while game.phase == "WAVE" and frames-started < 18000:
			var enemy := target(game)
			if game.economy.ammo < 5 and game.economy.coins >= int(game.config.economy.ammo_price):
				game._buy_ammo()
				purchases += 1
			if game.tower_hp <= game.tower_max-30 and game.economy.coins >= int(game.config.economy.repair_price): game._repair()
			if enemy != null and game.player.alive:
				var distance: float = game.player.bow_origin().distance_to(enemy.position)
				var lead: Vector2 = enemy.move_direction * enemy.speed * distance / float(game.config.bow.speed_opt)
				game.aim = (enemy.position+Vector2(0,-5)+lead-game.player.bow_origin()).normalized()
				if not game.bow.snapshot().charging: game._begin()
				elif game.bow.charge_time >= float(game.config.bow.sweet_start)+0.04: game._release()
			step(game)
			if frames % 60 == 0: await process_frame
		print("V2 BOT wave=",wave," frames=",frames-started," kills=",game.score," tower=",game.tower_hp," coins=",game.economy.coins," ammo=",game.economy.ammo," pickups=",game.pickups.records.size()," phase=",game.phase)
		check(game.phase == "CHOICE","Bot completes wave "+str(wave))
		if game.phase != "CHOICE": break
		game._release()
		var offers: Array = game.upgrades.offers()
		var old_count: int = game.upgrades.history.size()
		var selected: String = str(offers[0].id)
		# A modest damage/cadence preference; offers remain their seeded real choices.
		for offer: Dictionary in offers:
			if offer.id in ["sharp_arrows","fast_draw","strong_draw"]: selected = str(offer.id)
		game._choose_upgrade(selected)
		check(game.phase == "PREP" and game.upgrades.history.size() == old_count+1,"One real offered skill per clear")
		# Manual ground excursion gathers physical packs, then returns to safety.
		var trip := 0
		while not game.pickups.records.is_empty() and trip < 5000:
			var nearest: Vector2 = game.pickups.records[0].at
			var dist: float = game.player.position.distance_to(nearest)
			for pack: Dictionary in game.pickups.records:
				if game.player.position.distance_to(pack.at) < dist:
					nearest = pack.at
					dist = game.player.position.distance_to(nearest)
			game.player.go_to(nearest)
			game.aim = (nearest-game.player.position).normalized()
			if trip % 90 == 0: game._dash()
			step(game)
			trip += 1
			if trip % 60 == 0: await process_frame
		excursions += 1
		check(game.pickups.records.is_empty(),"Ground excursion collects all physical packs")
		if game.tower_hp < game.tower_max: game._repair()
		game.player.go_to(Vector2.ZERO)
		for _frame in 120: step(game)
	check(saw_boss,"Fifth wave includes real boss")
	check(excursions == 5,"Five manual pickup excursions")
	check(purchases > 0,"Bot uses real ammo shop transaction")
	if game.phase != "OVER":
		game.player.go_to(Vector2(0,70))
		for _frame in 90: step(game)
		game.player.invulnerable = 0
		var coins: int = game.economy.coins
		var ammo: int = game.economy.ammo
		game._attacked("player",10000)
		for _frame in 160: step(game)
		check(game.player.alive and game.economy.coins == coins and game.economy.ammo == ammo,"Real death/respawn grants no free resources")
	game.queue_free()
	paused = false
	await process_frame
	await performance_fixture()
	if had_save:
		var file := FileAccess.open(Save.SAVE_PATH,FileAccess.WRITE)
		file.store_string(old_save)
		file.close()
	else: DirAccess.remove_absolute(ProjectSettings.globalize_path(Save.SAVE_PATH))
	print("V2 TECHNICAL PLAYTEST checks=",checks," failures=",failures," frames=",frames," excursions=",excursions," shop=",purchases," boss=",saw_boss)
	quit(0 if failures == 0 else 1)

func performance_fixture() -> void:
	var before_scene := int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	var game := fixture()
	await process_frame
	var baseline := int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	for index in 80: game._spawn_enemy("basic",Vector2.from_angle(TAU*index/80.0)*250)
	for index in 50:
		game._shoot({"direction":Vector2.from_angle(TAU*index/50.0),"speed":10.0,"damage":1.0,"critical":false,"pierce":1,"range":200,"range_limited":false,"lifetime":6})
	# Avoid merge proximity while measuring 96 actual batched records.
	game.pickups.setup({"pickup_records":96,"pickup_merge_radius":0.0})
	for index in 96: game.pickups.spawn_pickup("coin",1,Vector2.from_angle(TAU*index/96.0)*180)
	for _burst in 100: game.feedback.burst(Vector2.ZERO,20,Color.WHITE,50)
	await process_frame
	check(game.enemies.size() == 80 and game.arrows.size() == 40,"Stress fixture respects real available ammo (40 of requested 50 shots)")
	# Complete the remaining ten through an explicit priced shop purchase.
	game._buy_ammo()
	for _arrow in 10: game._shoot({"direction":Vector2.RIGHT,"speed":10.0,"damage":1.0,"critical":false,"pierce":1,"range":200,"range_limited":false,"lifetime":6})
	check(game.arrows.size() == 50 and game.pickups.records.size() == 96,"Stress fixture reaches 80 rats / 50 arrows / 96 pickups")
	await process_frame
	var loaded := int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	check(game.feedback.particles.size() <= 80,"Feedback particles stay capped")
	var began := Time.get_ticks_usec()
	for _frame in 120: step(game)
	var micros := Time.get_ticks_usec()-began
	print("V2 STRESS nodes baseline=",baseline," loaded=",loaded," manual120ticks_us=",micros," particles=",game.feedback.particles.size()," pickups=",game.pickups.records.size())
	game._attacked("tower",10000)
	for enemy: Node2D in game.enemies:
		if is_instance_valid(enemy): enemy.queue_free()
	game.enemies.clear()
	game.feedback.enabled = false
	await process_frame
	await process_frame
	var cleaned := int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	print("V2 STRESS cleanup nodes=",cleaned," delta=",cleaned-baseline)
	check(game.arrows.is_empty() and game.pickups.records.is_empty() and game.feedback.particles.is_empty(),"Stress defeat cleans gameplay records and transient effects")
	game.queue_free()
	paused = false
	await process_frame
	await process_frame
	var after_scene := int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	print("V2 STRESS disposed nodes before=",before_scene," after=",after_scene)
	check(after_scene == before_scene,"Full scene disposal returns actual node count to baseline")
