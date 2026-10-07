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
	var body_scale: float = float(controller.get("radius")) / 9.0 if is_instance_valid(controller) else 1.0
	scale = Vector2(1.0 + squash * 0.22, 1.0 - squash * 0.2) * body_scale
	position.y = sin(_step) * 0.5 if walking else 0.0
	queue_redraw()

func _draw() -> void:
	var outline: Color = Color("302b42")
	var body: Color = Color("a5a1b8")
	var light: Color = Color("d6cadd")
	var pink: Color = Color("e887ae")
	var kind: String = str(controller.get("kind")) if is_instance_valid(controller) else "basic"
	if is_instance_valid(controller):
		var settings: Dictionary = controller.get("settings")
		body = Color(str(settings.get("color", "a88870")))
		light = body.lightened(0.3)
		if float(controller.get("windup_left")) > 0:
			var extent: float = float(settings.get("dash_speed", 110)) * float(settings.get("dash_duration", 0.4)) / maxf(0.1, float(controller.get("radius")) / 9.0)
			draw_arc(Vector2.ZERO, 11, 0, TAU, 16, Color("ff575b"), 2)
			draw_line(Vector2(12, 0), Vector2(extent, 0), Color("ff575b"), 2)
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
	# Silhouette markers remain visible independently of palette.
	draw_rect(Rect2(-5, -7, 3, 2), outline)
	draw_rect(Rect2(-5, 5, 3, 2), outline)
	if kind == "runner":
		draw_rect(Rect2(1, -5, 2, 10), Color("3bbca5"))
		draw_rect(Rect2(-2, 3, 4, 2), Color("3bbca5"))
	if kind == "tank":
		draw_rect(Rect2(-4, -4, 5, 8), Color("843d3a"))
		draw_rect(Rect2(-2, -3, 1, 6), Color("ebb576"))
	if kind == "boss":
		draw_rect(Rect2(-2, -5, 4, 10), Color("7b4c9d"))
		draw_rect(Rect2(-2, -5, 3, 3), Color("ffd775"))
		for y in [-5, -1, 3]: draw_rect(Rect2(-3, y, 3, 2), Color("ffd775"))
	if is_instance_valid(controller) and bool(controller.get("armor")):
		draw_rect(Rect2(3, -6, 3, 12), Color("ffd775"))
		draw_rect(Rect2(4, -5, 2, 10), Color("566b86"))
