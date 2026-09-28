class_name RunTuning
extends Resource
## C1 run-loop tuning: real seconds are mapped linearly onto one fictional dawn-to-dawn day.
@export var run_seconds: float = 720.0
@export var dawn_hour: float = 6.0
@export var final_warning_seconds: float = 60.0
## Kickoff Pack §2: surviving to dawn adds this fraction of the base score. 0 disables it.
@export var dawn_bonus_fraction: float = 0.25
@export var notoriety_cap: int = 6
## Label boundaries only; no C1 system changes behaviour by period.
@export var period_start_hours: PackedInt32Array = [6, 12, 18, 22]
@export var period_names: PackedStringArray = ["MORNING", "AFTERNOON", "EVENING", "NIGHT"]
