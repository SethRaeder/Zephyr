extends Node
class_name FadeParticleSprite

@export var root_node : Node

var tickle_components = []
var max_value = 0
var parent_modulate : Color
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent_modulate = get_parent().modulate
	
	for child in root_node.get_children(true):
		if child is TickleComponent:
			if child.tickle_damage_limit > 0:
				tickle_components.append(child)
				max_value += child.tickle_damage_limit

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var current_value = 0
	for child : TickleComponent in tickle_components:
		current_value += child.total_tickle_damage
	
	#print(" Fade Sprite : ",current_value / max_value)
	get_parent().modulate = parent_modulate.lerp(Color.TRANSPARENT, current_value / max_value)
