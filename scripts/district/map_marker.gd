class_name DistrictMarker
extends Node
@export var kind: StringName = &"phone"
var active: bool = true
func _ready() -> void:
	add_to_group("map_markers")
func point() -> Vector2:
	return (get_parent() as Node2D).global_position
