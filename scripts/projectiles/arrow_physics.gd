extends Node2D
class_name ArrowPhysics

signal moved_segment(from: Vector2, to: Vector2)
signal finished(data: Dictionary)

const VisualScript = preload("res://scripts/projectiles/arrow_visuals.gd")
var shot_data: Dictionary = {}
var hit_ids: Dictionary = {}
var remaining_hits: int = 1
var hit_count: int = 0
var distance_left: float = 0.0
var life_left: float = 6.0
var velocity: Vector2 = Vector2.ZERO
var is_finished: bool = false
var range_limited: bool = true

func setup(origin: Vector2, data: Dictionary) -> void:
	position = origin
	shot_data = data.duplicate(true)
	hit_ids.clear()
	hit_count = 0
	is_finished = false
	remaining_hits = -1 if bool(data.get("spectral", false)) else maxi(1, int(data.get("pierce", 1)))
	range_limited = bool(data.get("range_limited", true))
	distance_left = maxf(0.0, float(data.get("range", 210.0)))
	life_left = maxf(0.0, float(data.get("lifetime", 6.0)))
	var direction: Vector2 = data.get("direction", Vector2.RIGHT)
	velocity = direction.normalized() * maxf(0.0, float(data.get("speed", 360.0)))
	rotation = direction.angle()
	if get_child_count() == 0:
		var visual: Node2D = VisualScript.new()
		add_child(visual)
	for child: Node in get_children():
		if child is ArrowVisuals:
			child.spectral = bool(data.get("spectral", false))
			child.half_width = float(data.get("half_width", 18.0))

func tick(delta: float) -> void:
	if is_finished or is_queued_for_deletion():
		return
	var elapsed: float = minf(maxf(0.0, delta), life_left)
	var travel: float = velocity.length() * elapsed
	if range_limited:
		travel = minf(travel, distance_left)
	var start: Vector2 = global_position
	global_position += velocity.normalized() * travel
	if range_limited:
		distance_left = maxf(0.0, distance_left - travel)
	life_left = maxf(0.0, life_left - elapsed)
	moved_segment.emit(start, global_position)
	# A collision callback may finish and relocate us to its contact point.
	if is_finished or is_queued_for_deletion():
		return
	if range_limited and distance_left <= 0.0:
		finish("range", global_position)
	elif life_left <= 0.0:
		finish("lifetime", global_position)

func register_hit(id: int) -> bool:
	if is_finished or is_queued_for_deletion() or hit_ids.has(id):
		return false
	hit_ids[id] = true
	hit_count += 1
	if remaining_hits < 0:
		return false
	remaining_hits -= 1
	return remaining_hits <= 0

func finish(reason: String, at: Vector2) -> void:
	if is_finished:
		return
	is_finished = true
	global_position = at
	finished.emit({"position": at, "reason": reason, "hit_count": hit_count,
		"recoverable": hit_count == 0 and reason in ["range", "boundary", "lifetime"]})
	queue_free()
