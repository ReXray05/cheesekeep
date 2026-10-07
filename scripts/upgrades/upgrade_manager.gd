extends RefCounted
class_name UpgradeManager

var history: Array[String] = []
var ranks: Dictionary = {}
var definitions: Array = []
var expanded: bool = false
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var cached_offers: Array[Dictionary] = []

func _init() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/upgrades.json"))
	if parsed is Array:
		definitions = parsed
	rng.randomize()

func setup(retained: Array) -> void:
	history.clear()
	ranks.clear()
	cached_offers.clear()
	for item: Variant in retained:
		if item is String:
			var definition: Dictionary = find_definition(item)
			if eligible(definition, false):
				apply_acquisition(str(item))

func find_definition(id: String) -> Dictionary:
	for definition: Dictionary in definitions:
		if str(definition.get("id", "")) == id:
			return definition
	return {}

func eligible(definition: Dictionary, visible_only: bool = true) -> bool:
	if definition.is_empty():
		return false
	if visible_only and not expanded and not bool(definition.get("root", false)):
		return false
	var id: String = str(definition["id"])
	if int(ranks.get(id, 0)) >= int(definition.get("max_rank", 1)):
		return false
	var requirements: Array = definition.get("requires", [])
	for prerequisite: String in requirements:
		if int(ranks.get(prerequisite, 0)) == 0:
			return false
	return true

func offers() -> Array[Dictionary]:
	if not cached_offers.is_empty():
		return cached_offers.duplicate(true)
	var candidates: Array[Dictionary] = []
	for definition: Dictionary in definitions:
		if eligible(definition):
			candidates.append(definition)
	while not candidates.is_empty() and cached_offers.size() < 3:
		var index: int = rng.randi_range(0, candidates.size() - 1)
		cached_offers.append(candidates[index].duplicate(true))
		candidates.remove_at(index)
	return cached_offers.duplicate(true)

func acquire(id: String) -> bool:
	var definition: Dictionary = find_definition(id)
	if not eligible(definition):
		return false
	apply_acquisition(id)
	cached_offers.clear()
	return true

func apply_acquisition(id: String) -> void:
	history.append(id)
	ranks[id] = int(ranks.get(id, 0)) + 1

func rebuild(base: Dictionary) -> Dictionary:
	var result: Dictionary = base.duplicate(true)
	# Add V2 defaults before effects so migrated V1 files remain meaningful.
	var bow_defaults: Dictionary = {"spectral_start":1.55,"spectral_end":1.67,"break_time":1.85,"spectral_damage":28.0,"spectral_half_width":18.0}
	var player_defaults: Dictionary = {"melee_range":32.0,"melee_angle":110.0,"melee_damage":12.0,"melee_knockback":14.0,"melee_cooldown":0.45,"melee_duration":0.18,"dash_distance":75.0,"dash_duration":0.18,"dash_cooldown":1.0,"dash_iframes":0.08,"collect_radius":12.0,"magnet_radius":12.0}
	for group: String in ["bow", "player"]:
		var defaults: Dictionary = bow_defaults if group == "bow" else player_defaults
		var section: Dictionary = result.get(group, {})
		for key: String in defaults:
			if not section.has(key): section[key] = defaults[key]
		result[group] = section
	# Definition order makes rebuilding independent of acquisition ordering.
	for definition: Dictionary in definitions:
		for rank_index in range(int(ranks.get(str(definition.id), 0))):
			for effect: Dictionary in definition.get("effects", []):
				var path: PackedStringArray = str(effect.get("path", "")).split(".")
				if path.size() != 2: continue
				var category: Dictionary = result.get(path[0], {})
				var current: float = float(category.get(path[1], 0.0))
				var amount: float = float(effect.get("value", 0.0))
				category[path[1]] = current * amount if str(effect.get("operation", "add")) == "multiply" else current + amount
				result[path[0]] = category
	var bow: Dictionary = result.bow
	bow.sweet_start = maxf(0.05, float(bow.get("sweet_start", 0.85)))
	bow.sweet_end = maxf(bow.sweet_start + 0.02, float(bow.get("sweet_end", 0.98)))
	bow.spectral_start = maxf(bow.sweet_end + 0.02, float(bow.spectral_start))
	bow.spectral_end = maxf(bow.spectral_start + 0.02, float(bow.spectral_end))
	bow.break_time = maxf(bow.spectral_end + 0.04, float(bow.break_time))
	var player: Dictionary = result.player
	player.charging_slow = clampf(float(player.get("charging_slow", 0.65)), 0.1, 1.0)
	player.dash_duration = clampf(float(player.dash_duration), 0.08, 0.5)
	player.dash_cooldown = maxf(float(player.dash_duration), float(player.dash_cooldown))
	player.dash_iframes = clampf(float(player.dash_iframes), 0.0, float(player.dash_duration))
	player.melee_duration = clampf(float(player.melee_duration), 0.05, 0.5)
	player.melee_cooldown = maxf(float(player.melee_duration), float(player.melee_cooldown))
	player.melee_angle = clampf(float(player.melee_angle), 10.0, 180.0)
	player.collect_radius = maxf(1.0, float(player.collect_radius))
	player.magnet_radius = maxf(float(player.collect_radius), float(player.magnet_radius))
	if result.has("tower"):
		result.tower.mounted_damage = maxf(1.0, float(result.tower.get("mounted_damage", 1.5)))
	if result.has("economy"):
		result.economy.repair_price = maxf(1.0, float(result.economy.get("repair_price", 12)))
	return result
