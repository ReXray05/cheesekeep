extends Node2D

var destination: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.RIGHT
var speed: float = 100.0
var hp: float = 100.0
var max_hp: float = 100.0
var mounted: bool = false
var alive: bool = true
var wants_tower: bool = false
var tower_enabled: bool = false
var moving: bool = false
var charging_slow: float = 0.65
var invulnerable: float = 0.0

func _ready() -> void:
	var visual: Node2D = preload("res://scripts/player/player_visuals.gd").new()
	visual.player = self
	add_child(visual)

func go_to(point: Vector2) -> void:
	if not alive:
		return
	wants_tower = tower_enabled and point.distance_to(Vector2.ZERO) < 24.0
	if wants_tower:
		destination = Vector2.ZERO
	else:
		if mounted:
			position = Vector2(0, 38)
		mounted = false
		destination = point.limit_length(320.0)

func tick(delta: float, charging: bool) -> void:
	invulnerable = maxf(0.0, invulnerable - delta)
	moving = false
	if not alive or mounted:
		return
	if wants_tower and position.length() < 34.0:
		mounted = true
		position = Vector2.ZERO
		destination = position
		return
	var step: float = speed * (charging_slow if charging else 1.0) * delta
	moving = position.distance_to(destination) > 2.0
	var next: Vector2 = position.move_toward(destination, step)
	if tower_enabled and not wants_tower and next.length() < 30.0:
		var tangent: Vector2 = Vector2(-position.y, position.x).normalized()
		if tangent.dot(destination - position) < 0.0:
			tangent = -tangent
		next = (position + tangent * step).normalized() * 31.0
	position = next.limit_length(320.0)

func bow_origin() -> Vector2:
	return position + Vector2(0, -8 if not mounted else -34) + direction * 9.0

func hurt(amount: float) -> bool:
	if not alive or mounted or invulnerable > 0.0:
		return false
	hp = maxf(0.0, hp - amount)
	if hp <= 0.0:
		alive = false
		moving = false
	return true

func revive() -> void:
	alive = true
	mounted = false
	wants_tower = false
	hp = max_hp
	position = Vector2(0, 45)
	destination = position
	invulnerable = 1.0
