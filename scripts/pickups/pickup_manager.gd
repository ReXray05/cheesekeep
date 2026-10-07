extends Node2D
class_name PickupManager

signal collected(kind: String, amount: int, at: Vector2)

const TowerGeometry = preload("res://scripts/systems/tower_geometry.gd")

# One record draws one pack regardless of its quantity. There are no child nodes,
# timers or expiration: wealth stays on the ground until collected or clear().
var records: Array[Dictionary] = []
var config: Dictionary = {}
var _clock: float = 0.0

func setup(cfg: Dictionary) -> void:
	config = cfg.duplicate(true)

func spawn_pickup(kind: String, amount: int, at: Vector2) -> void:
	if kind not in ["coin", "arrow"] or amount <= 0:
		return
	at = _accessible(at)
	var nearest: int = -1
	var nearest_distance: float = INF
	for index in records.size():
		if records[index].kind == kind:
			var distance: float = at.distance_squared_to(records[index].at)
			if distance < nearest_distance:
				nearest = index
				nearest_distance = distance
	var cap: int = maxi(2, int(config.get("pickup_records", 96)))
	var merge_radius: float = maxf(0.0, float(config.get("pickup_merge_radius", 8.0)))
	if nearest >= 0 and (nearest_distance <= merge_radius * merge_radius or records.size() >= cap):
		records[nearest].amount += amount
	else:
		# Reserve one slot for each allowed type so hitting the cap cannot lose it.
		if nearest < 0 and records.size() >= cap - 1:
			_compress_same_kind()
		records.append({"kind": kind, "amount": amount, "at": at, "phase": fmod(_clock + records.size() * 1.7, TAU)})
	queue_redraw()

func tick(delta: float, collector_pos: Vector2, can_collect: bool, collect_radius: float = 12.0, magnet_radius: float = 12.0) -> void:
	_clock = fmod(_clock + maxf(0.0, delta), TAU * 100.0)
	if can_collect:
		var radius: float = maxf(0.0, collect_radius)
		var attraction: float = maxf(radius, magnet_radius)
		# Remove before emitting. A callback may spawn another record or call tick.
		var rewards: Array[Dictionary] = []
		for index in range(records.size() - 1, -1, -1):
			var pack: Dictionary = records[index]
			var at: Vector2 = pack.at
			if at.distance_to(collector_pos) <= attraction:
				at = _move(at, at.move_toward(collector_pos, maxf(0.0, delta) * float(config.get("pickup_magnet_speed", 110.0))))
				pack.at = at
			if at.distance_to(collector_pos) <= radius:
				records.remove_at(index)
				rewards.append(pack)
		for pack in rewards:
			collected.emit(pack.kind, pack.amount, pack.at)
	queue_redraw()

func clear() -> void:
	records.clear()
	_clock = 0.0
	queue_redraw()

func _compress_same_kind() -> void:
	for first in records.size():
		for second in range(first + 1, records.size()):
			if records[first].kind == records[second].kind:
				records[first].amount += records[second].amount
				records.remove_at(second)
				return

func _accessible(at: Vector2) -> Vector2:
	return TowerGeometry.accessible_point(at, 3.0, bool(config.get("tower_enabled", true)))

func _move(at: Vector2, to: Vector2) -> Vector2:
	return TowerGeometry.constrain_motion(at, to, 3.0, bool(config.get("tower_enabled", true)))

func _draw() -> void:
	for pack in records:
		var at: Vector2 = pack.at
		var bob: float = roundf(sin(_clock * 3.0 + float(pack.phase)))
		draw_rect(Rect2(at + Vector2(-4, 1), Vector2(8, 2)), Color(0.02, 0.04, 0.05, 0.4))
		at = at.round() + Vector2(0, bob - 2)
		if pack.kind == "coin":
			draw_rect(Rect2(at + Vector2(-3, -4), Vector2(6, 8)), Color("49304a"))
			draw_rect(Rect2(at + Vector2(-4, -2), Vector2(8, 4)), Color("49304a"))
			draw_rect(Rect2(at + Vector2(-2, -3), Vector2(4, 6)), Color("f0b640"))
			draw_rect(Rect2(at + Vector2(-3, -1), Vector2(6, 2)), Color("f0b640"))
			draw_rect(Rect2(at + Vector2(-1, -2), Vector2(1, 4)), Color("ffe69a"))
		else:
			draw_line(at + Vector2(-5, 3), at + Vector2(4, -3), Color("34263e"), 3.0)
			draw_line(at + Vector2(-5, 3), at + Vector2(4, -3), Color("d9b47c"), 1.0)
			draw_colored_polygon(PackedVector2Array([at + Vector2(6,-5), at + Vector2(1,-4), at + Vector2(4,-1)]), Color("d4ede5"))
			draw_rect(Rect2(at + Vector2(-6, 1), Vector2(2, 3)), Color("9ecb9b"))
		if fmod(_clock + float(pack.phase), 2.5) < 0.16:
			draw_line(at + Vector2(4,-5), at + Vector2(4,-1), Color("fff1cb"))
			draw_line(at + Vector2(2,-3), at + Vector2(6,-3), Color("fff1cb"))

