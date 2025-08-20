extends Parallax2D
class_name ParallaxMouseMove

@export var char_node : Node2D
var _char_pos : Vector2

func _ready():
	if char_node:
		_char_pos = char_node.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var screenDimensions := get_viewport_rect()
	var mouse_pos = get_global_mouse_position()
	mouse_pos = mouse_pos.clamp(Vector2.ZERO, screenDimensions.size)
	var desired_pos = (screenDimensions.get_center() - mouse_pos) / screenDimensions.size * scroll_scale
	scroll_offset = lerp(scroll_offset, desired_pos, delta * 2.0)
	if char_node:
		char_node.position = _char_pos + scroll_offset
