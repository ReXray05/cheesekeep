extends Node
class_name WaveManager

signal spawn_requested(kind: String, position: Vector2)
signal completed(wave: int, reward: int)

var wave: int = 0
var pending: int = 0
var active: bool = false
var variety_enabled: bool = false
var config: Dictionary = {}
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var spawn_timer: float = 0.0

func _init() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/waves.json"))
	if parsed is Dictionary:
		config = parsed
	rng.randomize()

func start() -> void:
	if active:
		return
	wave += 1
	pending = int(config.get("first_count", 6)) + (wave - 1) * int(config.get("count_increment", 2))
	active = true
	spawn_timer = 0.0

func tick(delta: float, alive_count: int) -> void:
	if not active:
		return
	spawn_timer -= maxf(0.0, delta)
	var spawned: int = 0
	var cap: int = int(config.get("alive_cap", 80))
	var interval: float = maxf(float(config.get("minimum_interval", 0.4)), float(config.get("initial_interval", 1.1)) - float(wave - 1) * float(config.get("interval_decrement", 0.07)))
	while pending > 0 and spawn_timer <= 0.0 and alive_count + spawned < cap:
		var kind: String = "basic"
		if variety_enabled:
			kind = choose_kind()
		var angle: float = rng.randf_range(0.0, TAU)
		var radius: float = rng.randf_range(float(config.get("radius_min", 240)), float(config.get("radius_max", 300)))
		pending -= 1
		spawned += 1
		spawn_timer += interval
		spawn_requested.emit(kind, Vector2.from_angle(angle) * radius)
	if alive_count + spawned >= cap:
		# A cap must not accumulate a huge burst of overdue spawns.
		spawn_timer = maxf(spawn_timer, 0.0)
	if pending == 0 and alive_count == 0 and spawned == 0:
		active = false
		completed.emit(wave, int(config.get("base_reward", 8)) + wave * int(config.get("reward_per_wave", 2)))

func choose_kind() -> String:
	var spawned_index: int = int(config.get("first_count", 6)) + (wave - 1) * int(config.get("count_increment", 2)) - pending
	if wave >= 5 and wave % 5 == 0 and spawned_index == 0:
		return "boss"
	var candidates: Array[String] = ["basic"]
	var milestones: Array = config.get("variety", [])
	for item: Dictionary in milestones:
		if wave >= int(item.get("wave", 999)):
			candidates.append(str(item.get("kind", "basic")))
	return candidates[rng.randi_range(0, candidates.size() - 1)]
