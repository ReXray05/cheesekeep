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
	for id: String in history:
		var definition: Dictionary = find_definition(id)
		var effects: Array = definition.get("effects", [])
		for effect: Dictionary in effects:
			var path: PackedStringArray = str(effect.get("path", "")).split(".")
			if path.size() != 2:
				continue
			var category: Dictionary = result.get(path[0], {})
			var current: float = float(category.get(path[1], 0.0))
			var amount: float = float(effect.get("value", 0.0))
			if str(effect.get("operation", "add")) == "multiply":
				category[path[1]] = current * amount
			else:
				category[path[1]] = current + amount
			result[path[0]] = category
	# Movement while aiming cannot become faster than normal movement.
	if result.has("player"):
		var player: Dictionary = result["player"]
		player["charging_slow"] = clampf(float(player.get("charging_slow", 0.65)), 0.1, 1.0)
	return result
