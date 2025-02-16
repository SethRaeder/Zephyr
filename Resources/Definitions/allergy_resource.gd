extends Resource
class_name AllergyResource

@export var allergy_name : String = "Allergen"
@export var max_count : float = 100.0
@export var tickle_amount_max : float = 10.0
@export var burn_amount_max : float = 10.0
@export var tickle_curve : Curve
@export var burn_curve : Curve

func does_tickle() -> bool:
	return tickle_amount_max > 0
	
func does_burn() -> bool:
	return burn_amount_max > 0

##Return the raw tickle  value depending on the progress percent, and a particle percent.
func sample_tickle(in_percent : float,  particle_percent : float) -> float:
	if tickle_curve != null:
		return tickle_curve.sample(in_percent) * tickle_amount_max * particle_percent
	return tickle_amount_max * particle_percent

##Return the raw burn value depending on the progress percent, and a particle percent.
func sample_burn(in_percent : float, particle_percent : float) -> float:	
	if burn_curve != null:
		return burn_curve.sample(in_percent) * burn_amount_max * particle_percent
	return burn_amount_max * particle_percent
