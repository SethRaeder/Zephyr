extends Control


var toggled := false
@onready var toggle_button: Button = $HBoxContainer/Toggle
@export var tool_spawn_node : Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if toggled:
		position.x = lerpf(position.x,-100,delta*30.0)
	else:
		position.x = lerpf(position.x,0,delta*30.0)



func _on_toggle_toggled(toggled_on: bool) -> void:
	toggled = toggled_on
	if toggled:
		toggle_button.text = ">>"
	else:
		toggle_button.text = "<<"
