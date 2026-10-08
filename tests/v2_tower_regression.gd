extends SceneTree

const Geometry = preload("res://scripts/systems/tower_geometry.gd")
const Player = preload("res://scripts/player/player_controller.gd")
var checks: int = 0
var failures: int = 0

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var player: Node2D = Player.new()
	root.add_child(player)
	player.tower_enabled = true
	# The raised image must not block the strip of floor behind the cheese.
	check(Geometry.constrain_motion(Vector2(-90,-20),Vector2(90,-20),7).is_equal_approx(Vector2(90,-20)), "Rear passage is open")
	check(not Geometry.TOWER_RECT.has_point(Vector2(0,-22)), "Raised sprite is not solid")
	check(Geometry.TOWER_CLICK_RECT.has_point(Vector2(0,-22)), "Raised sprite remains clickable")
	var slide: Vector2 = Geometry.slide_motion(Vector2(-40,0),Vector2(-20,20),7)
	check(slide.y > 19 and slide.x < -34, "Diagonal walking slides along the wall")
	check(not Geometry.TOWER_RECT.grow(7).has_point(slide), "Sliding stays outside solid")
	var stopped: Vector2 = Geometry.constrain_motion(Vector2(-100,10),Vector2(100,10),7)
	check(stopped.x < -34, "Dash sweep still blocks the base")
	var points: Array[Vector2] = [Vector2(-90,-20),Vector2(90,-20),Vector2(0,-80),Vector2(0,90),Vector2(-80,10),Vector2(80,10),Vector2(-75,70),Vector2(75,70)]
	for from in points:
		for target in points:
			if from == target: continue
			player.clear_actions()
			player.position = from
			player.mounted = false
			player.set_movement_input(Vector2.ZERO,false)
			player.go_to(target)
			var penetrated: bool = false
			for _tick in range(400):
				player.tick(1.0/60.0,false)
				penetrated = penetrated or Geometry.TOWER_RECT.grow(7).has_point(player.position)
			check(player.position.distance_to(target)<0.1, "Click route reaches destination %s -> %s" % [from,target])
			check(not penetrated, "Click route never enters the base")
	player.position = Vector2(0,-80)
	player.go_to(Vector2(0,-22))
	for _tick in range(120): player.tick(1.0/60.0,false)
	check(player.mounted, "Clicking the upper sprite still approaches and mounts")
	player.free()
	print("V2 TOWER REGRESSION: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)
