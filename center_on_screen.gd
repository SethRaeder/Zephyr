extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var screenDimensions = Vector2(get_viewport().size)
	position = screenDimensions / 2.0
