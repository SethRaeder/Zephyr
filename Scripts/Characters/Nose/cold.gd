extends Node
class_name Cold

@export var tickle_strength : CustomBoundedValue = preload("res://resources/bounded_values/colds/cold_tickle.tres")
@export var burn_strength : CustomBoundedValue = preload("res://resources/bounded_values/colds/cold_burn.tres")
@export var sensitivity_strength : CustomBoundedValue = preload("res://resources/bounded_values/colds/cold_sensitivity.tres")

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
		if tickle_strength.current_value > 0:
			nose.add_tickle(tickle_strength.current_value * delta, TickleComponent.DAMAGE_TYPES.TICKLE, null)
		if burn_strength.current_value > 0:
			nose.add_tickle(burn_strength.current_value * delta, TickleComponent.DAMAGE_TYPES.BURN, null)
		if sensitivity_strength.current_value > 0:
			nose.add_tickle(sensitivity_strength.current_value * delta, TickleComponent.DAMAGE_TYPES.SENSITIVITY, null)

func send_sliders(container : SliderBarContainer):
	container.add_new_header(name + " Settings")
	container.add_new_slider(tickle_strength)
	container.add_new_slider(burn_strength)
	container.add_new_slider(sensitivity_strength)
