extends SceneTree

const Enemy = preload("res://scripts/enemies/enemy_controller.gd")
const Economy = preload("res://scripts/economy/economy_manager.gd")
const Pickups = preload("res://scripts/pickups/pickup_manager.gd")
const Geometry = preload("res://scripts/systems/tower_geometry.gd")
var rewards: int = 0
var resources: Dictionary = {"coin": 0, "arrow": 0}

func _initialize() -> void:
	var economy = Economy.new()
	economy.setup({"start_coins": 0, "start_ammo": 0})
	assert(not economy.collect("wrong", 100) and not economy.collect("coin", 0))
	var manager = Pickups.new()
	root.add_child(manager)
	manager.setup({"pickup_records": 4, "pickup_merge_radius": 0.0})
	manager.collected.connect(func(kind: String, amount: int, _at: Vector2):
		resources[kind] += amount
		assert(economy.collect(kind, amount)))
	for index in 100:
		manager.spawn_pickup("coin", index + 1, Vector2(60 + index, 60))
		manager.spawn_pickup("arrow", 2, Vector2(-60 - index, 60))
	assert(manager.records.size() <= 4)
	var coins: int = 0
	var arrows: int = 0
	for pack in manager.records:
		if pack.kind == "coin": coins += int(pack.amount)
		else: arrows += int(pack.amount)
	assert(coins == 5050 and arrows == 200)
	manager.tick(20.0, Vector2.ZERO, false, 1000.0, 1000.0)
	assert(economy.coins == 0 and economy.ammo == 0)
	manager.tick(0.0, Vector2.ZERO, true, 1000.0, 1000.0)
	manager.tick(0.0, Vector2.ZERO, true, 1000.0, 1000.0)
	assert(economy.coins == 5050 and economy.ammo == 200 and manager.records.is_empty())
	manager.spawn_pickup("arrow", 1, Vector2.ZERO)
	assert(not Geometry.TOWER_RECT.grow(3).has_point(manager.records[0].at))
	manager.clear()
	manager.spawn_pickup("coin", 1, Vector2(-60, 0))
	manager.tick(1.0, Vector2(60, 0), true, 12.0, 150.0)
	assert(manager.records.size() == 1 and not Geometry.TOWER_RECT.grow(3).has_point(manager.records[0].at))
	manager.clear()
	economy.coins = 0
	economy.ammo = 0
	var shield = Enemy.new()
	root.add_child(shield)
	shield.configure("boss")
	shield.died.connect(func(reward: int):
		assert(shield.death_source == "melee")
		rewards += 1
		manager.spawn_pickup("coin", reward, Vector2(70, 70))
		manager.spawn_pickup("arrow", 2, Vector2(70, 70)))
	assert(shield.take_hit(12, false, "spectral").dealt == 3.0 and shield.armor)
	for _hit in 100:
		shield.take_hit(12, false, "melee")
	assert(shield.dead and shield.armor and rewards == 1)
	shield.take_hit(1000, true)
	assert(rewards == 1 and economy.ammo == 0 and economy.coins == 0)
	manager.tick(0.0, Vector2(70,70), true, 12, 12)
	assert(economy.coins == 35 and economy.ammo == 2 and economy.consume_arrow())
	shield.free()
	# Every approach direction eventually reaches the geometric contact and attacks.
	for side in 16:
		var rat = Enemy.new()
		root.add_child(rat)
		rat.configure("basic")
		rat.position = Vector2.from_angle(TAU * side / 16.0) * 120.0
		for _step in 200: rat.tick(0.05, Vector2(500,0), Vector2.ZERO, false, true)
		assert(Geometry.tower_contact(rat.position, rat.radius))
		assert(not Geometry.TOWER_RECT.grow(rat.radius).has_point(rat.position))
		rat.apply_knockback(-rat.position, 200.0)
		assert(not Geometry.TOWER_RECT.grow(rat.radius).has_point(rat.position))
		rat.free()
	var chase = Enemy.new()
	root.add_child(chase)
	chase.configure("runner")
	chase.settings.chase_radius = 1000
	chase.position = Vector2(-70,0)
	for _step in 200: chase.tick(0.05, Vector2(70,0), Vector2.ZERO, true, false)
	assert(chase.position.distance_to(Vector2(70,0)) <= chase.radius + 5.1)
	chase.free()
	var tank = Enemy.new()
	root.add_child(tank)
	tank.configure("tank")
	tank.position = Vector2(-80,0)
	tank.dash_direction = Vector2.RIGHT
	tank.dash_left = 1.0
	tank.tick(1.0, Vector2(80,0), Vector2.ZERO, false, true)
	assert(not Geometry.TOWER_RECT.grow(tank.radius).has_point(tank.position) and tank.dash_left == 0)
	tank.free()
	manager.free()
	print("PASS V2 enemy/economy: protected zero-resource melee recovery, unique death source, exact cap sums, mounted gate, no expiry, reachable miss, tower magnet block, 360 contact, opposite chase detour, swept charge/knockback")
	quit()
