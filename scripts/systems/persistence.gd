extends RefCounted
class_name Persistence

const UpgradeScript = preload("res://scripts/upgrades/upgrade_manager.gd")
const SAVE_PATH: String = "user://cheesekeep.json"

static func retain(history: Array, coins: int, threshold: int = 200) -> Array[String]:
	var ratio: float = clampf(float(coins) / float(maxi(1, threshold)), 0.0, 1.0)
	var count: int = int(floor(float(history.size()) * ratio))
	var selected: Array = history.slice(0, count)
	var manager: RefCounted = UpgradeScript.new()
	manager.setup(selected)
	var result: Array[String] = manager.history.duplicate()
	return result

static func save(history: Array, settings: Dictionary = {}) -> bool:
	var manager: RefCounted = UpgradeScript.new()
	manager.setup(history)
	var file: FileAccess = FileAccess.open(SAVE_PATH + ".tmp", FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify({"version": 1, "history": manager.history, "settings": settings}))
	var successful: bool = file.get_error() == OK
	file.close()
	if not successful:
		return false
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(SAVE_PATH + ".tmp"), ProjectSettings.globalize_path(SAVE_PATH)) == OK

static func load_history() -> Array[String]:
	if not FileAccess.file_exists(SAVE_PATH):
		return []
	var json: JSON = JSON.new()
	if json.parse(FileAccess.get_file_as_string(SAVE_PATH)) != OK:
		return []
	var parsed: Variant = json.data
	if not parsed is Dictionary:
		return []
	var data: Dictionary = parsed
	var version: Variant = data.get("version", 0)
	if not (version is int or version is float):
		return []
	if int(version) != 1 or not data.get("history", []) is Array:
		return []
	var manager: RefCounted = UpgradeScript.new()
	manager.setup(data.get("history", []))
	var result: Array[String] = manager.history.duplicate()
	return result
