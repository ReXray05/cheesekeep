extends Node2D
class_name AimIndicator

var bow: Node
var direction: Vector2 = Vector2.RIGHT

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if bow == null or not is_instance_valid(bow):
		return
	var data: Dictionary = bow.snapshot()
	if not bool(data["charging"]):
		return
	var aim: Vector2 = direction.normalized()
	var extent: float = float(data["range"])
	var width: float = float(data["half_width"])
	var tint: Color = data["color"]
	var base: Vector2 = aim * extent
	var sideways: Vector2 = aim.orthogonal() * width
	var points: PackedVector2Array = PackedVector2Array([Vector2.ZERO, base - sideways, base + sideways])
	draw_colored_polygon(points, Color(tint, 0.12))
	draw_polyline(PackedVector2Array([base - sideways, Vector2.ZERO, base + sideways]), Color(tint, 0.65), 1.0)
	draw_line(base - sideways, base + sideways, Color(tint, 0.9), 1.0)
	draw_line(Vector2.ZERO, base, Color(tint, 0.22), 1.0)
