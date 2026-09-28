class_name CashConfig
extends Resource
## Street-cash tuning. Deliberately small next to mission payouts ($1,800–$3,200 + bonuses).
@export var civilian_chance: float = 0.55
@export var civilian_range := Vector2i(15, 60)
@export var police_chance: float = 0.35
@export var police_range := Vector2i(25, 70)
## Armed hostiles, including robbery guards, carry the float.
@export var hostile_chance: float = 1.0
@export var hostile_range := Vector2i(120, 220)
## Deaths not attributed to the player (police crossfire, AI cruisers) drop nothing.
@export var requires_player_kill: bool = true
@export var lifetime: float = 90.0
@export var soft_cap: int = 40
@export var collect_radius: float = 34.0
@export var vehicle_collect_radius: float = 64.0

func chance_for(role: String) -> float:
	match role:
		"police": return police_chance
		"hostile": return hostile_chance
	return civilian_chance

func range_for(role: String) -> Vector2i:
	match role:
		"police": return police_range
		"hostile": return hostile_range
	return civilian_range
