extends Node2D
class_name BowVisuals

var aim: Vector2 = Vector2.RIGHT
var bow: Node
var recoil: float = 0.0
var melee_left: float = 0.0
var melee_direction: Vector2 = Vector2.RIGHT
var melee_duration: float = 0.18
var flash_left: float = 0.0
var flash_color: Color = Color.WHITE
var age: float = 0.0

func _ready() -> void:
	if bow != null:
		bow.snapped.connect(_broken)
		bow.recovered.connect(_recovered)

func _broken() -> void:
	flash_left = 0.24
	flash_color = Color("ff535b")

func _recovered() -> void:
	flash_left = 0.24
	flash_color = Color("91ed70")

func play_melee(data: Dictionary) -> void:
	melee_direction = data.get("direction", aim)
	melee_duration = maxf(0.01, float(data.get("duration", 0.18)))
	melee_left = melee_duration

func kick() -> void:
	recoil = 1.0

func _process(delta: float) -> void:
	age += delta
	recoil = maxf(0.0, recoil - delta * 9.0)
	melee_left = maxf(0.0, melee_left - delta)
	flash_left = maxf(0.0, flash_left - delta)
	queue_redraw()

func _draw() -> void:
	var data: Dictionary = bow.snapshot() if bow != null and is_instance_valid(bow) else {}
	var tint: Color = data.get("color", Color("edbe7a"))
	if flash_left > 0.0:
		tint = flash_color
	var charge: float = clampf(float(data.get("charge", 0.0)) / maxf(0.01, bow.value("sweet_start", 0.85) if bow != null else 0.85), 0.0, 1.0)
	var axis: Vector2 = aim.normalized()
	if melee_left > 0.0:
		var progress: float = 1.0 - melee_left / melee_duration
		axis = melee_direction.normalized().rotated(lerpf(-0.95, 0.95, progress))
		draw_arc(Vector2.ZERO, 26.0, melee_direction.angle() - 0.95, melee_direction.angle() + 0.95, 12, Color(1.0, 0.9, 0.65, 0.55 * (1.0 - progress)), 3.0)
	var side: Vector2 = axis.orthogonal()
	var back: Vector2 = axis * (-3.0 * recoil)
	if bool(data.get("overcharge", false)):
		back += side * sin(age * 60.0) * (1.0 if bool(data.get("spectral", false)) else 1.8)
	var upper: Vector2 = side * 8.0 + back
	var lower: Vector2 = side * -8.0 + back
	var curve: Vector2 = axis * 4.0 + back
	var cord: Vector2 = axis * (-5.0 * charge) + back
	if data.get("stage", "ready") == "broken":
		draw_line(upper, curve + side * 2.0, tint, 2.0)
		draw_line(curve - side * 2.0, lower, tint, 2.0)
		draw_line(upper, upper - axis * 6.0, Color("bbb4b0"), 1.0)
		draw_line(lower, lower - axis * 4.0, Color("bbb4b0"), 1.0)
		return
	draw_polyline(PackedVector2Array([upper, side * 5.0 + curve, curve, side * -5.0 + curve, lower]), tint, 2.0)
	draw_polyline(PackedVector2Array([upper, cord, lower]), Color("fff1c5"), 1.0)
	if bool(data.get("charging", false)):
		draw_line(cord - axis * 3.0, curve + axis * 6.0, Color("fff1c5"), 1.0)
	if bool(data.get("spectral", false)):
		draw_arc(curve, 12.0 + sin(age * 16.0), 0.0, TAU, 16, Color(0.8, 0.55, 1.0, 0.5), 1.0)
