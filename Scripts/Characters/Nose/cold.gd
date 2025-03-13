extends Node
class_name Cold

@export var tickle_strength : CustomBoundedValue
@export var burn_strength : CustomBoundedValue
@export var sensitivity_strength : CustomBoundedValue

var nose_array : Array[NoseTriggerZone]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("has_sliders")
	
	var all_noses = get_tree().get_nodes_in_group("nose")
	for nose in all_noses:
		if nose is NoseTriggerZone:
			nose_array.append(nose)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for nose in nose_array:
		nose.add_tickle(tickle_strength.current_value * delta, TickleComponent.DAMAGE_TYPES.TICKLE, null)
		nose.add_tickle(burn_strength.current_value * delta, TickleComponent.DAMAGE_TYPES.BURN, null)
		nose.add_tickle(sensitivity_strength.current_value * delta, TickleComponent.DAMAGE_TYPES.SENSITIVITY, null)

func send_sliders(container : SliderBarContainer):
	container.add_new_header(name + " Settings")
	container.add_new_slider(tickle_strength)
	container.add_new_slider(burn_strength)
	container.add_new_slider(sensitivity_strength)
