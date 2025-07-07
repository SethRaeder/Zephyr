extends CheckButton

func _ready() -> void:
	get_tree().connect("node_added",on_node_added)
	notify_all(button_pressed)
	
func _on_toggled(toggled_on: bool) -> void:
	print("toggled debug ",toggled_on)
	notify_all(toggled_on)

func notify_all(toggled_on : bool):
	get_tree().call_group("character_debug", "show" if toggled_on else "hide")
	get_tree().call_group("tool_debug", "show" if toggled_on else "hide")
	
func on_node_added(node : Node):
	if node.is_in_group("character_debug") or node.is_in_group("tool_debug"):
		if not button_pressed:
			node.hide()
