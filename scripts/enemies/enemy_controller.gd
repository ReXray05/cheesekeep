extends Node2D
class_name EnemyController

signal attack(target: String, amount: float)
signal died(reward: int)
signal summon_requested(kind: String, at: Vector2)

const VisualsScript = preload("res://scripts/enemies/enemy_visuals.gd")
const Geometry = preload("res://scripts/systems/tower_geometry.gd")

var hp: float = 30.0
var max_hp: float = 30.0
var kind: String = "basic"
var armor: bool = false
var dead: bool = false
var death_source: String = ""
var tower_enabled: bool = true
var _tower_pos: Vector2 = Vector2.ZERO
var radius: float = 9.0
var speed: float = 29.0
var player_damage: float = 10.0
var tower_damage: float = 5.0
var attack_cooldown: float = 0.9
var reward: int = 3
var move_direction: Vector2 = Vector2.ZERO
var _attack_remaining: float = 0.0
var _visuals: Node2D
static var _registry: Dictionary = {}
var settings: Dictionary = {}
var windup_left: float = 0.0
var dash_left: float = 0.0
var dash_direction: Vector2 = Vector2.RIGHT
var _charge_remaining: float = 4.0
var _summon_remaining: float = 6.0
var _dash_hit: bool = false

func _ready() -> void:
	_visuals = get_node_or_null("EnemyVisuals") as Node2D
	if _visuals == null:
		_visuals = VisualsScript.new()
		_visuals.name = "EnemyVisuals"
		add_child(_visuals)
	_visuals.set("controller", self)

func configure(enemy_kind: String, _wave: int = 1) -> void:
	if _registry.is_empty():
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/enemies.json"))
		if parsed is Dictionary: _registry = parsed
	kind = enemy_kind if _registry.has(enemy_kind) else "basic"
	settings = Dictionary(_registry.get("basic", {})).duplicate(true)
	settings.merge(_registry.get(kind, {}), true)
	max_hp = float(settings.get("hp", 30))
	hp = max_hp
	armor = bool(settings.get("armor", false))
	dead = false
	death_source = ""
	radius = float(settings.get("radius", 9))
	speed = float(settings.get("speed", 29))
	player_damage = float(settings.get("player_damage", 10))
	tower_damage = float(settings.get("tower_damage", 5))
	attack_cooldown = float(settings.get("attack_cooldown", 0.9))
	reward = int(settings.get("reward", 3))
	windup_left = 0.0
	dash_left = 0.0
	_charge_remaining = float(settings.get("charge_interval", 4))
	_summon_remaining = float(settings.get("summon_interval", 6))
	_dash_hit = false
	_attack_remaining = 0.0
	move_direction = Vector2.ZERO
	visible = true

func tick(delta: float, player_pos: Vector2, tower_pos: Vector2, player_alive: bool, mounted: bool) -> void:
	if dead:
		return
	_tower_pos = tower_pos
	global_position = Geometry.accessible_point(global_position - tower_pos, radius, tower_enabled) + tower_pos
	_attack_remaining = maxf(0.0, _attack_remaining - delta)
	if settings.has("summon_interval"):
		_summon_remaining -= delta
		if _summon_remaining <= 0.0:
			_summon_remaining = float(settings["summon_interval"])
			for side in [-1, 1]:
				var summon_at: Vector2 = global_position + Vector2(0, side * (radius + 10))
				summon_requested.emit("runner", Geometry.accessible_point(summon_at - tower_pos, 7.0, tower_enabled) + tower_pos)
	var target: String = "tower"
	var destination: Vector2 = tower_pos
	var stop_distance: float = radius + 5.0
	var amount: float = tower_damage
	if player_alive and not mounted and global_position.distance_to(player_pos) < float(settings.get("chase_radius", 80)):
		target = "player"
		destination = player_pos
		stop_distance = radius + 5.0
		amount = player_damage
	var offset: Vector2 = destination - global_position
	var distance: float = offset.length()
	if windup_left > 0.0:
		move_direction = dash_direction
		windup_left = maxf(0.0, windup_left - delta)
		if windup_left == 0.0: dash_left = float(settings.get("dash_duration", 0.4))
		return
	if dash_left > 0.0:
		var start: Vector2 = global_position
		var intended: Vector2 = global_position + dash_direction * float(settings.get("dash_speed", 110)) * minf(delta, dash_left)
		global_position = _constrain(global_position, intended)
		dash_left = maxf(0.0, dash_left - delta)
		if global_position.distance_to(intended) > 0.1:
			dash_left = 0.0
		move_direction = dash_direction
		if not _dash_hit:
			var contact: Vector2 = Geometry2D.get_closest_point_to_segment(tower_pos, start, global_position)
			if tower_enabled and Geometry.tower_contact(global_position - tower_pos, radius):
				_dash_hit = true
				attack.emit("tower", float(settings.get("dash_tower", tower_damage)))
			elif player_alive and not mounted:
				contact = Geometry2D.get_closest_point_to_segment(player_pos, start, global_position)
				if contact.distance_to(player_pos) < radius + 5.0:
					_dash_hit = true
					attack.emit("player", float(settings.get("dash_player", player_damage)))
		if dash_left == 0.0: _attack_remaining = attack_cooldown
		return
	_charge_remaining = maxf(0, _charge_remaining - delta)
	if settings.has("windup") and _charge_remaining <= 0.0 and distance >= 40.0 and distance <= 110.0:
		windup_left = float(settings["windup"])
		dash_direction = offset.normalized()
		move_direction = dash_direction
		_dash_hit = false
		_charge_remaining = float(settings.get("charge_interval", 4))
		return
	var touching: bool = Geometry.tower_contact(global_position - tower_pos, radius) if target == "tower" and tower_enabled else distance < stop_distance
	var next_target: Vector2 = destination
	if target == "player" and tower_enabled:
		next_target = _navigation_target(destination)
	move_direction = global_position.direction_to(next_target)
	if not touching:
		# Never overshoot the contact boundary on a long frame.
		var travel: float = speed * maxf(0.0, delta)
		if target == "player" and next_target.is_equal_approx(destination):
			travel = minf(travel, maxf(0.0, distance - stop_distance + 0.01))
		else:
			travel = minf(travel, global_position.distance_to(next_target))
		global_position = _constrain(global_position, global_position + move_direction * travel)
		return
	move_direction = Vector2.ZERO
	if _attack_remaining <= 0.0:
		_attack_remaining = attack_cooldown
		attack.emit(target, amount)

func take_hit(damage: float, critical: bool, source: String = "arrow") -> Dictionary:
	var result: Dictionary = {"killed": false, "blocked": false, "dealt": 0.0, "broken": false}
	if dead or damage <= 0.0:
		return result
	var dealt: float = damage
	if armor:
		if critical:
			armor = false
			result["broken"] = true
		else:
			dealt *= 0.25
			result["blocked"] = true
	result["dealt"] = minf(hp, dealt)
	hp = clampf(hp - dealt, 0.0, max_hp)
	if is_instance_valid(_visuals):
		_visuals.call("hit_feedback", critical, bool(result["blocked"]))
	if hp <= 0.0:
		dead = true
		death_source = source
		result["killed"] = true
		move_direction = Vector2.ZERO
		visible = false
		died.emit(reward)
	return result

func apply_knockback(direction: Vector2, amount: float) -> void:
	if dead or amount <= 0.0 or direction.length_squared() < 0.000001:
		return
	global_position = _constrain(global_position, global_position + direction.normalized() * amount)

func _constrain(from: Vector2, to: Vector2) -> Vector2:
	return Geometry.constrain_motion(from - _tower_pos, to - _tower_pos, radius, tower_enabled) + _tower_pos

func _visible_path(from: Vector2, to: Vector2) -> bool:
	return _constrain(from, to).distance_to(to) < 0.1

func _navigation_target(destination: Vector2) -> Vector2:
	# Visibility graph around the shared expanded rectangle; shortest complete
	# route chooses a stable side even when the player is exactly opposite.
	if _visible_path(global_position, destination):
		return destination
	var rect: Rect2 = Geometry.TOWER_RECT.grow(radius + 2.0)
	var points: Array[Vector2] = [global_position, destination,
		rect.position + _tower_pos, Vector2(rect.end.x, rect.position.y) + _tower_pos,
		rect.end + _tower_pos, Vector2(rect.position.x, rect.end.y) + _tower_pos]
	var costs: Array[float] = [0.0, INF, INF, INF, INF, INF]
	var parents: Array[int] = [-1, -1, -1, -1, -1, -1]
	var visited: Array[bool] = [false, false, false, false, false, false]
	for _iteration in points.size():
		var chosen: int = -1
		for index in points.size():
			if not visited[index] and (chosen < 0 or costs[index] < costs[chosen]):
				chosen = index
		if chosen < 0 or is_inf(costs[chosen]):
			break
		visited[chosen] = true
		if chosen == 1:
			var first: int = 1
			while parents[first] > 0:
				first = parents[first]
			return points[first]
		for index in points.size():
			if visited[index] or not _visible_path(points[chosen], points[index]):
				continue
			var cost: float = costs[chosen] + points[chosen].distance_to(points[index])
			if cost < costs[index]:
				costs[index] = cost
				parents[index] = chosen
	return global_position
