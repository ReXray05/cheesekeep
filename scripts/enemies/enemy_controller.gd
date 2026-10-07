extends Node2D
class_name EnemyController

signal attack(target: String, amount: float)
signal died(reward: int)
signal summon_requested(kind: String, at: Vector2)

const VisualsScript = preload("res://scripts/enemies/enemy_visuals.gd")

var hp: float = 30.0
var max_hp: float = 30.0
var kind: String = "basic"
var armor: bool = false
var dead: bool = false
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
	_attack_remaining = maxf(0.0, _attack_remaining - delta)
	if settings.has("summon_interval"):
		_summon_remaining -= delta
		if _summon_remaining <= 0.0:
			_summon_remaining = float(settings["summon_interval"])
			for side in [-1, 1]: summon_requested.emit("runner", global_position + Vector2(0, side * (radius + 10)))
	var target: String = "tower"
	var destination: Vector2 = tower_pos
	var stop_distance: float = radius + 29.0
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
		global_position += dash_direction * float(settings.get("dash_speed", 110)) * minf(delta, dash_left)
		dash_left = maxf(0.0, dash_left - delta)
		move_direction = dash_direction
		if not _dash_hit:
			var contact: Vector2 = Geometry2D.get_closest_point_to_segment(tower_pos, start, global_position)
			if contact.distance_to(tower_pos) < radius + 29.0:
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
	move_direction = offset.normalized() if distance > 0.001 else Vector2.ZERO
	if distance >= stop_distance:
		# Never overshoot the contact boundary on a long frame.
		global_position += move_direction * minf(speed * delta, maxf(0.0, distance - stop_distance + 0.01))
		return
	move_direction = Vector2.ZERO
	if _attack_remaining <= 0.0:
		_attack_remaining = attack_cooldown
		attack.emit(target, amount)

func take_hit(damage: float, critical: bool) -> Dictionary:
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
		result["killed"] = true
		move_direction = Vector2.ZERO
		visible = false
		died.emit(reward)
	return result
