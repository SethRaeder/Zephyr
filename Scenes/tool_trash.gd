extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("body_entered",destroy_tool)


func destroy_tool(body):
	if body is SneezeTool:
		body.queue_free()
