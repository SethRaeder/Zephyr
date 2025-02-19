extends Parallax2D
class_name ParallaxMouseMove

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var screenDimensions = Vector2(get_viewport().size)
	var mouse_pos = get_global_mouse_position()
	mouse_pos = mouse_pos.clamp(Vector2.ZERO, screenDimensions)
	var desired_pos = (mouse_pos + (screenDimensions/2)) / screenDimensions * scroll_scale
	scroll_offset = lerp(scroll_offset, desired_pos, delta * 2.0)
