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
	for i in range(64):
		var angle: float = i * TAU / 64.0
		var p: Vector2 = Vector2.from_angle(angle) * (354 + sin(i*7)*18)
		draw_rect(Rect2(p+Vector2(-2,-6),Vector2(4,16)),Color("4e4934"))
		draw_rect(Rect2(p+Vector2(-12,-17),Vector2(24,12)),Color("14352f"))
		draw_rect(Rect2(p+Vector2(-9,-25),Vector2(18,13)),Color("1d4b38"))
		draw_rect(Rect2(p+Vector2(-5,-32),Vector2(10,10)),Color("2e6246"))
		draw_rect(Rect2(p+Vector2(-9,-19),Vector2(6,3)),Color("3b7150"))
