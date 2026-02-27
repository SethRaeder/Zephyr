@tool
extends Entity
class_name Character

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		self.position = get_window().get_mouse_position()
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		self.call("look_at",get_window().get_mouse_position())
