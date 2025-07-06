extends Button

class_name ToolSpawner
@onready var toolbox: Control = $"../.."

@export var Tool : PackedScene

func _ready() -> void:
	connect("pressed",spawn_tool)

func spawn_tool():
	if Tool:
		if Tool.can_instantiate():
			var new_tool = Tool.instantiate()
			toolbox.tool_spawn_node.add_child(new_tool)
			
