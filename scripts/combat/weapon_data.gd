class_name WeaponData
extends Resource

@export var id: StringName = &"fists"
@export var title: String = "FISTS"
@export var damage: int = 1
@export var reach: float = 46.0
@export var arc_degrees: float = 80.0
@export var cooldown: float = 0.24
@export var knockback: float = 230.0
@export var firearm: bool = false
@export var ammunition: int = 0
@export var throw_damage: int = 2
@export var throw_speed: float = 850.0
@export var throw_knockback: float = 420.0

@export var projectile_speed: float = 1050.0
@export var projectile_range: float = 1680.0
@export var shot_sound: StringName = &"pistol"
## Pellets per trigger pull; each target takes `damage` at most once per pull.
@export var pellets: int = 1
@export var spread_degrees: float = 0.0
## Shooter push-back per shot.
@export var recoil: float = 90.0
## Crime report strength and audible radius of one shot.
@export var noise_severity: float = 1.5
@export var noise_radius: float = 700.0
