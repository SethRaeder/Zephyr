extends Node
class_name Cold

@export var tickle_curve : Curve
@export var burn_curve : Curve
@export var sensitivity_curve : Curve

var _progression : CustomBoundedValue
var _nose_array : Array[NoseTriggerZone]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_progression = CustomBoundedValue.new()
	_progression.name = "Cold Progression"
	
	add_to_group("has_sliders")
	
	var all_noses = get_tree().get_nodes_in_group("nose")
	for nose in all_noses:
		if nose is NoseTriggerZone:
			_nose_array.append(nose)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var tickle_strength = tickle_curve.sample_baked(_progression.get_percent())
	var burn_strength = burn_curve.sample_baked(_progression.get_percent())
	var sensitivity_strength = sensitivity_curve.sample_baked(_progression.get_percent())
	for nose in _nose_array:
		if tickle_strength > 0:
			nose.add_tickle(tickle_strength * delta, TickleComponent.DAMAGE_TYPES.TICKLE, null)
		if burn_strength > 0:
			nose.add_tickle(burn_strength * delta, TickleComponent.DAMAGE_TYPES.BURN, null)
		if sensitivity_strength > 0:
			nose.add_tickle(sensitivity_strength * delta, TickleComponent.DAMAGE_TYPES.SENSITIVITY, null)

func send_sliders(container : DebugUIContainer):
	container.add_new_header(name + " Settings", "Settings and data for cold")
	container.add_new_slider(_progression, "Strength of cold for this character.")
