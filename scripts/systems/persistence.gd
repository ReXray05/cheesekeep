extends RefCounted
class_name Persistence

const UpgradeScript = preload("res://scripts/upgrades/upgrade_manager.gd")
const SAVE_PATH: String = "user://cheesekeep.json"
const DEFAULT_SETTINGS: Dictionary = {"movement_mode": "click", "shoot_button": "right", "music_volume": 0.65, "sfx_volume": 0.8, "help_enabled": true, "effects_enabled": true}

static func retain(history: Array, coins: int, threshold: int = 200) -> Array[String]:
	var ratio: float = clampf(float(coins) / float(maxi(1, threshold)), 0.0, 1.0)
	var count: int = int(floor(float(history.size()) * ratio))
	var manager: RefCounted = UpgradeScript.new()
	manager.setup(history.slice(0, count))
	var result: Array[String] = manager.history.duplicate()
	return result

static func validate_settings(settings: Dictionary) -> Dictionary:
	var result: Dictionary = DEFAULT_SETTINGS.duplicate()
	for key in ["movement_mode", "shoot_button"]:
		var candidate: Variant = settings.get(key)
		if candidate is String and candidate in (["click", "wasd"] if key == "movement_mode" else ["left", "right"]):
			result[key] = candidate
	for key in ["music_volume", "sfx_volume"]:
		var candidate: Variant = settings.get(key)
		if (candidate is float or candidate is int) and is_finite(float(candidate)):
			result[key] = clampf(float(candidate), 0.0, 1.0)
	for key in ["help_enabled", "effects_enabled"]:
		if settings.get(key) is bool:
			result[key] = settings[key]
	return result

static func _load_payload() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var json: JSON = JSON.new()
	if json.parse(FileAccess.get_file_as_string(SAVE_PATH)) != OK or not json.data is Dictionary:
		return {}
	var data: Dictionary = json.data
	var version: Variant = data.get("version", 0)
	if not (version is int or version is float) or float(version) not in [1.0, 2.0]:
		return {}
	return data

static func save(history: Array, settings: Dictionary = {}) -> bool:
	var manager: RefCounted = UpgradeScript.new()
	manager.setup(history)
	var preferences: Dictionary = load_settings()
	for key in settings:
		preferences[key] = settings[key]
	preferences = validate_settings(preferences)
	var file: FileAccess = FileAccess.open(SAVE_PATH + ".tmp", FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify({"version": 2, "history": manager.history, "settings": preferences}))
	var successful: bool = file.get_error() == OK
	file.close()
	if not successful:
		return false
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(SAVE_PATH + ".tmp"), ProjectSettings.globalize_path(SAVE_PATH)) == OK

static func save_settings(settings: Dictionary) -> bool:
	return save(load_history(), settings)

static func load_history() -> Array[String]:
	var data: Dictionary = _load_payload()
	if not data.get("history", []) is Array:
		return []
	var manager: RefCounted = UpgradeScript.new()
	manager.setup(data.get("history", []))
	var result: Array[String] = manager.history.duplicate()
	return result

static func load_settings() -> Dictionary:
	var data: Dictionary = _load_payload()
	var settings: Variant = data.get("settings", {})
	return validate_settings(settings if settings is Dictionary else {})
