class_name DestroyDefinition
extends MissionDefinition
## Marked vehicles placed on acceptance. Any attributed destruction counts: guns, rams, barrels, chains.
@export var target_vehicle: VehicleData
@export var target_positions: Array[Vector2] = [Vector2(4040, 2330), Vector2(3440, 3060)]
@export var target_rotations: PackedFloat32Array = [1.5708, 0.0]
## Index of the target that bolts for the district edge when spooked; -1 = all stay parked.
@export var runner_index: int = 1
@export var spook_radius: float = 380.0
## Road points at the district edge; a runner that reaches one has escaped permanently.
@export var exit_points: Array[Vector2] = [Vector2(250, 3000), Vector2(4550, 3000), Vector2(2400, 3350)]
@export var escape_distance: float = 140.0
## After the last target, leave this radius around the targets' centroid; 0 = complete immediately.
@export var leave_radius: float = 650.0
@export var chain_bonus: int = 600
@export var multi_window: float = 5.0
@export var multi_bonus: int = 400
