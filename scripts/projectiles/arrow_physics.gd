extends Node2D
class_name ArrowPhysics

signal moved_segment(from: Vector2, to: Vector2)

const VisualScript = preload("res://scripts/projectiles/arrow_visuals.gd")
var shot_data: Dictionary = {}
var hit_ids: Dictionary = {}
var remaining_hits: int = 1
var distance_left: float = 0.0
var life_left: float = 4.0
var velocity: Vector2 = Vector2.ZERO

func setup(origin: Vector2, data: Dictionary) -> void:
	position = origin
	shot_data = data.duplicate(true)
	hit_ids.clear()
	remaining_hits = int(data.get("pierce", 1))
	distance_left = float(data.get("range", 210.0))
	life_left = 4.0
	var direction: Vector2 = data.get("direction", Vector2.RIGHT)
	velocity = direction.normalized() * float(data.get("speed", 360.0))
	rotation = direction.angle()
	if get_child_count() == 0:
		var visual: Node2D = Node2D.new()
		visual.set_script(VisualScript)
		add_child(visual)

func tick(delta: float) -> void:
	if is_queued_for_deletion():
		return
	life_left -= delta
	var travel: float = minf(velocity.length() * delta, distance_left)
	var start: Vector2 = global_position
	global_position += velocity.normalized() * travel
	distance_left -= travel
	moved_segment.emit(start, global_position)
	if distance_left <= 0.0 or life_left <= 0.0:
		queue_free()

func register_hit(id: int) -> bool:
	if hit_ids.has(id):
		return false
	hit_ids[id] = true
	remaining_hits -= 1
	return remaining_hits <= 0
