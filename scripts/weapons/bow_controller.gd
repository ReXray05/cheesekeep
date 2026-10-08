extends Node
class_name BowController

signal shot(data: Dictionary)
signal snapped
signal recovered
signal charge_stage_changed(stage: String)

enum State { IDLE, CHARGING, OVERCHARGING, COOLDOWN }
var charge_time: float = 0.0
var state: int = State.IDLE
var config: Dictionary = {}
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var cooldown_left: float = 0.0
var stage: String = "ready"

func _ready() -> void:
	for child: Node in get_children():
		if child is BowVisuals or child is AimIndicator:
			child.bow = self

func setup(settings: Dictionary) -> void:
	config = settings.duplicate(true)
	rng.randomize()
	reset()

func value(key: String, fallback: float) -> float:
	return float(config.get(key, fallback))

# UpgradeManager supplies recomposed timings. Guard malformed injected configs here.
func thresholds() -> Array[float]:
	var green: float = maxf(0.01, value("sweet_start", 0.85))
	var green_end: float = maxf(green + 0.01, value("sweet_end", 0.98))
	var purple: float = maxf(green_end + 0.01, value("spectral_start", 1.55))
	var purple_end: float = maxf(purple + 0.01, value("spectral_end", 1.67))
	var breaking: float = maxf(purple_end + 0.01, value("break_time", 1.85))
	return [green, green_end, purple, purple_end, breaking]

func _set_stage(next: String) -> void:
	if stage != next:
		stage = next
		charge_stage_changed.emit(stage)

func begin_charge() -> bool:
	if state != State.IDLE:
		return false
	charge_time = 0.0
	state = State.CHARGING
	_set_stage("low")
	return true

func tick(delta: float) -> void:
	delta = maxf(0.0, delta)
	if state == State.COOLDOWN:
		cooldown_left = maxf(0.0, cooldown_left - delta)
		if cooldown_left <= 0.0:
			state = State.IDLE
			_set_stage("ready")
			recovered.emit()
		return
	if state != State.CHARGING and state != State.OVERCHARGING:
		return
	var limits: Array[float] = thresholds()
	charge_time += delta
	if charge_time >= limits[4]:
		state = State.COOLDOWN
		charge_time = 0.0
		cooldown_left = maxf(0.0, value("cooldown", 1.5))
		_set_stage("broken")
		snapped.emit()
		return
	state = State.OVERCHARGING if charge_time > limits[1] else State.CHARGING
	_set_stage(_charge_stage(limits))

func _charge_stage(limits: Array[float]) -> String:
	if charge_time < limits[0]:
		return "low"
	if charge_time <= limits[1]:
		return "perfect"
	if charge_time < limits[2]:
		return "overcharge"
	if charge_time <= limits[3]:
		return "spectral"
	return "final"

func snapshot() -> Dictionary:
	var limits: Array[float] = thresholds()
	var normal: float = clampf(charge_time / limits[0], 0.0, 1.0)
	var excess: float = clampf((charge_time - limits[1]) / (limits[4] - limits[1]), 0.0, 1.0)
	var charging: bool = state == State.CHARGING or state == State.OVERCHARGING
	var current: String = _charge_stage(limits) if charging else ("broken" if state == State.COOLDOWN else "ready")
	var critical: bool = current == "perfect"
	var spectral: bool = current == "spectral"
	var overcharge: bool = charging and state == State.OVERCHARGING
	var power: float = lerpf(value("damage_min", 12), value("damage_opt", 34), normal)
	var arrow_speed: float = lerpf(value("speed_min", 190), value("speed_opt", 360), normal)
	var shot_range: float = lerpf(value("range_min", 65), value("range_opt", 210), normal)
	var width: float = lerpf(value("width_min", 42.5), value("width_opt", 3.5), normal)
	var tint: Color = Color("ff9b42")
	var label: String = "TENSANDO" if charging else "LISTO"
	if critical:
		tint = Color("91ed70")
		label = "¡CRÍTICO!"
	if overcharge:
		power = lerpf(value("damage_opt", 34), value("damage_max", 50), excess)
		arrow_speed = lerpf(value("speed_opt", 360), value("speed_max", 450), excess)
		shot_range = lerpf(value("range_opt", 210), value("range_max", 280), excess)
		width = lerpf(value("width_opt", 3.5), value("width_max", 27.5), excess)
		tint = Color("ff535b")
		label = "PELIGRO" if current != "final" else "¡ROTURA!"
	if spectral:
		power = value("spectral_damage", 56)
		arrow_speed = value("spectral_speed", 420)
		width = value("spectral_half_width", 18)
		tint = Color("cf8bff")
		label = "ESPECTRAL"
	if state == State.COOLDOWN:
		tint = Color("797d90")
		label = "REPARANDO"
	return {"state_label": label, "charge": charge_time, "power": power,
		"range": shot_range, "half_width": width, "color": tint,
		"critical": critical, "charging": charging, "stage": current, "spectral": spectral,
		"overcharge": overcharge, "speed": arrow_speed, "excess": excess,
		"cooldown": cooldown_left}

func release(direction: Vector2) -> void:
	if state != State.CHARGING and state != State.OVERCHARGING:
		return
	var data: Dictionary = snapshot()
	var aim: Vector2 = direction.normalized() if direction.length_squared() > 0.0001 else Vector2.RIGHT
	var spectral: bool = bool(data["spectral"])
	var endpoint: Vector2 = aim * float(data["range"])
	if not spectral:
		endpoint += aim.orthogonal() * rng.randf_range(-float(data["half_width"]), float(data["half_width"]))
	var critical: bool = bool(data["critical"])
	var damage: float = float(data["power"]) * (value("crit_multiplier", 1.5) if critical else 1.0)
	var pierce: int = 1
	if bool(data["overcharge"]):
		pierce = 2 + (1 if float(data["excess"]) >= 0.6 else 0)
	pierce += maxi(0, int(value("pierce_bonus", 0)))
	if spectral:
		pierce = -1
	state = State.IDLE
	charge_time = 0.0
	_set_stage("ready")
	shot.emit({"direction": endpoint.normalized(), "speed": float(data["speed"]),
		"damage": damage, "critical": critical, "pierce": pierce, "range": endpoint.length(),
		"stage": data["stage"], "spectral": spectral, "range_limited": data["stage"] == "low",
		"half_width": float(data["half_width"]), "lifetime": value("arrow_lifetime", 6.0)})

func reset() -> void:
	state = State.IDLE
	charge_time = 0.0
	cooldown_left = 0.0
	_set_stage("ready")
