extends SceneTree

var _summons: int = 0
var _attacks: Array[float] = []
var _deaths: int = 0

func _initialize() -> void:
	var script: Script = load("res://scripts/enemies/enemy_controller.gd")
	var expected: Dictionary = {"basic": [30, 29, 9], "runner": [18, 55, 7], "shield": [45, 22, 10], "tank": [95, 18, 13], "boss": [300, 15, 20]}
	for kind in expected:
		var enemy = script.new()
		root.add_child(enemy)
		enemy.configure(kind, 5)
		assert(enemy.kind == kind and enemy.hp == expected[kind][0] and enemy.speed == expected[kind][1] and enemy.radius == expected[kind][2])
		assert(enemy.armor == (kind in ["shield", "boss"]))
		enemy.free()
	var shield = script.new()
	root.add_child(shield)
	shield.configure("shield")
	assert(shield.take_hit(20, false).dealt == 5)
	assert(shield.take_hit(20, true).broken and shield.hp == 20 and not shield.armor)
	shield.died.connect(func(_reward: int): _deaths += 1)
	shield.take_hit(100, true)
	shield.take_hit(100, true)
	assert(_deaths == 1)
	shield.free()
	var tank = script.new()
	root.add_child(tank)
	tank.configure("tank")
	tank.attack.connect(func(_target: String, amount: float): _attacks.append(amount))
	tank.set("_charge_remaining", 0.0)
	tank.tick(0.01, Vector2(500, 0), Vector2(80, 0), false, false)
	assert(tank.windup_left == 0.55 and tank.position == Vector2.ZERO)
	tank.tick(0.6, Vector2(500, 0), Vector2(0, 80), false, false)
	assert(tank.dash_direction == Vector2.RIGHT and tank.dash_left == 0.4)
	tank.tick(0.4, Vector2(500, 0), Vector2(80, 0), false, false)
	assert(tank.position.is_equal_approx(Vector2(44, 0)) and _attacks == [14.0])
	tank.free()
	var boss = script.new()
	root.add_child(boss)
	boss.configure("boss")
	boss.summon_requested.connect(func(kind: String, at: Vector2):
		assert(kind == "runner" and at.distance_to(boss.position) == 30)
		_summons += 1)
	boss.tick(6.0, Vector2(500, 0), Vector2(500, 0), false, false)
	assert(_summons == 2)
	boss.tick(0.1, Vector2(500, 0), Vector2(500, 0), false, false)
	assert(_summons == 2)
	boss.take_hit(1000, true)
	boss.tick(10, Vector2.ZERO, Vector2.ZERO, true, false)
	assert(_summons == 2)
	boss.free()
	print("PASS enemy variants: registry, roles, armor, unique death, telegraph/locked dash/contact, boss summons")
	quit()
