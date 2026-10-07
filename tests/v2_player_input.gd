extends SceneTree
const Player = preload("res://scripts/player/player_controller.gd")
const Router = preload("res://scripts/input/input_controller.gd")
const Geometry = preload("res://scripts/systems/tower_geometry.gd")
const Store = preload("res://scripts/systems/persistence.gd")
var checks: int = 0
var failures: int = 0
var melees: Array[Dictionary] = []
var starts: int = 0
var releases: int = 0
func _initialize() -> void:
	call_deferred("run")
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)
func run() -> void:
	for radius in [0.0, 7.0, 14.0]:
		for heading in [Vector2.RIGHT, Vector2.DOWN, Vector2(1,1).normalized()]:
			var start: Vector2 = -heading * 100.0
			var end: Vector2 = Geometry.constrain_motion(start, heading * 100.0, radius)
			check(not Geometry.TOWER_RECT.grow(radius).has_point(end), "No tower tunneling")
			check(end.distance_to(start) < 120.0, "Long segment blocked")
		check(Geometry.accessible_point(Vector2(999,999),radius).length() <= 320-radius+0.01, "Arena projection")
	var p: Node2D = Player.new()
	root.add_child(p)
	p.position = Vector2(-100,80)
	p.destination = p.position
	p.melee_started.connect(func(data: Dictionary) -> void: melees.append(data))
	var anchor: Vector2 = p.aim_anchor()
	p.direction = Vector2.DOWN
	check(p.aim_anchor() == anchor, "Aim stable against direction")
	check(p.request_dash(Vector2.RIGHT), "Dash admitted")
	check(p.request_melee(Vector2.RIGHT,false), "Melee queued in dash")
	check(not p.request_melee(Vector2.DOWN,false), "Only one queued melee")
	p.tick(0.18,true)
	check(melees.is_empty(), "Charging at dash finish invalidates melee")
	check(absf(p.position.x + 25.0)<0.01, "Dash exact 75 at long delta")
	p.tick(1.0,false)
	check(p.request_melee(Vector2(5,0),false), "Melee freely admitted")
	check(melees.size() == 1 and melees[0].direction == Vector2.RIGHT, "Melee single normalized payload")
	check(not p.request_melee(Vector2.RIGHT,false), "Melee cooldown")
	p.tick(0.5,false)
	check(not p.request_melee(Vector2.RIGHT,true), "Charge disallows melee")
	p.tower_enabled = true
	p.position = Vector2(0,38)
	check(p.request_interact() and p.mounted, "Near tower explicit mount")
	check(p.request_dash(Vector2.DOWN) and not p.mounted, "Mounted dash dismounts")
	p.tick(0.18,false)
	check(p.position.y > 100 and not p.mounted, "No dash automount")
	p.invulnerable = 0
	p.hurt(1000)
	check(not p.alive and p.dash_left == 0 and p.melee_left == 0, "Death clears actions")
	p.revive()
	p.position = Vector2(0,-100)
	p.go_to(Vector2(0,100))
	for i in range(400):
		p.tick(0.016,false)
	check(p.position.distance_to(Vector2(0,100))<1.0, "Click detours fully across cheese")
	p.set_movement_input(Vector2.RIGHT,true)
	p.tick(0.1,false)
	var stopped: Vector2 = p.position
	p.set_movement_input(Vector2.ZERO,true)
	p.tick(1.0,false)
	check(p.position == stopped, "WASD release does not chase old destination")
	p.free()
	var input: Node = Router.new()
	root.add_child(input)
	var field: Control = Control.new()
	field.size = Vector2(360,360)
	root.add_child(field)
	var world: SubViewport = SubViewport.new()
	world.size = Vector2i(360,360)
	root.add_child(world)
	input.field = field
	input.viewport = world
	input.start_requested.connect(func() -> void: starts += 1; input.captured = true)
	input.release_requested.connect(func() -> void: releases += 1)
	for selected in ["left", "right"]:
		for mode in ["click", "wasd"]:
			input.reset()
			input.apply_settings({"shoot_button":selected,"movement_mode":mode})
			var down: InputEventMouseButton = InputEventMouseButton.new()
			down.position = Vector2(50,50)
			down.button_index = MOUSE_BUTTON_LEFT if selected == "left" else MOUSE_BUTTON_RIGHT
			down.pressed = true
			input._unhandled_input(down)
			check(input.captured and input.captured_button == down.button_index, "Configured capture")
			input.set_suspended(true)
			var up: InputEventMouseButton = down.duplicate()
			up.pressed = false
			up.position = Vector2(900,900)
			var before: int = releases
			input._input(up)
			check(input.pending_release and releases == before, "Paused global release deferred")
			input.set_suspended(false)
			check(releases == before, "Resume no autoshot")
			var before_starts: int = starts
			input._unhandled_input(down)
			check(starts == before_starts and not input.pending_release, "Explicit recapture retains charge")
			input._input(up)
			check(releases == before+1, "Recapture resolves exactly once")
	input.reset()
	input.free()
	field.free()
	world.free()
	var previous: String = FileAccess.get_file_as_string(Store.SAVE_PATH) if FileAccess.file_exists(Store.SAVE_PATH) else ""
	check(Store.save(["fast_draw"], {"movement_mode":"wasd","shoot_button":"left","music_volume":2.0,"sfx_volume":-0.5}), "V2 save")
	check(Store.load_settings().music_volume == 1.0 and Store.load_settings().sfx_volume == 0.0, "Volume clamp")
	check(Store.save(["fast_draw"]), "Defeat save")
	check(Store.load_settings().movement_mode == "wasd", "Defeat preserves settings")
	check(Store.save_settings({"effects_enabled":false}) and Store.load_history() == ["fast_draw"], "Settings preserve retained history")
	var file: FileAccess = FileAccess.open(Store.SAVE_PATH, FileAccess.WRITE)
	file.store_string('{"version":1,"history":["fast_draw"],"settings":{"shoot_button":"left"}}')
	file.close()
	check(Store.load_history() == ["fast_draw"] and Store.load_settings().shoot_button == "left", "V1 migration preserves IDs/settings")
	file = FileAccess.open(Store.SAVE_PATH, FileAccess.WRITE)
	file.store_string('{"version":99,"history":["fast_draw"]}')
	file.close()
	check(Store.load_history().is_empty() and Store.load_settings().movement_mode == "click", "Future version safe defaults")
	if previous.is_empty():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(Store.SAVE_PATH))
	else:
		file = FileAccess.open(Store.SAVE_PATH, FileAccess.WRITE)
		file.store_string(previous)
		file.close()
	print("V2 PLAYER INPUT: ", checks, " checks, ", failures, " failures")
	quit(0 if failures == 0 else 1)

