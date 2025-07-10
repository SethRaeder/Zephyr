extends Node
class_name FadeParticleSprite

@export var root_node : ToolParticle

var tickle_components : Array[TickleComponent] = []
var max_value : float= 0
var parent_modulate : Color
var parent_scale : Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent_modulate = get_parent().modulate
	parent_scale = get_parent().scale
	
	for child in root_node.get_children(true):
		if child is TickleComponent:
			if child.tickle_damage_limit > 0:
				tickle_components.append(child)
				max_value += child.tickle_damage_limit

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var current_value : float = 0
	for child : TickleComponent in tickle_components:
		current_value += child.total_tickle_damage
	
	var damage_factor : float = current_value / max_value
	#print(" Fade Sprite : ",current_value / max_value)
	var lifetime_factor : float = root_node.lifetime / root_node.particle_lifetime
	
	get_parent().modulate = parent_modulate.lerp(Color.TRANSPARENT, max(lifetime_factor, damage_factor))
	get_parent().scale = parent_scale.lerp(parent_scale * 0.1, max(lifetime_factor, damage_factor))
