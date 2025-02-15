extends Node
class_name AllergenDetector

@export var allergen : AllergyResource
@export var max_value : float = 100
@export var decay_time_seconds : float = 60
@export var effect_curve : Curve

var decay_rate = -max_value / decay_time_seconds
var accumulator := CustomBoundedValue.new("Allergy Value", 0.0, max_value, 0.0)

var nose : NoseTriggerZone
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	nose = get_parent()
	nose.on_allergy_damage.connect(on_allergy_damage)

func on_allergy_damage(damage_amount : float, allergy_type : AllergyResource):
	#print("Detecting allergy damage")
	if allergy_type.allergy_name == allergen.allergy_name:
		accumulator.add_value(damage_amount)
		print("Allergy Detector : ",allergen.allergy_name,", ",damage_amount,", ",accumulator.get_percent())

func _process(delta: float) -> void:
	accumulator.add_value(delta * decay_rate)
	
	var effect = effect_curve.sample(accumulator.get_percent())
	if effect > 0:
		nose.add_tickle(allergen.tickle_amount * effect, TickleComponent.DAMAGE_TYPES.TICKLE, null)
		nose.add_tickle(allergen.burn_amount * effect, TickleComponent.DAMAGE_TYPES.BURN, null)
