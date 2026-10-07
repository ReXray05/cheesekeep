extends Node2D
class_name ArrowVisuals

func _draw() -> void:
	draw_line(Vector2(-13, 0), Vector2(-6, 0), Color(0.9, 0.75, 0.4, 0.18), 2.0)
	draw_line(Vector2(-6, 0), Vector2(4, 0), Color("fbe8ac"), 1.0)
	draw_line(Vector2(-5, -2), Vector2(-3, 0), Color("c77353"), 1.0)
	draw_line(Vector2(-5, 2), Vector2(-3, 0), Color("c77353"), 1.0)
	draw_colored_polygon(PackedVector2Array([Vector2(7, 0), Vector2(3, -2), Vector2(3, 2)]), Color("e8f4ff"))
