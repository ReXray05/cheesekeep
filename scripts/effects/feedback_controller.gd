extends Node2D
class_name FeedbackController

var enabled: bool = true:
	set(value):
		enabled = value
		if not value:
			particles.clear()
			rings.clear()
			shake_strength = 0.0
			flash_strength = 0.0
			queue_redraw()
var audio_enabled: bool = true:
	set(value):
		audio_enabled = value
		if not value:
			for player: AudioStreamPlayer in players:
				player.stop()
			if is_instance_valid(music):
				music.stop()
		elif activated and is_instance_valid(music) and not music.playing:
			music.play()
var shake_strength: float = 0.0
var flash_strength: float = 0.0
var particles: Array[Dictionary] = []
var rings: Array[Dictionary] = []
var players: Array[AudioStreamPlayer] = []
var music: AudioStreamPlayer
var sounds: Dictionary = {}
var activated: bool = false
var music_volume: float = 0.7:
	set(value):
		music_volume = clampf(value,0,1)
		if is_instance_valid(music): music.volume_db = -22.0 + linear_to_db(maxf(0.0001,music_volume))
var sfx_volume: float = 0.8:
	set(value):
		sfx_volume = clampf(value,0,1)
		for voice: AudioStreamPlayer in players:
			voice.volume_db = -12.0 + linear_to_db(maxf(0.0001,sfx_volume))
var sound_index: int = 0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func setup() -> void:
	if not players.is_empty():
		return
	z_index = 20
	rng.randomize()
	for index: int in range(8):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
		player.volume_db = -12.0
		add_child(player)
		players.append(player)
	for key: String in ["fire", "impact", "critical", "blocked", "snap", "damage", "purchase", "wave_start", "wave_clear", "over", "dash", "melee", "ready", "spectral", "perfect"]:
		sounds[key] = load("res://assets/audio/" + key + ".wav")
	music = AudioStreamPlayer.new()
	music.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
	var track: AudioStreamWAV = load("res://assets/audio/music.wav")
	if track != null:
		track = track.duplicate()
		track.loop_mode = AudioStreamWAV.LOOP_FORWARD
		track.loop_begin = 0
		track.loop_end = int(track.get_length() * track.mix_rate)
		music.stream = track
	music.volume_db = -22.0
	add_child(music)

func tick(delta: float) -> void:
	if not enabled:
		return
	shake_strength = maxf(0.0, shake_strength - delta * 12.0)
	flash_strength = maxf(0.0, flash_strength - delta * 3.0)
	for particle: Dictionary in particles:
		particle["life"] = float(particle["life"]) - delta
		particle["position"] += particle["velocity"] * delta
		particle["velocity"] *= exp(-delta * 5.0)
	particles = particles.filter(func(p: Dictionary) -> bool: return float(p["life"]) > 0.0)
	for ring: Dictionary in rings:
		ring["life"] = float(ring["life"]) - delta
		ring["radius"] = float(ring["radius"]) + delta * 25.0
	rings = rings.filter(func(r: Dictionary) -> bool: return float(r["life"]) > 0.0)
	queue_redraw()

func fire(origin: Vector2, direction: Vector2, power: float, critical: bool) -> void:
	activate()
	play_sound("fire", clampf(0.8 + power / 85.0, 0.8, 1.5))
	if not enabled:
		return
	burst(origin + direction * 5.0, 4, Color("fff0a1"), 28.0)
	add_ring(origin, Color("ffe8a6"), 0.12)
	shake_strength = maxf(shake_strength, 2.2 if critical else 0.3)

func impact(at: Vector2, critical: bool, blocked: bool, killed: bool) -> void:
	play_sound("blocked" if blocked else ("critical" if critical else "impact"), rng.randf_range(0.94, 1.06))
	if not enabled:
		return
	var tint: Color = Color("b7d1e6") if blocked else (Color("ffe17a") if critical else Color("dbe4b5"))
	burst(at, 14 if critical else 8, tint, 62.0 if killed else 42.0)
	if critical:
		add_ring(at, tint, 0.22)
		shake_strength = maxf(shake_strength, 2.2)
		flash_strength = maxf(flash_strength, 0.35)

func damage(at: Vector2, heavy: bool = false) -> void:
	play_sound("damage", 0.8 if heavy else 1.0)
	if not enabled:
		return
	burst(at, 10 if heavy else 5, Color("ff806d"), 40.0)
	shake_strength = maxf(shake_strength, 3.5 if heavy else 1.1)
	flash_strength = maxf(flash_strength, 0.45 if heavy else 0.12)

func snap(at: Vector2) -> void:
	play_sound("snap")
	if not enabled:
		return
	burst(at, 12, Color("e0c098"), 50.0)
	shake_strength = maxf(shake_strength, 3.0)
	flash_strength = maxf(flash_strength, 0.6)

func purchase() -> void:
	play_sound("purchase")

func wave_start() -> void:
	activate()
	play_sound("wave_start")

func wave_clear() -> void:
	play_sound("wave_clear")

func over() -> void:
	play_sound("over")
	if enabled:
		shake_strength = maxf(shake_strength, 3.5)
		flash_strength = maxf(flash_strength, 0.5)

func activate() -> void:
	activated = true
	if audio_enabled and is_instance_valid(music) and not music.playing:
		music.play()

func play_sound(key: String, pitch: float = 1.0) -> void:
	if not audio_enabled or not activated or players.is_empty() or not sounds.has(key):
		return
	var player: AudioStreamPlayer = players[sound_index % players.size()]
	sound_index += 1
	player.stop()
	player.stream = sounds[key]
	player.pitch_scale = pitch
	player.play()

func burst(at: Vector2, count: int, tint: Color, speed: float) -> void:
	for index: int in range(mini(count, maxi(0, 80 - particles.size()))):
		var life: float = rng.randf_range(0.18, 0.38)
		particles.append({"position": at, "velocity": Vector2.from_angle(rng.randf_range(0, TAU)) * rng.randf_range(speed * 0.3, speed), "life": life, "max_life": life, "color": tint, "size": 2.0 if index % 3 == 0 else 1.0})

func add_ring(at: Vector2, tint: Color, life: float) -> void:
	if rings.size() < 8:
		rings.append({"position": at, "radius": 2.0, "life": life, "max_life": life, "color": tint})

func _draw() -> void:
	if not enabled:
		return
	for particle: Dictionary in particles:
		var tint: Color = particle["color"]
		tint.a = clampf(float(particle["life"]) / float(particle["max_life"]), 0.0, 1.0)
		draw_rect(Rect2(particle["position"], Vector2.ONE * float(particle["size"])), tint)
	for ring: Dictionary in rings:
		var tint: Color = ring["color"]
		tint.a = clampf(float(ring["life"]) / float(ring["max_life"]), 0.0, 1.0)
		draw_arc(ring["position"], float(ring["radius"]), 0.0, TAU, 16, tint, 1.0)
