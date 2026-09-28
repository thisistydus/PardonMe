class_name DistrictScore
extends Node
## The one authoritative run-cash interface. C1 has no spending, so cash held equals cash earned.
signal changed
signal cash_added(amount: int, source: StringName)
const TUNING: RunTuning = preload("res://data/run_tuning.tres")
var money: int = 0
var notoriety: int = 1
var missions: int = 0
var cash_by_source: Dictionary[StringName, int] = {}
var rejected_awards: int = 0

func live_score() -> int:
	return money * notoriety

## Every cash source (street pickups, mission payouts, bonuses) enters here exactly once.
func add_cash(amount: int, source: StringName) -> bool:
	if amount <= 0:
		# Zero/negative awards are refused and counted rather than silently altering the score.
		rejected_awards += 1
		return false
	money += amount
	cash_by_source[source] = cash_by_source.get(source, 0) + amount
	cash_added.emit(amount, source)
	changed.emit()
	return true

func add_notoriety(tiers: int) -> void:
	notoriety = clampi(notoriety + tiers, 1, TUNING.notoriety_cap)
	changed.emit()

func award_mission(definition: MissionDefinition, bonus_cash: int, bonus_labels: Array[String]) -> void:
	add_cash(definition.cash_reward, &"mission")
	if bonus_cash > 0:
		add_cash(bonus_cash, &"bonus")
	add_notoriety(definition.notoriety_reward)
	missions += 1
	Events.sound_requested.emit(&"reward")
	var extra := (" / BONUS " + ", ".join(bonus_labels) + " +$%d" % bonus_cash) if bonus_cash > 0 else ""
	Events.message_requested.emit("%s DONE / +$%d%s / NOTORIETY ×%d / SCORE %d" % [definition.kind_label, definition.cash_reward, extra, notoriety, live_score()])

## Final-score arithmetic shown line by line on the results screen.
## Base = cash × notoriety (notoriety is never below ×1). Zero cash yields a zero score.
## Surviving to dawn adds dawn_bonus_fraction of the base, rounded down.
func breakdown(survived: bool) -> Dictionary:
	var tier := maxi(1, notoriety)
	var base := maxi(0, money) * tier
	var bonus := int(floor(base * TUNING.dawn_bonus_fraction)) if survived else 0
	return {"cash": money, "notoriety": tier, "base": base, "dawn_bonus": bonus, "final": base + bonus}
