extends Node2D
class_name EnemyController

signal attack(target: String, amount: float)
signal died(reward: int)

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

func _ready() -> void:
	_visuals = get_node_or_null("EnemyVisuals") as Node2D
	if _visuals == null:
		_visuals = VisualsScript.new()
		_visuals.name = "EnemyVisuals"
		add_child(_visuals)
	_visuals.set("controller", self)

func configure(_enemy_kind: String, _wave: int = 1) -> void:
	# The core gate uses only the basic rat; variants are added later.
	kind = "basic"
	max_hp = 30.0
	hp = max_hp
	armor = false
	dead = false
	radius = 9.0
	speed = 29.0
	player_damage = 10.0
	tower_damage = 5.0
	attack_cooldown = 0.9
	reward = 3
	_attack_remaining = 0.0
	move_direction = Vector2.ZERO
	visible = true

func tick(delta: float, player_pos: Vector2, tower_pos: Vector2, player_alive: bool, mounted: bool) -> void:
	if dead:
		return
	_attack_remaining = maxf(0.0, _attack_remaining - delta)
	var target: String = "tower"
	var destination: Vector2 = tower_pos
	var stop_distance: float = 38.0
	var amount: float = tower_damage
	if player_alive and not mounted and global_position.distance_to(player_pos) < 80.0:
		target = "player"
		destination = player_pos
		stop_distance = 14.0
		amount = player_damage
	var offset: Vector2 = destination - global_position
	var distance: float = offset.length()
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
