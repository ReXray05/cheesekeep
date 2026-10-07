extends SceneTree

const BowScript = preload("res://scripts/weapons/bow_controller.gd")
const ArrowScript = preload("res://scripts/projectiles/arrow_physics.gd")
const EnemyScript = preload("res://scripts/enemies/enemy_controller.gd")
const PlayerScript = preload("res://scripts/player/player_controller.gd")

var failures: int = 0
var checks: int = 0
var shots: Array[Dictionary] = []
var death_rewards: Array[int] = []
var segments: Array[Dictionary] = []

func _initialize() -> void:
	call_deferred("run_tests")

func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + description)

func capture_shot(data: Dictionary) -> void:
	shots.append(data)

func capture_death(reward: int) -> void:
	death_rewards.append(reward)

func capture_segment(from: Vector2, to: Vector2) -> void:
	segments.append({"from": from, "to": to})

func run_tests() -> void:
	test_bow()
	test_break_rates()
	test_arrow()
	test_enemy()
	test_player()
	print("CORE TESTS: ", checks, " assertions, ", failures, " failures")
	quit(0 if failures == 0 else 1)

func test_bow() -> void:
	var bow: Node = BowScript.new()
	root.add_child(bow)
	bow.setup({"break_peak_rate": 0.0})
	bow.rng.seed = 7345
	bow.shot.connect(capture_shot)
	check(bow.begin_charge(), "Idle accepts charge")
	check(not bow.begin_charge(), "Repeated down does not reset charge")
	bow.tick(0.84)
	check(not bool(bow.snapshot()["critical"]), "Before green is not critical")
	bow.tick(0.06)
	check(bool(bow.snapshot()["critical"]), "Green reports critical")
	bow.release(Vector2(0.6, 0.8))
	check(shots.size() == 1 and bool(shots[0]["critical"]), "Release emits exactly one critical")
	check(is_equal_approx(float(shots[0]["damage"]), 51.0), "Green damage includes critical multiplier")
	bow.release(Vector2.RIGHT)
	check(shots.size() == 1, "Repeated release never duplicates shot")
	var aim: Vector2 = Vector2(0.6, 0.8)
	for charge: float in [0.0, 0.4, 0.90, 1.5, 2.3]:
		var offsets: Array[float] = []
		for sample: int in range(80):
			bow.begin_charge()
			bow.tick(charge)
			var preview: Dictionary = bow.snapshot()
			bow.release(aim)
			var data: Dictionary = shots.back()
			var endpoint: Vector2 = data["direction"] * float(data["range"])
			var side: float = endpoint.dot(aim.orthogonal())
			check(absf(endpoint.dot(aim) - float(preview["range"])) < 0.001, "Shot reaches displayed base")
			check(absf(side) <= float(preview["half_width"]) + 0.001, "Shot lies within displayed base")
			offsets.append(side / float(preview["half_width"]))
		var mean: float = 0.0
		for offset: float in offsets:
			mean += offset / float(offsets.size())
		check(absf(mean) < 0.25, "Dispersion samples both sides of base")
	check(not bool(shots.back()["critical"]) and int(shots.back()["pierce"]) == 3, "Red rewards penetration without critical")
	bow.reset()
	check(not bool(bow.snapshot()["charging"]), "Reset interrupts charge")
	bow.free()

func test_break_rates() -> void:
	var bow: Node = BowScript.new()
	root.add_child(bow)
	bow.setup({})
	var rates: Array[float] = []
	for fps: int in [30, 60, 144]:
		var broken: int = 0
		for trial: int in range(1000):
			bow.reset()
			bow.rng.seed = 999 + trial
			bow.begin_charge()
			var elapsed: float = 0.0
			while elapsed < 2.2 and bow.state != 3:
				var delta: float = minf(1.0 / float(fps), 2.2 - elapsed)
				bow.tick(delta)
				elapsed += delta
			if bow.state == 3:
				broken += 1
		var rate: float = float(broken) / 1000.0
		rates.append(rate)
		print("BREAK RATE ", fps, " FPS: ", rate)
		# Analytic hazard from .98 to 2.2 is .5 * .7 * 1.22.
		check(absf(rate - (1.0 - exp(-0.427))) < 0.07, "Break risk matches integrated hazard at " + str(fps) + " FPS")
	check(absf(rates.max() - rates.min()) < 0.08, "Break probability stable across frame rates")
	bow.state = 3
	bow.cooldown_left = 1.5
	check(not bow.begin_charge(), "Broken bow rejects charge")
	bow.tick(1.5)
	check(bow.begin_charge(), "Cooldown recovers bow")
	bow.free()

func test_arrow() -> void:
	var arrow: Node2D = ArrowScript.new()
	root.add_child(arrow)
	arrow.setup(Vector2(5, 7), {"direction": Vector2.RIGHT, "speed": 450.0, "range": 10.0, "pierce": 2})
	arrow.moved_segment.connect(capture_segment)
	check(not arrow.register_hit(12), "First penetrating impact preserves arrow")
	check(not arrow.register_hit(12) and arrow.remaining_hits == 1, "Duplicate target does not consume penetration")
	check(arrow.register_hit(13), "Second distinct target exhausts penetration")
	arrow.tick(1.0)
	check(segments.size() == 1, "Fast arrow exposes swept segment")
	check(segments[0]["from"] == Vector2(5, 7) and segments[0]["to"] == Vector2(15, 7), "Long frame clamps segment at range")
	check(arrow.is_queued_for_deletion(), "Range exhaustion removes arrow")
	arrow.tick(1.0)
	check(segments.size() == 1, "Expired arrow never emits another segment")

func test_enemy() -> void:
	var enemy: Node2D = EnemyScript.new()
	root.add_child(enemy)
	enemy.configure("basic", 1)
	enemy.died.connect(capture_death)
	enemy.armor = true
	var result: Dictionary = enemy.take_hit(20.0, false)
	check(bool(result["blocked"]) and is_equal_approx(enemy.hp, 25.0), "Armor blocks most ordinary damage")
	result = enemy.take_hit(10.0, true)
	check(not enemy.armor and bool(result["broken"]) and is_equal_approx(enemy.hp, 15.0), "Critical breaks armor and damages health")
	result = enemy.take_hit(51.0, true)
	check(bool(result["killed"]) and is_equal_approx(float(result["dealt"]), 15.0), "Lethal hit reports actual health removed")
	enemy.take_hit(51.0, true)
	check(death_rewards.size() == 1 and death_rewards[0] == 3, "Dead target pays reward exactly once")
	var old_position: Vector2 = enemy.position
	enemy.tick(1.0, Vector2(100, 100), Vector2.ZERO, true, false)
	check(enemy.position == old_position, "Dead enemy stops movement")
	enemy.free()

func test_player() -> void:
	var player: Node2D = PlayerScript.new()
	root.add_child(player)
	player.go_to(Vector2(200, 0))
	player.tick(0.5, false)
	var normal_distance: float = player.position.x
	player.position = Vector2.ZERO
	player.tick(0.5, true)
	check(is_equal_approx(player.position.x / normal_distance, 0.65), "Charging movement penalty applies")
	player.hurt(10.0)
	check(player.alive and is_equal_approx(player.hp, 90.0), "Ordinary hit is nonlethal")
	player.alive = false
	var dead_position: Vector2 = player.position
	player.tick(1.0, false)
	check(player.position == dead_position, "Dead player cannot move")
	player.free()
