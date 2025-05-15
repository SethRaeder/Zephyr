extends Node
class_name State

@export var animation_tree : AnimationTree
@export var brain_ref : Brain
@export var nose_refs : Array[NoseTriggerZone] = []

func on_enter(transition_name : String) -> void:
	pass

func on_exit() -> void:
	pass
	
func state_process(delta: float) -> State:
	return null

func state_physics_process(delta: float) -> State:
	return null
