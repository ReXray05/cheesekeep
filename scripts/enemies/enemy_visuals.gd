extends Node2D
class_name EnemyVisuals

var controller: Node2D
var _flash_remaining: float = 0.0
var _squash_remaining: float = 0.0
var _critical: bool = false
var _blocked: bool = false
var _step: float = 0.0

func hit_feedback(critical: bool, blocked: bool) -> void:
	_flash_remaining = 0.12
	_squash_remaining = 0.18
	_critical = critical
	_blocked = blocked
	queue_redraw()

func _process(delta: float) -> void:
	_flash_remaining = maxf(0.0, _flash_remaining - delta)
	_squash_remaining = maxf(0.0, _squash_remaining - delta)
	var walking: bool = false
	if is_instance_valid(controller):
		var direction: Vector2 = controller.get("move_direction")
		walking = direction.length_squared() > 0.01
		if walking:
			rotation = direction.angle()
			_step += delta * 12.0
	var squash: float = _squash_remaining / 0.18
	scale = Vector2(1.0 + squash * 0.22, 1.0 - squash * 0.2)
	position.y = sin(_step) * 0.5 if walking else 0.0
	queue_redraw()

func _draw() -> void:
	var outline: Color = Color("302b42")
	var body: Color = Color("a5a1b8")
	var light: Color = Color("d6cadd")
	var pink: Color = Color("e887ae")
	if _flash_remaining > 0.0:
		body = Color("ffe8a5") if _critical else Color.WHITE
		if _blocked:
			body = Color("84b2d6")
	# Pixel blocks remain legible at the small logical field resolution.
	draw_rect(Rect2(-8, -6, 15, 12), Color(0.05, 0.04, 0.08, 0.28))
	draw_line(Vector2(-7, 0), Vector2(-13, 2), pink, 2.0)
	draw_line(Vector2(-13, 2), Vector2(-16, -1), pink, 2.0)
	draw_rect(Rect2(-7, -6, 13, 12), outline)
	draw_rect(Rect2(-8, -3, 15, 6), outline)
	draw_rect(Rect2(-5, -5, 10, 10), body)
	draw_rect(Rect2(-7, -2, 13, 4), body)
	draw_rect(Rect2(-3, -4, 5, 3), light)
	draw_rect(Rect2(2, -7, 4, 4), outline)
	draw_rect(Rect2(2, 3, 4, 4), outline)
	draw_rect(Rect2(3, -6, 2, 2), pink)
	draw_rect(Rect2(3, 4, 2, 2), pink)
	draw_rect(Rect2(5, -3, 5, 6), outline)
	draw_rect(Rect2(5, -2, 4, 4), body)
	draw_rect(Rect2(9, -1, 2, 2), pink)
	draw_rect(Rect2(6, -3, 2, 2), Color("151421"))
	draw_rect(Rect2(6, 1, 2, 2), Color("151421"))
	if is_instance_valid(controller) and bool(controller.get("armor")):
		draw_rect(Rect2(-3, -5, 4, 10), Color("647998"))
