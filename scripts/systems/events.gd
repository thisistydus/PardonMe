extends Node
## Cross-system presentation events. No score or Heat simulation in Goal A.
signal impact(at: Vector2, direction: Vector2, strength: float)
signal sound_requested(kind: StringName)
signal message_requested(text: String)
signal player_died
signal target_downed
signal vehicle_entered(vehicle: Node2D)
signal vehicle_exited(vehicle: Node2D)
signal vehicle_destroyed(vehicle: Node2D)

signal phone_answered(phone: Node2D)
signal crime(kind: StringName, at: Vector2, severity: float, audible_radius: float, player_caused: bool)

signal mission_completed(reward: int)

signal shutdown_requested
