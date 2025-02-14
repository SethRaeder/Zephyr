extends Node2D


var start_position
@export var move_reducer = 100.0

func _ready() -> void:
	start_position = get_parent().position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var offset = (get_global_mouse_position() * -1 / move_reducer)
	get_parent().position = lerp(get_parent().position, start_position + offset, 0.05)
