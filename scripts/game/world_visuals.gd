extends Node2D

var tower_enabled: bool = false
var tower_hp: float = 300.0
var tower_max: float = 300.0
var target: Vector2 = Vector2.ZERO
var show_target: bool = false
var clock: float = 0.0

func _process(delta: float) -> void:
	clock += delta
	queue_redraw()

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
	if show_target:
		draw_arc(target,6.0+sin(clock*5),0,TAU,12,Color("f8d57d"),1)
		draw_line(target+Vector2(-9,0),target+Vector2(9,0),Color("f8d57d"))
	if tower_enabled:
		draw_set_transform(Vector2(0,12),0,Vector2(1,0.5))
		draw_circle(Vector2.ZERO,35,Color(0.01,0.02,0.025,0.6))
		draw_set_transform(Vector2.ZERO)
		draw_colored_polygon(PackedVector2Array([Vector2(-27,-18),Vector2(0,-5),Vector2(27,-18),Vector2(27,12),Vector2(0,25),Vector2(-27,12)]),Color("cb893a"))
		draw_colored_polygon(PackedVector2Array([Vector2(0,-5),Vector2(27,-18),Vector2(27,12),Vector2(0,25)]),Color("996132"))
		draw_colored_polygon(PackedVector2Array([Vector2(0,-33),Vector2(27,-18),Vector2(0,-5),Vector2(-27,-18)]),Color("ffd775"))
		for p in [Vector2(-12,-18),Vector2(7,-21),Vector2(0,-12),Vector2(-16,1),Vector2(-4,11),Vector2(17,0)]:
			draw_rect(Rect2(p,Vector2(6,4)),Color("af7334"))
		if tower_hp < tower_max*0.5:
			draw_line(Vector2(-22,-10),Vector2(-7,0),Color("593e31"),2)
			draw_line(Vector2(-7,0),Vector2(-12,15),Color("593e31"),2)
		draw_rect(Rect2(-27,30,54,3),Color("17212d"))
		draw_rect(Rect2(-27,30,54*maxf(0,tower_hp/tower_max),3),Color("ffd775"))
