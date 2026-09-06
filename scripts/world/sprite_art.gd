class_name SpriteArt
extends RefCounted
## Source PNGs are preserved; source regions exclude transparent padding at draw time.
const PLAYER: Texture2D = preload("res://Art/Generated/player_v1.png")
const COMPACT: Texture2D = preload("res://Art/Generated/compact_final.png")
const TARGET: Texture2D = preload("res://Art/Generated/practice_target_final.png")
const PLAYER_REGION := Rect2(232, 231, 838, 762)
const COMPACT_REGION := Rect2(142, 98, 1423, 712)
const TARGET_REGION := Rect2(337, 156, 815, 758)
