extends Node2D

var player: Node2D
var clock: float = 0.0

func _process(delta: float) -> void:
	clock += delta
	queue_redraw()

func _draw() -> void:
	if not is_instance_valid(player) or not player.alive:
		return
	draw_set_transform(Vector2.ZERO, 0, Vector2(1, 0.5))
	draw_circle(Vector2(0, 2), 9, Color(0.015,0.02,0.03,0.55))
	draw_set_transform(Vector2(0, -26 if player.mounted else 0))
	if player.invulnerable > 0.0 and int(clock * 15) % 2 == 0:
		return
	var bob: float = floor(sin(clock * 16) * 1.5) if player.moving else 0.0
	draw_rect(Rect2(-7,-11+bob,14,12), Color("101f29"))
	draw_rect(Rect2(-5,-10+bob,10,10), Color("53bb9c"))
	draw_rect(Rect2(-5,-7+bob,3,6), Color("2b796b"))
	draw_rect(Rect2(-4,-3,3,5), Color("af855b"))
	draw_rect(Rect2(2,-3,3,5), Color("af855b"))
	draw_rect(Rect2(-5,-19+bob,10,10), Color("eccc97"))
	draw_rect(Rect2(-6,-21+bob,12,5), Color("4bb78b"))
	draw_rect(Rect2(-3,-23+bob,8,3), Color("72d3a3"))
	draw_rect(Rect2(2,-17+bob,2,2), Color("182635"))
	draw_rect(Rect2(-7,-16+bob,2,3), Color("df6267"))
	draw_rect(Rect2(-9,-8+bob,3,7), Color("714c43"))
