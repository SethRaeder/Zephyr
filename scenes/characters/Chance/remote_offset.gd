@tool
extends Node2D
@export var target : Node2D
@export var offset : Vector2
@export_range(-1.0,1.0,0.01) var rotation_influence : float

func _process(_delta: float) -> void:
	if target:
		global_position = target.global_position + offset.rotated(target.rotation * rotation_influence)
