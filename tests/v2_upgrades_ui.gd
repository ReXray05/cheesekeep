extends SceneTree
const HUD = preload("res://scripts/ui/hud.gd")
var failures: int = 0
var assertions: int = 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, label: String) -> void:
	assertions += 1
	if not condition:
		failures += 1
		push_error(label)

func run() -> void:
	var base: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/balance.json"))
	var manager: UpgradeManager = UpgradeManager.new()
	manager.expanded = true
	check(manager.definitions.size() == 20, "20 compact combinable nodes")
	var old_ids: Array[String] = ["fast_draw", "damage", "stride", "cheese", "precision", "steady_string", "piercing", "keen_edge", "momentum", "nimble", "repair", "rind"]
	var historical: Array[String] = []
	for id: String in old_ids:
		for rank_index in range(int(manager.find_definition(id).max_rank)):
			historical.append(id)
	manager.setup(historical)
	check(manager.history == historical, "Valid V1 ranks and prerequisite history survives")
	for length in range(historical.size() + 1):
		manager.setup(historical.slice(0, length))
		check(manager.history == historical.slice(0, length), "Retained prefix remains valid")
	for fast_rank in range(4):
		for steady_rank in range(4):
			for window_rank in range(2):
				var acquired: Array[String] = []
				for rank_index in range(fast_rank): acquired.append("fast_draw")
				if fast_rank > 0:
					for rank_index in range(steady_rank): acquired.append("steady_string")
					if steady_rank > 0 and window_rank > 0: acquired.append("spectral_window")
				manager.setup(acquired)
				var rebuilt: Dictionary = manager.rebuild(base)
				var b: Dictionary = rebuilt.bow
				check(b.sweet_start < b.sweet_end and b.sweet_end < b.spectral_start and b.spectral_start < b.spectral_end and b.spectral_end < b.break_time, "Every timing rank combination stays ordered")
				check(rebuilt == manager.rebuild(base), "Rebuild is idempotent")
		manager.setup(["fast_draw", "fast_draw", "fast_draw"])
	var accelerated: Dictionary = manager.rebuild(base).bow
	var factor: float = pow(0.92, 3)
	check(is_equal_approx(accelerated.spectral_start, 1.55 * factor) and is_equal_approx(accelerated.spectral_end, 1.67 * factor) and is_equal_approx(accelerated.break_time, 1.85 * factor), "Fast draw scales every V2 clock jointly")
	manager.setup(["fast_draw", "steady_string", "fast_draw"])
	var mixed_first: Dictionary = manager.rebuild(base)
	manager.setup(["fast_draw", "fast_draw", "steady_string"])
	check(mixed_first == manager.rebuild(base), "Acquisition order does not change the same ranks")
	var invalid_clocks: Dictionary = base.duplicate(true)
	invalid_clocks.player.merge({"dash_duration":0.18,"dash_iframes":5.0,"dash_cooldown":0.01,"melee_duration":0.18,"melee_cooldown":0.01,"charging_slow":8.0}, true)
	var safe_player: Dictionary = manager.rebuild(invalid_clocks).player
	check(safe_player.dash_iframes <= safe_player.dash_duration and safe_player.dash_cooldown >= safe_player.dash_duration and safe_player.melee_cooldown >= safe_player.melee_duration and safe_player.charging_slow <= 1, "Invalid durations and movement cannot invert clocks")
	manager.setup([])
	var offers: Array[Dictionary] = manager.offers()
	var ids: Array = []
	for item: Dictionary in offers:
		check(manager.eligible(item) and not ids.has(item.id), "Offers are unique and eligible")
		ids.append(item.id)
	check(offers == manager.offers(), "Offers cached until acquisition")
	check(not manager.acquire("shove"), "Cannot bypass prerequisite")
	var all_history: Array[String] = []
	for item: Dictionary in manager.definitions:
		for rank_index in range(int(item.max_rank)):
			all_history.append(str(item.id))
	manager.setup(all_history)
	check(manager.history == all_history, "All specializations coexist")
	var max_config: Dictionary = manager.rebuild(base)
	check(max_config.player.melee_range == 42 and max_config.player.melee_angle == 160 and max_config.player.melee_knockback == 28, "Melee changes shape and displacement")
	check(max_config.bow.spectral_half_width == 27 and max_config.player.magnet_radius == 44, "Spectral and collection change physical geometry")
	check(max_config.player.dash_iframes <= max_config.player.dash_duration and max_config.player.dash_duration <= max_config.player.dash_cooldown, "Dash clocks remain coherent")
	check(base.bow.sweet_start == 0.85, "Base remains unchanged")
	var hud: Control = HUD.new()
	root.size = Vector2i(1152, 720)
	root.add_child(hud)
	hud.setup(false)
	hud.update_status({"hp":100,"max_hp":100,"tower_hp":300,"tower_max":300,"ammo":0,"coins":0,"phase":"CHOICE","shoot_button":"left","movement_mode":"wasd","help_enabled":true,"bow":{"state_label":"MORADO", "charge":1.6,"color":Color("9051ba")}})
	hud.show_offers(offers)
	await process_frame
	await process_frame
	check(hud._controls.text.contains("WASD") and hud._controls.text.contains("IZQ: cargar"), "Controls reflect settings")
	check(hud._help.visible and hud._charge.max_time == 1.85, "Help settings and guaranteed break visible")
	check(hud._status.text.contains("Flechas: 0") and hud._hp.visible and hud._cheese.visible, "Vital metrics remain visible at zero resources")
	for node: Control in [hud._help, hud.message, hud._controls]:
		check(node.global_position.y + node.size.y <= 720, "Side panels fit within 720px")
	var stable_count: int = hud.get_child_count()
	for iteration in range(20):
		hud.show_tree(historical, manager.definitions)
		await process_frame
		check(hud._tree.position.y + hud._tree.size.y <= 720, "Tree window stays within frame")
		check(hud._tree.nodes.size() == 20 and hud._tree.links.size() >= 20, "Tree has graph nodes and requirement links")
		check(hud._tree.nodes.shove.tooltip_text.contains("Bloqueada".to_upper()), "Locked state communicates requirements")
		hud.close_tree()
		await process_frame
		check(hud.get_child_count() == stable_count and not hud.has_overlay(), "Opening/closing tree never grows HUD nodes")
	if DisplayServer.get_name() != "headless":
		hud.show_tree(historical, manager.definitions)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://ui-proof.png")
	hud.queue_free()
	await process_frame
	print("V2 UPGRADES/UI: %d assertions, %d failures" % [assertions, failures])
	quit(0 if failures == 0 else 1)

