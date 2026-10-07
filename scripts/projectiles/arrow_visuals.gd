extends Node2D
class_name ArrowVisuals

var spectral: bool = false
var half_width: float = 18.0
var age: float = 0.0

func _process(delta: float) -> void:
	age += delta
	queue_redraw()

func _draw() -> void:
	if spectral:
		var pulse: float = 0.65 + 0.15 * sin(age * 18.0)
		var w: float = maxf(1.0, half_width)
		# One bounded drawing node: its silhouette matches the swept hit corridor.
		draw_colored_polygon(PackedVector2Array([Vector2(20, 0), Vector2(2, -w), Vector2(-32, -w * 0.6), Vector2(-46, 0), Vector2(-32, w * 0.6), Vector2(2, w)]), Color(0.65, 0.3, 1.0, 0.18 * pulse))
		draw_line(Vector2(-44, 0), Vector2(14, 0), Color(0.85, 0.65, 1.0, pulse), 4.0)
		draw_polyline(PackedVector2Array([Vector2(-7, -w), Vector2(20, 0), Vector2(-7, w)]), Color("efcfff"), 2.0)
		for i: int in range(3):
			var x: float = -18.0 - float(i) * 10.0
			var y: float = sin(age * 14.0 + float(i)) * w * 0.5
			draw_line(Vector2(x - 8, y), Vector2(x, y), Color(0.7, 0.5, 1.0, 0.45), 2.0)
		return
	draw_line(Vector2(-13, 0), Vector2(-6, 0), Color(0.9, 0.75, 0.4, 0.18), 2.0)
	draw_line(Vector2(-6, 0), Vector2(4, 0), Color("fbe8ac"), 1.0)
	draw_line(Vector2(-5, -2), Vector2(-3, 0), Color("c77353"), 1.0)
	draw_line(Vector2(-5, 2), Vector2(-3, 0), Color("c77353"), 1.0)
	draw_colored_polygon(PackedVector2Array([Vector2(7, 0), Vector2(3, -2), Vector2(3, 2)]), Color("e8f4ff"))
