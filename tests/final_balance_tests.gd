extends SceneTree

const GameScene = preload("res://scenes/game/game.tscn")
const SaveScript = preload("res://scripts/systems/persistence.gd")
var checks: int = 0
var failures: int = 0
var boss_seen: bool = false
var peak_enemies: int = 0
var peak_arrows: int = 0
var tick_us: int = 0
var frame_count: int = 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + description)

func make_game() -> Control:
	var game: Control = GameScene.instantiate()
	root.add_child(game)
	game.set_process(false)
	game.router.set_process(false)
	game.router.inside = false
	game.feedback.audio_enabled = false
	return game

func step(game: Control, frames: int) -> void:
	for index: int in range(frames):
		var started: int = Time.get_ticks_usec()
		game._process(1.0 / 60.0)
		tick_us += Time.get_ticks_usec() - started
		frame_count += 1
		peak_enemies = maxi(peak_enemies, game.enemies.size())
		peak_arrows = maxi(peak_arrows, game.arrows.size())
		for enemy: Node2D in game.enemies:
			if enemy.kind == "boss":
				boss_seen = true

func run() -> void:
	var had_save: bool = FileAccess.file_exists(SaveScript.SAVE_PATH)
	var prior: String = FileAccess.get_file_as_string(SaveScript.SAVE_PATH) if had_save else ""
	SaveScript.save([])
	var game: Control = make_game()
	game.wave_manager.rng.seed = 1042
	game.upgrades.rng.seed = 77
	game.bow.rng.seed = 991
	await process_frame
	game.player.go_to(Vector2.ZERO)
	step(game, 60)
	for number: int in range(1, 6):
		game._next_wave()
		var frames: int = 0
		while game.phase == "WAVE" and frames < 10000:
			if game.economy.ammo <= 8 and game.economy.coins >= int(game.config.economy.ammo_price):
				game._buy_ammo()
			if game.tower_hp < game.tower_max - float(game.config.economy.repair_hp) and game.economy.coins >= int(game.config.economy.repair_price):
				game._repair()
			var target: Node2D = find_target(game)
			if target != null and game.player.alive:
				var travel: float = game.player.bow_origin().distance_to(target.position) / float(game.config.bow.speed_opt)
				var lead: Vector2 = target.move_direction * target.speed * travel
				if target.windup_left > 0.0:
					lead = Vector2.ZERO
				game.aim = (target.position + Vector2(0, -5) + lead - game.player.bow_origin()).normalized()
				if not bool(game.bow.snapshot()["charging"]):
					game._begin()
				elif game.bow.charge_time >= float(game.config.bow.sweet_start) + 0.04:
					game._release()
			step(game, 1)
			frames += 1
			if frames % 30 == 0:
				await process_frame
		print("FINAL BOT wave=", number, " frames=", frames, " kills=", game.score, " cheese=", game.tower_hp, " coins=", game.economy.coins, " ammo=", game.economy.ammo, " phase=", game.phase)
		check(game.phase == "CHOICE", "Real shots complete wave " + str(number))
		if game.phase != "CHOICE":
			break
		var offers: Array = game.upgrades.offers()
		var choice: String = str(offers[0]["id"])
		for preferred: String in ["damage", "fast_draw", "piercing", "cheese", "precision"]:
			var found: bool = false
			for offer: Dictionary in offers:
				if str(offer["id"]) == preferred:
					choice = preferred
					found = true
					break
			if found:
				break
		game._choose_upgrade(choice)
		check(game.phase == "PREP", "One offered choice returns to manual preparation")
		game._release()
		step(game, 180)
	check(boss_seen and game.wave_manager.wave == 5 and game.phase == "PREP", "Fifth-wave boss present and defeated")
	check(peak_enemies <= 80 and peak_arrows <= 50, "Normal run stays inside entity limits")
	print("NORMAL RUN ticks=", frame_count, " avg_tick_us=", float(tick_us) / float(maxi(1, frame_count)), " peak_enemies=", peak_enemies, " peak_arrows=", peak_arrows)
	game.queue_free()
	await process_frame
	await stress()
	if had_save:
		var file: FileAccess = FileAccess.open(SaveScript.SAVE_PATH, FileAccess.WRITE)
		file.store_string(prior)
		file.close()
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SaveScript.SAVE_PATH))
	print("FINAL BALANCE TESTS: ", checks, " checks, ", failures, " failures")
	quit(0 if failures == 0 else 1)

func find_target(game: Control) -> Node2D:
	var closest: Node2D = null
	var distance: float = 150.0
	for enemy: Node2D in game.enemies:
		if not is_instance_valid(enemy) or enemy.dead or enemy.is_queued_for_deletion():
			continue
		var current: float = game.player.bow_origin().distance_to(enemy.position)
		if current < distance:
			distance = current
			closest = enemy
	return closest

func stress() -> void:
	var base_nodes: int = int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	var game: Control = make_game()
	await process_frame
	# Controlled load fixture, not a claim that normal input emits 50 shots at once.
	for index: int in range(80):
		game._spawn_enemy("basic", Vector2.from_angle(float(index) * TAU / 80.0) * 300.0)
	game.economy.earn(6)
	game._buy_ammo()
	var data: Dictionary = {"direction": Vector2.RIGHT, "speed": 190.0, "damage": 12.0, "critical": false, "pierce": 1, "range": 280.0}
	for index: int in range(50):
		game._shoot(data)
	for index: int in range(100):
		game.feedback.impact(Vector2.ZERO, true, false, true)
	check(game.enemies.size() == 80 and game.arrows.size() == 50 and game.feedback.particles.size() == 80, "Controlled fixture reaches stated enemy projectile effect limits")
	var node_peak: int = int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	var time_before: int = tick_us
	step(game, 120)
	check(game.arrows.is_empty(), "All stress arrows expire after lifetime/range/offscreen")
	check(game.feedback.particles.is_empty() and game.feedback.rings.is_empty(), "Stress feedback expires rather than accumulating")
	print("STRESS 80rats/50arrows/80particles: 120tick_avg_us=", float(tick_us - time_before) / 120.0, " peak_nodes=", node_peak, " baseline_nodes=", base_nodes)
	game.queue_free()
	await process_frame
	await process_frame
	check(int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)) <= base_nodes + 2, "Destroyed load scene returns node count to baseline")
