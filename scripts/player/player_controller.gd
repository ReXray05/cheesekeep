extends Node2D

signal melee_started(data: Dictionary)
signal melee_finished
signal dash_started
signal dash_finished

const Geometry = preload("res://scripts/systems/tower_geometry.gd")
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
var actor_radius: float = 7.0
var movement_input: Vector2 = Vector2.ZERO
var direct_movement: bool = false
var dash_steering: Vector2 = Vector2.ZERO
var dash_left: float = 0.0
var dash_cooldown: float = 0.0
var dash_direction: Vector2 = Vector2.RIGHT
var melee_left: float = 0.0
var melee_cooldown: float = 0.0
var melee_direction: Vector2 = Vector2.RIGHT
var visual_clock: float = 0.0
var afterimages: Array[Dictionary] = []
var _queued_melee: bool = false
var _queued_direction: Vector2 = Vector2.RIGHT
var _dash_elapsed: float = 0.0
var _afterimage_clock: float = 0.0
var cfg: Dictionary = {}

func setup(config: Dictionary) -> void:
	cfg = config.duplicate(true)
	speed = float(cfg.get("speed", speed))
	charging_slow = float(cfg.get("charging_slow", charging_slow))
	max_hp = float(cfg.get("max_hp", max_hp))
	hp = minf(hp, max_hp)

func value(key: String, fallback: float) -> float:
	return float(cfg.get(key, fallback))

func _ready() -> void:
	var visual: Node2D = preload("res://scripts/player/player_visuals.gd").new()
	visual.player = self
	add_child(visual)

func set_movement_input(vector: Vector2, direct_mode: bool = false) -> void:
	direct_movement = direct_mode
	movement_input = vector.limit_length(1.0)
	if not movement_input.is_zero_approx():
		wants_tower = false

func set_dash_steering(heading: Vector2) -> void:
	dash_steering = heading.normalized()

func clear_queued_melee() -> void:
	_queued_melee = false

func _dismount() -> void:
	mounted = false
	position = Geometry.accessible_point(Vector2(0, 38), actor_radius, tower_enabled)
	destination = position

func go_to(point: Vector2) -> void:
	if not alive:
		return
	wants_tower = tower_enabled and Geometry.TOWER_CLICK_RECT.has_point(point)
	if mounted:
		if wants_tower:
			_dismount()
			wants_tower = false
			return
		_dismount()
	destination = Geometry.accessible_point(point, actor_radius, tower_enabled)
	if wants_tower:
		destination = Geometry.accessible_point(position.clamp(Geometry.TOWER_RECT.position, Geometry.TOWER_RECT.end), actor_radius, true)

func request_interact() -> bool:
	if not alive or not tower_enabled or dash_left > 0.0:
		return false
	if mounted:
		_dismount()
		return true
	if not Geometry.tower_contact(position, actor_radius + 12.0):
		return false
	mounted = true
	wants_tower = false
	moving = false
	position = Vector2.ZERO
	destination = position
	return true

func request_dash(heading: Vector2) -> bool:
	if not alive or dash_left > 0.0 or dash_cooldown > 0.0:
		return false
	if mounted:
		_dismount()
	wants_tower = false
	dash_steering = Vector2.ZERO
	dash_direction = heading.normalized() if not heading.is_zero_approx() else direction.normalized()
	dash_left = value("dash_duration", 0.18)
	dash_cooldown = value("dash_cooldown", 1.0)
	_dash_elapsed = 0.0
	invulnerable = maxf(invulnerable, value("dash_iframes", 0.08))
	dash_started.emit()
	return true

func request_melee(heading: Vector2, charging: bool) -> bool:
	if not alive or charging or melee_cooldown > 0.0 or melee_left > 0.0:
		return false
	if dash_left > 0.0:
		if _queued_melee:
			return false
		_queued_melee = true
		_queued_direction = heading
		return true
	melee_direction = heading.normalized() if not heading.is_zero_approx() else direction.normalized()
	melee_left = value("melee_duration", 0.18)
	melee_cooldown = value("melee_cooldown", 0.45)
	melee_started.emit({"origin": aim_anchor(), "direction": melee_direction, "range": value("melee_range", 32.0), "half_angle": deg_to_rad(value("melee_angle", 110.0) * 0.5), "damage": value("melee_damage", 12.0), "knockback": value("melee_knockback", 14.0)})
	return true

func clear_actions() -> void:
	_queued_melee = false
	dash_left = 0.0
	melee_left = 0.0
	movement_input = Vector2.ZERO
	destination = position
	wants_tower = false
	moving = false
	afterimages.clear()

func tick(delta: float, charging: bool) -> void:
	visual_clock += delta
	for ghost in afterimages:
		ghost["life"] -= delta
	afterimages = afterimages.filter(func(ghost: Dictionary) -> bool: return ghost["life"] > 0.0)
	invulnerable = maxf(0.0, invulnerable - delta)
	dash_cooldown = maxf(0.0, dash_cooldown - delta)
	melee_cooldown = maxf(0.0, melee_cooldown - delta)
	if melee_left > 0.0:
		melee_left = maxf(0.0, melee_left - delta)
		if melee_left == 0.0:
			melee_finished.emit()
	moving = false
	if not alive or mounted:
		return
	if dash_left > 0.0:
		_tick_dash(delta, charging)
		return
	if wants_tower and Geometry.tower_contact(position, actor_radius + 3.0):
		request_interact()
		return
	var step: float = speed * (charging_slow if charging else 1.0) * (value("melee_slow", 0.65) if melee_left > 0.0 else 1.0) * delta
	if direct_movement and movement_input.is_zero_approx() and not wants_tower:
		return
	var target: Vector2 = destination
	if tower_enabled and not direct_movement and not wants_tower:
		target = Geometry.navigation_target(position, destination, actor_radius)
	var next: Vector2 = position + movement_input * step if direct_movement and not wants_tower else position.move_toward(target, step)
	var safe: Vector2 = Geometry.slide_motion(position, next, actor_radius, tower_enabled)
	moving = position.distance_to(safe) > 0.01
	position = safe

func _tick_dash(delta: float, charging: bool) -> void:
	var duration: float = maxf(0.01, value("dash_duration", 0.18))
	var elapsed_next: float = minf(duration, _dash_elapsed + delta)
	var desired: Vector2 = dash_steering if not dash_steering.is_zero_approx() else (movement_input.normalized() if not movement_input.is_zero_approx() else dash_direction)
	var turn: float = clampf(dash_direction.angle_to(desired), -1.4 * delta, 1.4 * delta)
	dash_direction = dash_direction.rotated(turn)
	# Integral of a linearly decelerating speed profile, exactly distance over duration.
	var a: float = _dash_elapsed / duration
	var b: float = elapsed_next / duration
	var distance: float = value("dash_distance", 75.0) * ((1.5 * b - 0.5 * b * b) - (1.5 * a - 0.5 * a * a))
	var target: Vector2 = position + dash_direction * distance
	var next: Vector2 = Geometry.constrain_motion(position, target, actor_radius, tower_enabled)
	moving = position.distance_to(next) > 0.01
	_afterimage_clock -= delta
	if _afterimage_clock <= 0.0:
		_afterimage_clock = 0.03
		afterimages.append({"position": position, "life": 0.16})
		if afterimages.size() > 6:
			afterimages.pop_front()
	position = next
	_dash_elapsed = elapsed_next
	dash_left = maxf(0.0, duration - elapsed_next)
	if next.distance_to(target) > 0.1:
		dash_left = 0.0
	if dash_left == 0.0:
		destination = position
		dash_finished.emit()
		if _queued_melee:
			_queued_melee = false
			request_melee(_queued_direction, charging)

func aim_anchor() -> Vector2:
	return position + Vector2(0, -34 if mounted else -8)

func bow_origin() -> Vector2:
	return aim_anchor() + direction * 9.0

func hurt(amount: float) -> bool:
	if not alive or mounted or invulnerable > 0.0:
		return false
	hp = maxf(0.0, hp - amount)
	if hp <= 0.0:
		alive = false
		clear_actions()
	return true

func revive() -> void:
	alive = true
	mounted = false
	hp = max_hp
	position = Geometry.accessible_point(Vector2(0, 45), actor_radius, tower_enabled)
	clear_actions()
	dash_cooldown = 0.0
	melee_cooldown = 0.0
	invulnerable = 1.0

