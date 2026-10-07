extends Node
class_name BowController

signal shot(data: Dictionary)
signal snapped

enum State { IDLE, CHARGING, OVERCHARGING, COOLDOWN }
var charge_time: float = 0.0
var state: int = State.IDLE
var config: Dictionary = {}
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var cooldown_left: float = 0.0

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

func begin_charge() -> bool:
	if state != State.IDLE:
		return false
	charge_time = 0.0
	state = State.CHARGING
	return true

func tick(delta: float) -> void:
	if state == State.COOLDOWN:
		cooldown_left = maxf(0.0, cooldown_left - delta)
		if cooldown_left <= 0.0:
			state = State.IDLE
		return
	if state != State.CHARGING and state != State.OVERCHARGING:
		return
	charge_time += delta
	var sweet_end: float = value("sweet_end", 0.98)
	if charge_time > sweet_end:
		state = State.OVERCHARGING
		var peak: float = maxf(sweet_end + 0.01, value("overcharge_peak", 2.2))
		var stress: float = maxf(0.0, (charge_time - sweet_end) / (peak - sweet_end))
		var rate: float = minf(4.0, value("break_peak_rate", 0.7) * stress)
		if rng.randf() < 1.0 - exp(-rate * delta):
			state = State.COOLDOWN
			charge_time = 0.0
			cooldown_left = value("cooldown", 1.5)
			snapped.emit()

func snapshot() -> Dictionary:
	var sweet_start: float = value("sweet_start", 0.85)
	var sweet_end: float = value("sweet_end", 0.98)
	var peak: float = maxf(sweet_end + 0.01, value("overcharge_peak", 2.2))
	var normal: float = clampf(charge_time / maxf(0.01, sweet_start), 0.0, 1.0)
	var excess: float = clampf((charge_time - sweet_end) / (peak - sweet_end), 0.0, 1.0)
	var critical: bool = charge_time >= sweet_start and charge_time <= sweet_end
	var charging: bool = state == State.CHARGING or state == State.OVERCHARGING
	var overcharge: bool = state == State.OVERCHARGING
	var power: float = lerpf(value("damage_min", 12), value("damage_opt", 34), normal)
	var arrow_speed: float = lerpf(value("speed_min", 190), value("speed_opt", 360), normal)
	var shot_range: float = lerpf(value("range_min", 65), value("range_opt", 210), normal)
	var width: float = lerpf(value("width_min", 42.5), value("width_opt", 3.5), normal)
	var tint: Color = Color("ff9b42")
	var label: String = "LISTO"
	if charging:
		label = "TENSANDO"
	if critical and charging:
		tint = Color("91ed70")
		label = "¡CRÍTICO!"
	if overcharge:
		power = lerpf(value("damage_opt", 34), value("damage_max", 50), excess)
		arrow_speed = lerpf(value("speed_opt", 360), value("speed_max", 450), excess)
		shot_range = lerpf(value("range_opt", 210), value("range_max", 280), excess)
		width = lerpf(value("width_opt", 3.5), value("width_max", 27.5), excess)
		tint = Color("ff535b")
		label = "PELIGRO"
	if state == State.COOLDOWN:
		label = "REPARANDO"
	return {"state_label": label, "charge": charge_time, "power": power,
		"range": shot_range, "half_width": width, "color": tint,
		"critical": critical and charging, "charging": charging,
		"overcharge": overcharge, "speed": arrow_speed, "excess": excess,
		"cooldown": cooldown_left}

func release(direction: Vector2) -> void:
	if state != State.CHARGING and state != State.OVERCHARGING:
		return
	var data: Dictionary = snapshot()
	var aim: Vector2 = direction.normalized() if direction.length_squared() > 0.0001 else Vector2.RIGHT
	var endpoint: Vector2 = aim * float(data["range"]) + aim.orthogonal() * rng.randf_range(-float(data["half_width"]), float(data["half_width"]))
	var critical: bool = bool(data["critical"])
	var damage: float = float(data["power"]) * (value("crit_multiplier", 1.5) if critical else 1.0)
	var pierce: int = 1
	if bool(data["overcharge"]):
		pierce = 2 + (1 if float(data["excess"]) >= 0.6 else 0)
	state = State.IDLE
	charge_time = 0.0
	shot.emit({"direction": endpoint.normalized(), "speed": float(data["speed"]),
		"damage": damage, "critical": critical, "pierce": pierce, "range": endpoint.length()})

func reset() -> void:
	state = State.IDLE
	charge_time = 0.0
	cooldown_left = 0.0
