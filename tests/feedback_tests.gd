extends SceneTree

const FeedbackScript = preload("res://scripts/effects/feedback_controller.gd")
var checks: int = 0
var failures: int = 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + description)

func run() -> void:
	var fx: Node2D = FeedbackScript.new()
	root.add_child(fx)
	fx.setup()
	fx.setup()
	check(fx.players.size() == 8 and fx.get_child_count() == 9, "Setup is idempotent and audio voices bounded")
	check(not fx.music.playing and not fx.activated, "Setup never autoplays music")
	for player: AudioStreamPlayer in fx.players:
		check(not player.playing, "No effect voice before gesture")
	check(fx.sounds.size() == 10 and fx.music.stream != null, "All prerecorded PCM resources load")
	check(is_equal_approx(fx.music.stream.get_length(), 20.0), "Loop track lasts 20 seconds")
	check(fx.music.stream.loop_mode == AudioStreamWAV.LOOP_FORWARD, "Music has explicit loop playback")
	fx.audio_enabled = false
	fx.fire(Vector2.ZERO, Vector2.RIGHT, 34.0, true)
	check(fx.activated and not fx.music.playing, "Muted gesture does not start sound")
	for index: int in range(100):
		fx.impact(Vector2(index, 0), true, false, true)
	check(fx.particles.size() == 80 and fx.rings.size() <= 8, "Impact storm has fixed particle and ring limits")
	check(fx.shake_strength <= 4.0 and fx.flash_strength <= 1.0, "Feedback amplitude stays bounded")
	fx.tick(1.0)
	check(fx.particles.is_empty() and fx.rings.is_empty() and fx.shake_strength == 0.0 and fx.flash_strength == 0.0, "Transient feedback expires without node leakage")
	fx.snap(Vector2.ZERO)
	check(not fx.particles.is_empty() and fx.shake_strength > 0.0, "Snap produces short visual feedback")
	fx.enabled = false
	check(fx.particles.is_empty() and fx.rings.is_empty() and fx.shake_strength == 0.0 and fx.flash_strength == 0.0, "Disabling visuals clears effects immediately")
	fx.impact(Vector2.ZERO, true, false, true)
	fx.damage(Vector2.ZERO, true)
	fx.snap(Vector2.ZERO)
	fx.over()
	check(fx.particles.is_empty() and fx.shake_strength == 0.0 and fx.flash_strength == 0.0, "Disabled visuals cannot accumulate hidden feedback")
	fx.audio_enabled = true
	check(fx.music.playing and not fx.enabled, "Audio can play independently with visuals disabled")
	for index: int in range(20):
		fx.purchase()
	check(fx.players.size() == 8 and fx.get_child_count() == 9, "Repeated audio cues reuse fixed voice pool")
	fx.audio_enabled = false
	check(not fx.music.playing, "Mute stops music")
	for player: AudioStreamPlayer in fx.players:
		check(not player.playing, "Mute stops effect voices")
	var shader: Shader = load("res://scripts/effects/chromatic.gdshader")
	check(shader != null and shader.code.contains("SCREEN_PIXEL_SIZE"), "Bounded chromatic shader resource loads")
	# Let the audio mixing thread retire stopped stream playbacks before exit.
	await create_timer(0.15).timeout
	fx.queue_free()
	await create_timer(0.05).timeout
	print("FEEDBACK TESTS: ", checks, " checks, ", failures, " failures")
	quit(0 if failures == 0 else 1)
