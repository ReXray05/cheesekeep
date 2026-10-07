extends Node

signal move_requested(destination: Vector2)
signal start_requested
signal release_requested

var field: Control
var viewport: SubViewport
var captured: bool = false
var enabled: bool = true
var mouse_world: Vector2 = Vector2.RIGHT * 100.0
var inside: bool = false

func _process(_delta: float) -> void:
	if not is_instance_valid(field):
		return
	var point: Vector2 = field.get_global_mouse_position()
	var rect: Rect2 = field.get_global_rect()
	inside = rect.has_point(point)
	if inside:
		var local: Vector2 = (point - rect.position) * Vector2(viewport.size) / rect.size
		mouse_world = viewport.get_canvas_transform().affine_inverse() * local
	if captured and not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		captured = false
		release_requested.emit()

func _input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	var button: InputEventMouseButton = event as InputEventMouseButton
	if button.button_index == MOUSE_BUTTON_RIGHT and not button.pressed:
		if captured:
			captured = false
			release_requested.emit()
		return
	if not enabled or not button.pressed or not is_instance_valid(field):
		return
	var rect: Rect2 = field.get_global_rect()
	if not rect.has_point(button.position):
		return
	var local: Vector2 = (button.position - rect.position) * Vector2(viewport.size) / rect.size
	mouse_world = viewport.get_canvas_transform().affine_inverse() * local
	if button.button_index == MOUSE_BUTTON_LEFT:
		move_requested.emit(mouse_world)
	elif button.button_index == MOUSE_BUTTON_RIGHT:
		start_requested.emit()

func reset() -> void:
	captured = false
