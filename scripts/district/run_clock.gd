class_name RunClock
extends Node
## Central fictional time for one run. Physics-stepped so pause, death and tests agree.
signal run_started
signal minute_changed(minute_of_day: int)
signal hour_reached(hour: int)
signal period_changed(period: String)
signal final_warning
signal dawn
const MINUTES_PER_DAY: float = 1440.0
var tuning: RunTuning
var run: ToyRunManager
var elapsed: float = 0.0
var started: bool = false
var warned: bool = false
var finished: bool = false
var last_minute: int = -1
var last_hour: int = -1
var period: String = ""

func _physics_process(delta: float) -> void:
	if finished or run.ended:
		return
	if not started:
		started = true
		run_started.emit()
		publish()
	elapsed = minf(elapsed + delta, tuning.run_seconds)
	publish()
	if not warned and remaining() <= tuning.final_warning_seconds:
		warned = true
		final_warning.emit()
	if elapsed >= tuning.run_seconds:
		finished = true
		dawn.emit()

func publish() -> void:
	var minute := minute_of_day()
	if minute == last_minute:
		return
	last_minute = minute
	minute_changed.emit(minute)
	var current_hour := minute / 60
	if current_hour != last_hour:
		# The opening hour is reported by run_started, not as a crossed threshold.
		if last_hour != -1:
			hour_reached.emit(current_hour)
		last_hour = current_hour
	var current := period_name()
	if current != period:
		period = current
		period_changed.emit(period)

func progress() -> float:
	return clampf(elapsed / maxf(tuning.run_seconds, 0.001), 0.0, 1.0)

func remaining() -> float:
	return maxf(0.0, tuning.run_seconds - elapsed)

## Fictional minutes since this run's opening dawn, 0–1440.
func day_minutes() -> float:
	return progress() * MINUTES_PER_DAY

func minute_of_day() -> int:
	return int(tuning.dawn_hour * 60.0 + day_minutes()) % int(MINUTES_PER_DAY)

func hour() -> int:
	return minute_of_day() / 60

func time_text() -> String:
	var minute := minute_of_day()
	return "%02d:%02d" % [minute / 60, minute % 60]

## Inclusive-exclusive window on the 24-hour dial; wraps past midnight. 0→24 is always open.
func is_within(from_hour: float, until_hour: float) -> bool:
	if until_hour - from_hour >= 24.0:
		return true
	var now := minute_of_day() / 60.0
	if from_hour <= until_hour:
		return now >= from_hour and now < until_hour
	return now >= from_hour or now < until_hour

func period_name() -> String:
	var now := hour()
	var chosen: String = tuning.period_names[tuning.period_names.size() - 1]
	var best := -1
	for i: int in tuning.period_start_hours.size():
		# Hours before dawn belong to the previous evening's final period.
		var start: int = tuning.period_start_hours[i]
		var shifted := (now - int(tuning.dawn_hour) + 24) % 24
		var start_shifted := (start - int(tuning.dawn_hour) + 24) % 24
		if start_shifted <= shifted and start_shifted > best:
			best = start_shifted
			chosen = tuning.period_names[i]
	return chosen
