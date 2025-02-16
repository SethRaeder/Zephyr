extends Parallax2D
class_name ParallaxMouseMove

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var screenDimensions = Vector2(get_viewport().size)
	var desired_pos = (get_global_mouse_position() - (screenDimensions/2))/screenDimensions * scroll_scale
	scroll_offset = lerp(scroll_offset, desired_pos, delta * 2.0)
