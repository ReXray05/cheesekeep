extends SceneTree

const GameScene = preload("res://scenes/game/game.tscn")
const SaveScript = preload("res://scripts/systems/persistence.gd")
var checks: int = 0
var failures: int = 0
var prior_save: String = ""
var had_save: bool = false
var simulated_frames: int = 0

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
	return game

func step(game: Control, frames: int) -> void:
	for index: int in range(frames):
		game._process(1.0 / 60.0)
		simulated_frames += 1

func run() -> void:
	had_save = FileAccess.file_exists(SaveScript.SAVE_PATH)
	if had_save:
		prior_save = FileAccess.get_file_as_string(SaveScript.SAVE_PATH)
	SaveScript.save([])
	var game: Control = make_game()
	game.wave_manager.rng.seed = 1042
	game.upgrades.rng.seed = 77
	game.bow.rng.seed = 991
	await process_frame
	check(not game.prototype and game.phase == "PREP", "Playable scene begins in preparation")
	var initial_coins: int = game.economy.coins
	game._repair()
	check(game.economy.coins == initial_coins, "Repair at full tower health does not charge")
	game.player.go_to(Vector2.ZERO)
	step(game, 60)
	check(game.player.mounted, "Tower click approaches and mounts")
	game._attacked("tower", 10.0)
	check(is_equal_approx(game.tower_max - game.tower_hp, 15.0), "Mounted tower takes 1.5 times damage")
	game._attacked("player", 10.0)
	check(is_equal_approx(game.player.hp, game.player.max_hp), "Mounted archer is immune")
	game.player.go_to(Vector2(0, 70))
	step(game, 60)
	check(not game.player.mounted and game.player.position.distance_to(Vector2(0, 70)) < 1.0, "Ground destination dismounts and walks")
	game.player.go_to(Vector2.ZERO)
	step(game, 60)
	await process_frame
	for wave_index: int in range(1, 4):
		game._next_wave()
		game._next_wave()
		check(game.wave_manager.wave == wave_index and game.phase == "WAVE", "Manual next starts one wave only")
		if wave_index == 1:
			var ammo_before: int = game.economy.ammo
			var coins_before: int = game.economy.coins
			game._buy_ammo()
			check(game.phase == "WAVE" and game.economy.ammo == ammo_before + 10 and game.economy.coins == coins_before - 6, "Buying arrows during combat does not pause")
		var frames: int = 0
		while game.phase == "WAVE" and frames < 8000:
			var target: Node2D = find_target(game)
			if target != null and game.player.alive:
				var distance: float = game.player.bow_origin().distance_to(target.position)
				var lead: Vector2 = target.move_direction * target.speed * distance / float(game.config.bow.speed_opt)
				game.aim = (target.position + Vector2(0, -5) + lead - game.player.bow_origin()).normalized()
				if not bool(game.bow.snapshot()["charging"]):
					game._begin()
				elif game.bow.charge_time >= float(game.config.bow.sweet_start) + 0.04:
					game._release()
			step(game, 1)
			frames += 1
			if frames % 45 == 0:
				await process_frame
		print("BOT WAVE ", wave_index, " frames=", frames, " kills=", game.score, " tower=", game.tower_hp, " coins=", game.economy.coins, " phase=", game.phase)
		check(game.phase == "CHOICE", "Rat-killing bot completes wave " + str(wave_index))
		if game.phase != "CHOICE":
			break
		var offers: Array = game.upgrades.offers()
		var coins_before: int = game.economy.coins
		var history_before: int = game.upgrades.history.size()
		game._choose_upgrade(str(offers[0]["id"]))
		check(game.phase == "PREP" and game.upgrades.history.size() == history_before + 1 and game.economy.coins == coins_before, "Free choice grants exactly one rank")
		game._choose_upgrade(str(offers[0]["id"]))
		check(game.upgrades.history.size() == history_before + 1, "Duplicate choice cannot add rank")
		var completed_number: int = game.wave_manager.wave
		step(game, 120)
		check(game.phase == "PREP" and game.wave_manager.wave == completed_number and game.enemies.is_empty(), "Between waves remains manual with no enemies")
		if game.tower_hp < game.tower_max:
			var old_hp: float = game.tower_hp
			coins_before = game.economy.coins
			game._repair()
			check(game.tower_hp > old_hp and game.economy.coins == coins_before - int(game.config.economy.repair_price), "Real repairs restore health and deduct price")
	if game.phase != "OVER":
		await test_death_and_end(game)
	game.queue_free()
	await process_frame
	var restart: Control = make_game()
	await process_frame
	check(restart.phase == "PREP" and restart.wave_manager.wave == 0 and restart.score == 0 and restart.enemies.is_empty() and restart.arrows.is_empty(), "New run resets waves actors projectiles and score")
	check(restart.economy.coins == int(restart.base_config.economy.start_coins), "New run resets unspent currency")
	check(restart.upgrades.history == SaveScript.load_history(), "New run uses retained history")
	restart.queue_free()
	await process_frame
	if had_save:
		var backup: FileAccess = FileAccess.open(SaveScript.SAVE_PATH, FileAccess.WRITE)
		backup.store_string(prior_save)
		backup.close()
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SaveScript.SAVE_PATH))
	print("INTEGRATION TESTS: ", checks, " checks, ", failures, " failures; simulation frames=", simulated_frames)
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

func test_death_and_end(game: Control) -> void:
	# The last rat may die while the bot has already begun its next draw.
	# Resolve it through release and let normal recovery/projectile expiry run.
	game._release()
	step(game, 200)
	game.player.go_to(Vector2(0, 70))
	step(game, 60)
	game._begin()
	step(game, 15)
	check(bool(game.bow.snapshot()["charging"]), "Charging before lethal player attack")
	game._attacked("player", game.player.hp + 1.0)
	check(not game.player.alive and not bool(game.bow.snapshot()["charging"]), "Death interrupts charge")
	game._release()
	check(game.arrows.is_empty(), "Dead player cannot emit former charge")
	step(game, 160)
	check(game.player.alive and is_equal_approx(game.player.hp, game.player.max_hp), "Player revives while cheese remains alive")
	game._begin()
	step(game, 54)
	game._release()
	check(game.arrows.size() == 1, "Revived player can shoot")
	step(game, 65)
	game._begin()
	step(game, 15)
	game._release()
	game._attacked("player", game.player.hp + 1.0)
	check(not game.player.alive and game.respawn_left > 0.0, "Second death starts pending respawn")
	var expected: Array = SaveScript.retain(game.upgrades.history, game.economy.coins, int(game.config.economy.retention_coins))
	game._attacked("tower", game.tower_hp + 1.0)
	check(game.phase == "OVER" and game.arrows.is_empty() and not game.wave_manager.active, "Tower destruction freezes run and clears arrows")
	check(SaveScript.load_history() == expected and int(game.result.retained) == expected.size(), "Death saves money-derived retained prefix")
	var coins_before: int = game.economy.coins
	var score_before: int = game.score
	var elapsed_before: float = game.elapsed
	game._buy_ammo()
	game._repair()
	game._next_wave()
	game._begin()
	game._release()
	game._attacked("tower", 100)
	step(game, 60)
	check(game.economy.coins == coins_before and game.score == score_before and game.elapsed == elapsed_before and game.arrows.is_empty(), "Game-over ignores spending spawning shots damage and time")
	step(game, 180)
	check(not game.player.alive, "Destroyed tower prevents pending respawn")
