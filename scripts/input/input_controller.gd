extends Node

signal move_requested(destination: Vector2)
signal start_requested
signal release_requested
signal melee_requested
signal dash_requested
signal interact_requested
signal pause_requested

var field: Control
var viewport: SubViewport
var enabled: bool = true
var mouse_world: Vector2 = Vector2.RIGHT * 100.0
var inside: bool = false
var suspended: bool = false
var pending_release: bool = false
var movement_mode: String = "click"
var shoot_button: String = "right"
var captured_button: int = MOUSE_BUTTON_RIGHT
var captured: bool = false:
	set(value):
		captured = value
		if value:
			captured_button = _requested_button
		else:
			pending_release = false
var _requested_button: int = MOUSE_BUTTON_RIGHT
var _held_keys: Dictionary = {}
var _physical_hold_seen: bool = false

func apply_settings(settings: Dictionary) -> void:
	# Remapping never changes ownership of an existing hold.
	var mode: String = str(settings.get("movement_mode", movement_mode))
	var button: String = str(settings.get("shoot_button", shoot_button))
	if mode in ["click", "wasd"]:
		movement_mode = mode
	if button in ["left", "right"]:
		shoot_button = button

func set_suspended(value: bool) -> void:
	suspended = value
	_held_keys.clear()
	if captured and _physical_hold_seen and not Input.is_mouse_button_pressed(captured_button):
		pending_release = true

func movement_vector() -> Vector2:
	if not enabled or suspended or movement_mode != "wasd":
		return Vector2.ZERO
	return Vector2(float(_held_keys.get(KEY_D, false)) - float(_held_keys.get(KEY_A, false)), float(_held_keys.get(KEY_S, false)) - float(_held_keys.get(KEY_W, false))).normalized()

func _process(_delta: float) -> void:
	if not is_instance_valid(field) or not is_instance_valid(viewport):
		return
	_update_mouse(field.get_global_mouse_position())
	if captured and _physical_hold_seen and not Input.is_mouse_button_pressed(captured_button) and not pending_release:
		_release_capture()

func _update_mouse(point: Vector2) -> void:
	if not is_instance_valid(field) or not is_instance_valid(viewport):
		inside = false
		return
	var rect: Rect2 = field.get_global_rect()
	inside = rect.has_point(point)
	if inside and rect.size.x > 0.0 and rect.size.y > 0.0:
		var local: Vector2 = (point - rect.position) * Vector2(viewport.size) / rect.size
		mouse_world = viewport.get_canvas_transform().affine_inverse() * local

func _release_capture() -> void:
	if suspended:
		pending_release = true
		return
	if pending_release:
		return
	captured = false
	_physical_hold_seen = false
	release_requested.emit()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key: InputEventKey = event
		if key.keycode == KEY_ESCAPE and key.pressed and not key.echo:
			pause_requested.emit()
			get_viewport().set_input_as_handled()
		if not key.pressed:
			_held_keys.erase(key.keycode)
	if event is InputEventMouseButton:
		var button: InputEventMouseButton = event
		if not button.pressed and captured and button.button_index == captured_button:
			_release_capture()

func _unhandled_input(event: InputEvent) -> void:
	if not enabled or suspended:
		return
	if event is InputEventKey:
		var key: InputEventKey = event
		if not key.pressed or key.echo:
			return
		if key.keycode in [KEY_W, KEY_A, KEY_S, KEY_D]:
			_held_keys[key.keycode] = true
		elif key.keycode == KEY_SPACE:
			dash_requested.emit()
		elif key.keycode == KEY_E and movement_mode == "wasd":
			interact_requested.emit()
	if not event is InputEventMouseButton:
		return
	var button: InputEventMouseButton = event
	if not button.pressed:
		return
	_update_mouse(button.position)
	if not inside:
		return
	var selected: int = MOUSE_BUTTON_LEFT if shoot_button == "left" else MOUSE_BUTTON_RIGHT
	if captured and pending_release and button.button_index == captured_button:
		# Resume the existing charge only after an explicit fresh press.
		pending_release = false
		_physical_hold_seen = Input.is_mouse_button_pressed(captured_button)
		return
	if button.button_index == selected:
		if not captured:
			_requested_button = selected
			_physical_hold_seen = Input.is_mouse_button_pressed(selected)
			start_requested.emit()
	elif button.button_index == MOUSE_BUTTON_MIDDLE:
		melee_requested.emit()
	elif button.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT]:
		move_requested.emit(mouse_world)

func reset() -> void:
	captured = false
	pending_release = false
	_physical_hold_seen = false
	_held_keys.clear()

