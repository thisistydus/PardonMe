class_name ToyFeedback
extends Node2D

var particles: Array[Dictionary] = []
var sounds: Dictionary[StringName, AudioStreamWAV] = {}
var voices: Array[AudioStreamPlayer] = []
var voice_index: int = 0
var freeze_remaining: float = 0.0
var shake: float = 0.0
var shake_enabled: bool = true
var camera: Camera2D
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 15
	rng.seed = 8347
	Events.shutdown_requested.connect(stop_audio)
	Events.impact.connect(on_impact)
	Events.sound_requested.connect(play_sound)
	for kind: StringName in [&"swing", &"bat_hit", &"punch", &"pistol", &"enemy_shot", &"empty", &"wounded", &"death", &"crash", &"enter", &"throw_hit", &"explosion", &"warning", &"police_alert", &"heat", &"search", &"escaped", &"mission", &"reward"]:
		sounds[kind] = make_sound(kind)
	for i: int in 12:
		var voice := AudioStreamPlayer.new()
		voice.volume_db = -13.0
		add_child(voice)
		voices.append(voice)

func make_sound(kind: StringName) -> AudioStreamWAV:
	var length: float = 0.18
	var frequency: float = 100.0
	var noise: float = 0.4
	match kind:
		&"bat_hit": frequency = 72; length = 0.24; noise = 0.7
		&"punch": frequency = 100; length = 0.15; noise = 0.45
		&"swing": frequency = 400; length = 0.12; noise = 0.9
		&"pistol", &"enemy_shot": frequency = 58; length = 0.22; noise = 0.85
		&"empty": frequency = 850; length = 0.04; noise = 0.2
		&"wounded": frequency = 210; length = 0.4; noise = 0.25
		&"death": frequency = 70; length = 0.6; noise = 0.35
		&"crash": frequency = 45; length = 0.4; noise = 0.85
		&"enter": frequency = 160; length = 0.09; noise = 0.4
		&"throw_hit": frequency = 350; length = 0.16; noise = 0.65
		&"explosion": frequency = 38; length = 0.85; noise = 0.78
		&"police_alert", &"heat": frequency = 660; length = 0.28; noise = 0.04
		&"search": frequency = 350; length = 0.3; noise = 0.05
		&"escaped", &"reward": frequency = 1100; length = 0.4; noise = 0.02
		&"mission": frequency = 740; length = 0.2; noise = 0.04
		&"warning": frequency = 920; length = 0.11; noise = 0.04
	var count := int(22050 * length)
	var bytes := PackedByteArray()
	bytes.resize(count * 2)
	var phase: float = 0.0
	for i: int in count:
		var progress := float(i) / count
		phase += TAU * frequency * (1.0 - progress * 0.7) / 22050.0
		var sample := (sin(phase) * (1.0 - noise) + rng.randf_range(-1, 1) * noise) * pow(1.0 - progress, 3.0)
		bytes.encode_s16(i * 2, int(sample * 28000))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	stream.data = bytes
	return stream

func play_sound(kind: StringName) -> void:
	if not sounds.has(kind):
		push_error("Unknown feedback sound: " + String(kind))
		return
	var voice := voices[voice_index]
	voice_index = (voice_index + 1) % voices.size()
	voice.stream = sounds[kind]
	voice.pitch_scale = rng.randf_range(0.94, 1.05)
	voice.play()

func on_impact(at: Vector2, direction: Vector2, strength: float) -> void:
	shake = maxf(shake, strength * 5.0)
	if strength >= 0.5:
		freeze_remaining = maxf(freeze_remaining, 0.045 if strength >= 1.0 else 0.025)
		Engine.time_scale = 0.06
	for i: int in int(5 + strength * 8):
		particles.append({"p": at, "v": direction.rotated(rng.randf_range(-1.5, 1.5)) * rng.randf_range(80, 330), "life": rng.randf_range(0.12, 0.32)})

func _process(delta: float) -> void:
	var real_delta := delta / maxf(Engine.time_scale, 0.01)
	if freeze_remaining > 0:
		freeze_remaining -= real_delta
		if freeze_remaining <= 0:
			Engine.time_scale = 1.0
	if get_tree().paused:
		return
	for i: int in range(particles.size() - 1, -1, -1):
		particles[i].life -= delta
		particles[i].p += particles[i].v * delta
		if particles[i].life <= 0:
			particles.remove_at(i)
	shake = move_toward(shake, 0, real_delta * 30)
	if camera:
		camera.offset = Vector2(rng.randf_range(-shake, shake), rng.randf_range(-shake, shake)) if shake_enabled else Vector2.ZERO
	queue_redraw()

func _draw() -> void:
	for particle: Dictionary in particles:
		draw_line(particle.p, particle.p - particle.v * 0.025, Color("edd29a"), 3, true)

func _exit_tree() -> void:
	Engine.time_scale = 1.0

func stop_audio() -> void:
	for voice: AudioStreamPlayer in voices:
		voice.stop()
		voice.stream = null
