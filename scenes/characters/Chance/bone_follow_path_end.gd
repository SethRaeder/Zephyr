@tool
extends Node2D

@export var target_path : Path2D
@export var offset : Vector2

@export var look_at_mark : Marker2D

func _process(_delta: float) -> void:
	if target_path:
		var all_points : PackedVector2Array = target_path.curve.get_baked_points()
		global_position = target_path.global_position + ((all_points[all_points.size()-1] + offset) * global_scale) 
	if look_at:
		look_at(look_at_mark.global_position)
