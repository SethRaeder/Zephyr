extends Node
class_name Cold

@export var tickle_strength : CustomBoundedValue = CustomBoundedValue.new("Tickle Strength", 0, 5, 0)
@export var burn_strength : CustomBoundedValue = CustomBoundedValue.new("Burn Strength", 0, 5, 0)
@export var sensitivity_strength : CustomBoundedValue = CustomBoundedValue.new("Sensitivity Strength", 0, 1, 0)

var nose_parent : NoseTriggerZone

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("has_sliders")
	nose_parent = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	nose_parent.add_tickle(tickle_strength.current_value * delta, TickleComponent.DAMAGE_TYPES.TICKLE, null)
	nose_parent.add_tickle(burn_strength.current_value * delta, TickleComponent.DAMAGE_TYPES.BURN, null)
	nose_parent.add_tickle(sensitivity_strength.current_value * delta, TickleComponent.DAMAGE_TYPES.SENSITIVITY, null)

func send_sliders(container : SliderBarContainer):
	container.add_new_header(name + " Settings")
	container.add_new_slider(tickle_strength)
	container.add_new_slider(burn_strength)
	container.add_new_slider(sensitivity_strength)
