extends Node2D

var targets: Array[Vector2] = []
var cursor: Vector2 = Vector2(180,180)
var show_cursor: bool = false

func _draw() -> void:
	var center: Vector2 = Vector2(180,180)
	for target: Vector2 in targets:
		if Rect2(10,10,340,340).has_point(target):
			continue
		var vector: Vector2 = target - center
		var extent: float = maxf(absf(vector.x),absf(vector.y))
		var tip: Vector2 = center + vector * (165.0 / maxf(1,extent))
		var direction: Vector2 = vector.normalized()
		var sideways: Vector2 = direction.orthogonal()
		draw_colored_polygon(PackedVector2Array([tip+direction*3,tip-direction*4+sideways*3,tip-direction*4-sideways*3]),Color("edac70"))
	if show_cursor:
		for signum in [-1,1]:
			draw_line(cursor+Vector2(signum*4,0),cursor+Vector2(signum*8,0),Color("f8e8b3"))
			draw_line(cursor+Vector2(0,signum*4),cursor+Vector2(0,signum*8),Color("f8e8b3"))
