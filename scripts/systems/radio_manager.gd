class_name ToyRadioManager
extends Node
## One audible stream; stations keep virtual broadcast positions while unselected.
signal station_changed(station: RadioStationData)
signal availability_changed(in_vehicle: bool)
const LIBRARY: RadioLibrary = preload("res://data/radio/library.tres")
const OFF: int = 4
var vehicle: ToyCompact
var selected: int = OFF
var broadcast_time: float = 0.0
var offsets: PackedFloat64Array = []
var audio: AudioStreamPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for station: RadioStationData in LIBRARY.stations:
		assert(station.audio != null and station.audio.get_length() > 2.0, "Invalid radio audio: " + station.title)
		offsets.append(rng.randf_range(1.0, station.audio.get_length() - 1.0))
	audio = AudioStreamPlayer.new()
	audio.name = "RadioPlayback"
	audio.volume_db = -12.0
	add_child(audio)
	Events.shutdown_requested.connect(release_audio)
	Events.vehicle_entered.connect(on_enter)
	Events.vehicle_exited.connect(on_exit)
	Events.vehicle_destroyed.connect(on_exit)
	Events.player_died.connect(stop_radio)

func _process(delta: float) -> void:
	audio.stream_paused = get_tree().paused
	if not get_tree().paused:
		broadcast_time += delta / maxf(Engine.time_scale, 0.01)

func _unhandled_input(event: InputEvent) -> void:
	if vehicle == null or get_tree().paused or event.is_echo():
		return
	for i: int in 5:
		if event.is_action_pressed("radio_%d" % (i + 1)):
			select_station(i)
			get_viewport().set_input_as_handled()
			return
	if event.is_action_pressed("radio_next"):
		select_station((selected + 1) % 5)

func station_position(index: int) -> float:
	return fposmod(offsets[index] + broadcast_time, LIBRARY.stations[index].audio.get_length())

func on_enter(car: ToyCompact) -> void:
	vehicle = car
	availability_changed.emit(true)
	select_station(car.radio_station, true)

func on_exit(car: ToyCompact) -> void:
	if vehicle == car:
		stop_radio()

func stop_radio() -> void:
	audio.stop()
	vehicle = null
	selected = OFF
	availability_changed.emit(false)
	station_changed.emit(null)

func select_station(index: int, force: bool = false) -> void:
	if vehicle == null or index < 0 or index > OFF:
		return
	if selected == index and not force:
		return
	selected = index
	vehicle.radio_station = index
	audio.stop()
	if index == OFF:
		audio.stream = null
		station_changed.emit(null)
		return
	var station := LIBRARY.stations[index]
	var stream := station.audio.duplicate() as AudioStreamOggVorbis
	stream.loop = true
	audio.stream = stream
	audio.play(station_position(index))
	station_changed.emit(station)

func _exit_tree() -> void:
	release_audio()

func release_audio() -> void:
	# Release the active decoder before scene shutdown/restart.
	if is_instance_valid(audio):
		audio.stop()
		audio.stream = null
