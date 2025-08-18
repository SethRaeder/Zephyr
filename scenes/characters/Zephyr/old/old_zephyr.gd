extends Node2D
class_name SneezeCharacter

@export var lungs : Node
@export var nose : Node

func _process(delta: float) -> void:
	var roll = randf_range(0.0,100.0)
	if roll > 96:
		%AnimationTree.set("parameters/expression_transition/transition_request","tickle_hitch")
	elif roll < 4:
		%AnimationTree.set("parameters/expression_transition/transition_request","idle")
	
