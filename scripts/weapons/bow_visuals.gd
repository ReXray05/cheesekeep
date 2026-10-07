extends Node2D
class_name BowVisuals

var aim: Vector2 = Vector2.RIGHT
var bow: Node
var recoil: float = 0.0

func kick() -> void:
	recoil = 1.0

func _process(delta: float) -> void:
	recoil = maxf(0.0, recoil - delta * 9.0)
	queue_redraw()

func _draw() -> void:
	var data: Dictionary = bow.snapshot() if bow != null and is_instance_valid(bow) else {}
	var tint: Color = data.get("color", Color("edbe7a"))
	var charge: float = clampf(float(data.get("charge", 0.0)) / (bow.value("sweet_start",0.85) if bow != null else 0.85), 0.0, 1.0)
	var axis: Vector2 = aim.normalized()
	var side: Vector2 = axis.orthogonal()
	var back: Vector2 = axis * (-3.0 * recoil)
	var upper: Vector2 = side * 8.0 + back
	var lower: Vector2 = side * -8.0 + back
	var curve: Vector2 = axis * 4.0 + back
	var cord: Vector2 = axis * (-5.0 * charge) + back
	draw_polyline(PackedVector2Array([upper, side * 5.0 + curve, curve, side * -5.0 + curve, lower]), tint, 2.0)
	draw_polyline(PackedVector2Array([upper, cord, lower]), Color("fff1c5"), 1.0)
	if bool(data.get("charging", false)):
		draw_line(cord - axis * 3.0, curve + axis * 6.0, Color("fff1c5"), 1.0)
