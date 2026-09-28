class_name MissionDefinition
extends Resource
## Shared job data. Template resources (Boost/Rob/Destroy) extend this with their own tuning.
@export var id: StringName = &"job"
@export var title: String = "UNTITLED JOB"
## Short template word shown on phones, the objective card and results.
@export var kind_label: String = "JOB"
## Index into DistrictLayout.phones; that payphone rings with this offer.
@export var phone_index: int = 0
@export var cash_reward: int = 0
@export var notoriety_reward: int = 1
## Seconds after acceptance; 0 means untimed.
@export var time_limit: float = 0.0
## Seconds before a failed job rings again. Completed jobs never repeat in a run.
@export var retry_delay: float = 4.0
## Fictional-hour offer window; 0→24 is the whole day. All C1 jobs use the whole day.
@export var available_from_hour: float = 0.0
@export var available_until_hour: float = 24.0
## Reserved for later faction design. C1 has no factions, standing, UI or behaviour for it.
@export var faction_id: StringName = &""
