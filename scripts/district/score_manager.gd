class_name DistrictScore
extends Node
signal changed
var money: int = 0
var notoriety: int = 1
var missions: int = 0
func _ready() -> void:
	Events.mission_completed.connect(award)
func live_score() -> int:
	return money * notoriety
func award(reward: int) -> void:
	money += reward
	notoriety = mini(6, notoriety + 1)
	missions += 1
	changed.emit()
	Events.sound_requested.emit(&"reward")
	Events.message_requested.emit("DELIVERED / +$%d / NOTORIETY ×%d / SCORE %d" % [reward, notoriety, live_score()])
