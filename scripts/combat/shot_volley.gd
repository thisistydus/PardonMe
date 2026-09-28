class_name ShotVolley
extends RefCounted
## One trigger pull. The first pellet to reach a body deals the weapon's damage; the rest are absorbed.
var hits: Dictionary[int, bool] = {}

func claim(body: Object) -> bool:
	var id := body.get_instance_id()
	if hits.has(id):
		return false
	hits[id] = true
	return true
