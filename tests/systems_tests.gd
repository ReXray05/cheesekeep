extends SceneTree

const WaveScript = preload("res://scripts/waves/wave_manager.gd")
const EconomyScript = preload("res://scripts/economy/economy_manager.gd")
const UpgradeScript = preload("res://scripts/upgrades/upgrade_manager.gd")
const SaveScript = preload("res://scripts/systems/persistence.gd")

var checks: int = 0
var failures: int = 0
var spawns: Array[Dictionary] = []
var completions: Array[Dictionary] = []

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + description)

func run() -> void:
	test_wave()
	test_economy()
	test_upgrades()
	test_save()
	print("SYSTEMS TESTS: ", checks, " checks, ", failures, " failures")
	quit(0 if failures == 0 else 1)

func test_wave() -> void:
	var wave: Node = WaveScript.new()
	root.add_child(wave)
	wave.rng.seed = 51
	wave.spawn_requested.connect(func(kind: String, point: Vector2) -> void: spawns.append({"kind": kind, "position": point}))
	wave.completed.connect(func(number: int, reward: int) -> void: completions.append({"wave": number, "reward": reward}))
	wave.start()
	wave.start()
	check(wave.wave == 1 and wave.pending == 6, "Active wave cannot start twice")
	wave.tick(10.0, 0)
	check(spawns.size() == 6 and wave.pending == 0 and wave.active, "Complete spawn batch waits for live enemies")
	for spawn: Dictionary in spawns:
		var point: Vector2 = spawn["position"]
		check(spawn["kind"] == "basic" and point.length() >= 239.999 and point.length() <= 300.001, "MVP spawns only basic rats on valid ring")
	wave.tick(0.1, 6)
	check(completions.is_empty(), "Live rats prevent wave completion")
	wave.tick(0.1, 0)
	wave.tick(10.0, 0)
	check(completions.size() == 1 and completions[0]["reward"] == 10, "Completion and reward emit exactly once")
	wave.start()
	check(wave.wave == 2 and wave.pending == 8, "Next wave grows by two")
	wave.tick(100.0, 80)
	check(wave.pending == 8, "Cap blocks spawns")
	wave.tick(0.0, 79)
	check(wave.pending == 7, "Released cap slot admits only one rat")
	wave.free()

func test_economy() -> void:
	var economy: RefCounted = EconomyScript.new()
	economy.setup({"start_coins": 10, "start_ammo": 0})
	check(not economy.consume_arrow() and economy.ammo == 0, "No negative ammunition")
	check(not economy.spend(11) and economy.coins == 10, "Insufficient balance leaves coins unchanged")
	check(not economy.spend(-10) and economy.coins == 10, "Negative spend cannot create money")
	check(economy.buy_ammo() and economy.ammo == 10 and economy.coins == 4, "Ammo purchase updates both resources")
	check(not economy.buy_ammo() and economy.ammo == 10 and economy.coins == 4, "Failed purchase is atomic")
	check(economy.consume_arrow() and economy.ammo == 9, "Emission consumes one arrow")
	economy.earn(-100)
	economy.earn(6)
	check(economy.coins == 10, "Only positive rewards count")

func test_upgrades() -> void:
	var upgrades: RefCounted = UpgradeScript.new()
	upgrades.setup([])
	upgrades.rng.seed = 88
	var first: Array = upgrades.offers()
	check(first.size() == 3 and first == upgrades.offers(), "Offers remain stable until acquisition")
	for offer: Dictionary in first:
		check(bool(offer.get("root", false)), "MVP offers only roots")
	check(not upgrades.acquire("precision"), "Locked child cannot be acquired")
	check(upgrades.acquire("fast_draw"), "Root can be acquired")
	upgrades.expanded = true
	check(upgrades.acquire("precision"), "Child becomes eligible after parent")
	check(not upgrades.acquire("unknown"), "Unknown upgrade rejected")
	var base: Dictionary = {"bow": {"sweet_start": 0.85, "sweet_end": 0.98, "overcharge_peak": 2.2, "width_min": 42.5, "width_opt": 3.5, "width_max": 27.5}, "player": {"charging_slow": 0.65}}
	var rebuilt: Dictionary = upgrades.rebuild(base)
	check(is_equal_approx(float(rebuilt["bow"]["sweet_start"]), 0.782), "Charge improvement affects timing")
	check(is_equal_approx(float(rebuilt["bow"]["width_max"]), 20.625), "Precision also affects dangerous red spread")
	check(base["bow"]["sweet_start"] == 0.85 and rebuilt == upgrades.rebuild(base), "Rebuild does not mutate base or compound effects")
	upgrades.setup(["precision", "fast_draw", "precision", "precision", "precision", "fake"])
	check(upgrades.history == ["fast_draw", "precision", "precision"], "Loaded history rejects missing parents, unknown IDs and excess ranks")
	upgrades.setup([])
	for rank: int in range(3):
		check(upgrades.acquire("damage"), "Legal root rank acquired")
	check(not upgrades.acquire("damage"), "Max rank enforced")

func test_save() -> void:
	var history: Array = ["fast_draw", "precision", "damage", "cheese"]
	check(SaveScript.retain(history, 0).is_empty(), "Zero money retains no progress")
	check(SaveScript.retain(history, 99) == ["fast_draw"], "Fraction is floored, not rounded")
	check(SaveScript.retain(history, 100) == ["fast_draw", "precision"], "Retained prefix preserves parent before child")
	check(SaveScript.retain(history, 200) == history and SaveScript.retain(history, 500) == history, "Threshold and higher retain all")
	check(SaveScript.save(history), "Save writes actual versioned file")
	check(SaveScript.load_history() == history, "History round-trips")
	check(SaveScript.save(["damage"]), "Second save replaces existing file")
	check(SaveScript.load_history() == ["damage"], "Replacement does not append stale history")
	var file: FileAccess = FileAccess.open(SaveScript.SAVE_PATH, FileAccess.WRITE)
	file.store_string("{broken")
	file.close()
	check(SaveScript.load_history().is_empty(), "Corrupt JSON recovers safely")
	file = FileAccess.open(SaveScript.SAVE_PATH, FileAccess.WRITE)
	file.store_string('{"version":1,"history":["repair","cheese","repair",55,"unknown"]}')
	file.close()
	check(SaveScript.load_history() == ["cheese", "repair"], "Disk load validates prerequisite order and IDs")
	file = FileAccess.open(SaveScript.SAVE_PATH, FileAccess.WRITE)
	file.store_string('{"version":{},"history":[]}')
	file.close()
	check(SaveScript.load_history().is_empty(), "Invalid version type recovers without conversion error")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SaveScript.SAVE_PATH))
