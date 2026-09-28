class_name RobDefinition
extends MissionDefinition
## Storefront hold-up staged at an exterior trigger; no interior.
@export var store_position := Vector2(2800, 915)
## Arriving this close (on foot or driving) trips the alarm and brings the guards out.
@export var alarm_radius: float = 230.0
## The player must stand inside this radius on foot while the register is emptied.
@export var zone_radius: float = 95.0
@export var hold_seconds: float = 3.0
## Progress lost per second while outside the zone.
@export var hold_decay: float = 0.5
@export var guard_positions: Array[Vector2] = [Vector2(2640, 905), Vector2(2965, 905)]
@export var alarm_severity: float = 2.0
@export var alarm_audible_radius: float = 450.0
@export var pickup_radius: float = 34.0
## Escape = this far from the store AND police no longer holding a positive identification.
@export var escape_radius: float = 950.0
@export var low_heat_threshold: int = 1
@export var low_heat_bonus: int = 750
@export var quick_seconds: float = 100.0
@export var quick_bonus: int = 500
