extends Parallax2D
class_name ParallaxMouseMove

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var screenDimensions := get_viewport_rect()
	var mouse_pos = get_global_mouse_position()
	mouse_pos = mouse_pos.clamp(Vector2.ZERO, screenDimensions.size)
	var desired_pos = (mouse_pos + screenDimensions.get_center()) / screenDimensions.size * scroll_scale
	scroll_offset = lerp(scroll_offset, desired_pos, delta * 2.0)
