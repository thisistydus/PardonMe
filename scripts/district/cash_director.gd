class_name CashDirector
extends Node
## Rolls street-cash drops for NPC deaths and pays collected pickups into DistrictScore.
const CONFIG: CashConfig = preload("res://data/cash_config.tres")
var game: DistrictGame
var rng := RandomNumberGenerator.new()
var pickups: Array[CashPickup] = []
var dropped: int = 0
var collected: int = 0
var expired: int = 0

func _ready() -> void:
	rng.seed = game.run.seed_value * 31 + 7
	Events.npc_killed.connect(on_npc_killed)

func on_npc_killed(npc: Node2D, by_player: bool) -> void:
	if CONFIG.requires_player_kill and not by_player:
		return
	var role: String = npc.get("role")
	if rng.randf() >= CONFIG.chance_for(role):
		return
	var bounds := CONFIG.range_for(role)
	spawn(npc.global_position + Vector2(rng.randf_range(-10, 10), rng.randf_range(-10, 10)), rng.randi_range(bounds.x, bounds.y))

func spawn(at: Vector2, amount: int) -> CashPickup:
	# Oldest drops make room first, so the world never accumulates unbounded pickups.
	while pickups.size() >= CONFIG.soft_cap:
		remove(pickups[0])
		expired += 1
	var pickup := CashPickup.new()
	pickup.amount = amount
	pickup.lifetime = CONFIG.lifetime
	pickup.position = at
	game.add_child(pickup)
	pickups.append(pickup)
	dropped += 1
	return pickup

func remove(pickup: CashPickup) -> void:
	pickups.erase(pickup)
	if is_instance_valid(pickup):
		pickup.remove_from_group("cash_pickups")
		pickup.queue_free()

func _physics_process(_delta: float) -> void:
	var player := game.player
	var reach := CONFIG.vehicle_collect_radius if player.vehicle != null else CONFIG.collect_radius
	for pickup: CashPickup in pickups.duplicate():
		if not is_instance_valid(pickup):
			pickups.erase(pickup)
		elif pickup.age >= pickup.lifetime:
			remove(pickup)
			expired += 1
		elif player.alive and not pickup.collected and player.global_position.distance_to(pickup.global_position) < reach:
			pickup.collected = true
			collected += 1
			game.score.add_cash(pickup.amount, &"street")
			Events.sound_requested.emit(&"cash")
			remove(pickup)
