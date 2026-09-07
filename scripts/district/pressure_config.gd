class_name PressureConfig
extends Resource
## Human-tunable B.5 balance; weapon magazine capacity remains WeaponData truth.
@export var search_radii: PackedFloat32Array = [0, 380, 720, 1150, 1700]
@export var search_durations: PackedFloat32Array = [0, 6, 10, 15, 20]
@export var police_budgets: PackedInt32Array = [2, 3, 8, 14, 22]
@export var reinforcement_delays: PackedFloat32Array = [5, 5, 3, 2, 1.5]
# Weighted cycles: repeated entries encode approximate proportions.
@export var roles_by_heat: Array[String] = ["search", "search", "pursuer,pursuer,search", "pursuer,interceptor,search,containment,pursuer", "pursuer,interceptor,search,containment,tactical,pursuer,search,containment"]
@export var speed_range := Vector2(195, 225)
@export var reaction_range := Vector2(0.5, 0.85)
@export var engagement_range := Vector2(280, 350)
@export var shot_discipline_range := Vector2(1.7, 2.1)
@export var npc_magazine_fraction: float = 1.0
@export var coordinator_interval: float = 1.2
@export var prediction_seconds: float = 1.3
@export var prediction_limit: float = 500
@export var vehicle_heat: int = 3
@export var vehicle_cap: int = 2
@export var vehicle_delay: float = 12
@export var roadblock_heat: int = 4
@export var roadblock_clear_heat: int = 1
@export var drop_min_age: float = 180
@export var drop_safe_distance: float = 1800
@export var drop_soft_cap: int = 64
@export var barrel_health: float = 8
@export var barrel_radius: float = 220
@export var barrel_lethal_radius: float = 65
@export var barrel_damage: float = 150
@export var barrel_force: float = 1250
@export var barrel_fuse: float = 0.65
@export var chain_delay_range := Vector2(0.1, 0.35)
@export var boost_reward: int = 2500
@export var boost_notoriety: int = 1
