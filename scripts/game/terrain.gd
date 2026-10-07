extends Node2D

func _draw() -> void:
	draw_rect(Rect2(-600,-600,1200,1200), Color("132f33"))
	for x in range(-15, 16):
		for y in range(-15, 16):
			var center: Vector2 = Vector2((x-y)*24,(x+y)*12)
			var light: bool = (x+y)%2 == 0
			var color: Color = Color("21443c") if light else Color("244940")
			if center.length() > 325.0:
				color = Color("172e32")
			draw_colored_polygon(PackedVector2Array([center+Vector2(0,-12),center+Vector2(24,0),center+Vector2(0,12),center+Vector2(-24,0)]),color)
			if (x*7+y*13)%11 == 0 and center.length() < 310.0:
				draw_rect(Rect2(center+Vector2(5,-2),Vector2(2,2)),Color("53734b"))
	for i in range(48):
		var a: float = i * TAU / 48.0
		var p: Vector2 = Vector2(cos(a),sin(a)) * 328.0
		draw_rect(Rect2(p,Vector2(5,3)),Color("577d55"))
