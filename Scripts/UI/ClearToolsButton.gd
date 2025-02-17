extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("button_down",delete_all_tools)

func delete_all_tools():
	for node in get_tree().get_nodes_in_group("tool_particles"):
		node.queue_free()
	for node in get_tree().get_nodes_in_group("tools"):
		node.queue_free()
