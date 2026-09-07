class_name ExplosionTracker
extends Node
## One debug feat per attributed chain; no new scoring economy hidden in this pass.
var counts: Dictionary[int, int] = {}
var reported: Dictionary[int, bool] = {}
var feat_count: int = 0
var last_feat: String = ""
func _ready() -> void:
	Events.explosion_detonated.connect(on_explosion)
func on_explosion(token: int, caused: bool) -> void:
	if not caused: return
	counts[token] = counts.get(token, 0) + 1
	if counts[token] >= 3 and not reported.has(token):
		reported[token] = true
		feat_count += 1
		last_feat = "CHAIN REACTION / 3+ objects (debug feat)"
		Events.message_requested.emit(last_feat)
