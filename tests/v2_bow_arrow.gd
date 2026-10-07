extends SceneTree

const Bow = preload("res://scripts/weapons/bow_controller.gd")
const Arrow = preload("res://scripts/projectiles/arrow_physics.gd")
var checks: int = 0
var failures: int = 0
var shots: Array[Dictionary] = []
var endings: Array[Dictionary] = []
var segments: Array[Dictionary] = []
var snaps: int = 0
var recoveries: int = 0

func _initialize() -> void:
	call_deferred("run_tests")

func check(ok: bool, description: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(description)

func run_tests() -> void:
	var bow: Node = Bow.new()
	root.add_child(bow)
	bow.setup({})
	bow.shot.connect(func(data: Dictionary) -> void: shots.append(data))
	bow.snapped.connect(func() -> void: snaps += 1)
	bow.recovered.connect(func() -> void: recoveries += 1)
	for timing: Array in [[0.84, "low"], [0.85, "perfect"], [0.98, "perfect"], [0.99, "overcharge"], [1.55, "spectral"], [1.67, "spectral"], [1.68, "final"]]:
		bow.reset()
		check(bow.begin_charge(), "Accept fresh charge")
		check(not bow.begin_charge(), "Repeated input retains charge")
		bow.tick(float(timing[0]))
		check(bow.snapshot().stage == timing[1], "Deterministic threshold " + str(timing))
		bow.release(Vector2(0.6, 0.8))
		check(shots.back().stage == timing[1], "Payload retains stage")
		check(bool(shots.back().range_limited) == (timing[1] == "low"), "Only low has physical range limit")
		var count: int = shots.size()
		bow.release(Vector2.RIGHT)
		check(shots.size() == count, "Repeated release is inert")
	bow.begin_charge()
	bow.tick(1.60)
	bow.release(Vector2(0.6, 0.8))
	var spectral: Dictionary = shots.back()
	check(spectral.spectral and not spectral.critical and spectral.pierce == -1, "Spectral is unlimited noncritical")
	check(is_equal_approx(spectral.damage, 28.0) and is_equal_approx(spectral.speed, 420.0) and is_equal_approx(spectral.half_width, 18.0), "Spectral tuning")
	check(spectral.direction.is_equal_approx(Vector2(0.6, 0.8)), "Spectral central aim has no hidden dispersion")
	for fps: int in [30, 60, 144]:
		bow.reset()
		bow.begin_charge()
		var frames: int = 0
		while bow.state != Bow.State.COOLDOWN and frames < 1000:
			bow.tick(1.0 / float(fps))
			frames += 1
		check(absf(float(frames) / float(fps) - 1.85) <= 1.0 / float(fps) + 0.0001, "Deterministic break across FPS")
	bow.reset()
	bow.begin_charge()
	var previous_snaps: int = snaps
	bow.tick(20.0)
	check(snaps == previous_snaps + 1 and bow.state == Bow.State.COOLDOWN, "Long step breaks once, starts full recovery")
	var shot_count: int = shots.size()
	bow.release(Vector2.RIGHT)
	check(shots.size() == shot_count, "Broken charge cannot shoot")
	check(not bow.begin_charge(), "Broken bow rejects charge")
	bow.tick(1.49)
	check(recoveries == 0, "No early recovered signal")
	bow.tick(0.02)
	bow.tick(10.0)
	check(recoveries == 1 and bow.state == Bow.State.IDLE, "Recovery emitted once")
	bow.free()

	var arrow: Node2D = make_arrow({"direction": Vector2.RIGHT, "speed": 420.0, "range": 10.0, "spectral": true, "range_limited": false, "lifetime": 6.0})
	for id: int in range(100):
		check(not arrow.register_hit(id), "Unlimited spectral budget")
	check(not arrow.register_hit(0) and arrow.hit_count == 100 and arrow.remaining_hits == -1, "One spectral hit per ID")
	arrow.tick(20.0)
	check(segments.back().to == Vector2(2520, 0), "Long frame stops at lifetime, independent of indicator range")
	check(endings.back().reason == "lifetime" and not endings.back().recoverable and endings.back().hit_count == 100, "Hits forbid recovery")
	var end_count: int = endings.size()
	arrow.finish("boundary", Vector2.ZERO)
	arrow.tick(1.0)
	check(endings.size() == end_count, "Finish is idempotent")

	arrow = make_arrow({"direction": Vector2.RIGHT, "speed": 500.0, "range": 12.0})
	arrow.tick(10.0)
	check(segments.back().to == Vector2(12, 0), "Legacy range segment is clamped")
	check(endings.back().reason == "range" and endings.back().recoverable, "Missed low arrow recovers")
	arrow = make_arrow({"direction": Vector2.RIGHT, "speed": 500.0, "range_limited": false, "pierce": 2})
	check(not arrow.register_hit(1), "First normal hit leaves one budget")
	check(not arrow.register_hit(1) and arrow.remaining_hits == 1, "Duplicate normal hit is ignored")
	check(arrow.register_hit(2), "Second hit exhausts finite budget")
	arrow.finish("hits", Vector2(8, 0))
	check(not endings.back().recoverable, "Hit finish not recoverable")
	arrow = make_arrow({"direction": Vector2.RIGHT, "speed": 1000.0, "range_limited": false, "lifetime": 0.1})
	arrow.moved_segment.connect(func(_from: Vector2, _to: Vector2) -> void: arrow.finish("boundary", Vector2(20, 0)))
	end_count = endings.size()
	arrow.tick(10.0)
	check(endings.size() == end_count + 1 and endings.back().reason == "boundary" and endings.back().position == Vector2(20, 0), "Collision callback finish wins over same-step lifetime")
	check(not arrow.register_hit(77) and arrow.hit_count == 0, "Finished guard prevents late damage registration")
	arrow = make_arrow({})
	arrow.finish("cleanup", Vector2.ZERO)
	check(not endings.back().recoverable, "Cleanup creates no pickup")
	print("V2 BOW ARROW: ", checks, " assertions, ", failures, " failures")
	quit(0 if failures == 0 else 1)

func make_arrow(data: Dictionary) -> Node2D:
	var arrow: Node2D = Arrow.new()
	root.add_child(arrow)
	arrow.setup(Vector2.ZERO, data)
	arrow.finished.connect(func(payload: Dictionary) -> void: endings.append(payload))
	arrow.moved_segment.connect(func(from: Vector2, to: Vector2) -> void: segments.append({"from": from, "to": to}))
	return arrow
