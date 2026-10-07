extends Node2D
class_name AimIndicator

var bow: Node
var direction: Vector2 = Vector2.RIGHT
var age: float = 0.0

func _process(delta: float) -> void:
	age += delta
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
	if bool(data.get("spectral", false)):
		var pulse: float = 0.12 + 0.04 * sin(age * 14.0)
		draw_colored_polygon(PackedVector2Array([-sideways, base - sideways, base + sideways, sideways]), Color(tint, pulse))
		draw_line(-sideways, base - sideways, Color(tint, 0.7), 1.0)
		draw_line(sideways, base + sideways, Color(tint, 0.7), 1.0)
		draw_line(base - sideways, base + sideways, Color(tint, 0.7), 1.0)
		for i: int in range(3):
			var center: Vector2 = aim * (extent * (float(i) + 0.5) / 3.0)
			draw_polyline(PackedVector2Array([center - aim * 6.0 - sideways * 0.35, center, center - aim * 6.0 + sideways * 0.35]), Color(tint, 0.6), 1.0)
		return
	var points: PackedVector2Array = PackedVector2Array([Vector2.ZERO, base - sideways, base + sideways])
	draw_colored_polygon(points, Color(tint, 0.12))
	draw_polyline(PackedVector2Array([base - sideways, Vector2.ZERO, base + sideways]), Color(tint, 0.65), 1.0)
	draw_line(base - sideways, base + sideways, Color(tint, 0.9), 1.0)
	draw_line(Vector2.ZERO, base, Color(tint, 0.22), 1.0)
