extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = get_viewport_rect().get_center()
