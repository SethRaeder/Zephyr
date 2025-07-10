extends Node
class_name AllergenDetector

@export_category("Node References")
##Connect here to hook into sneeze signals to expel particles.
@export var brain : Brain

@export_category("Allergen Settings")
##Allergy Resource this detector should track
@export var allergen : AllergyResource
##Effect of this allergen on tickle from overall progress. Domain is the number of seconds, value is the amount to send as damage to nose.
@export var progress_tickle_curve : Curve
##Effect of this allergen on burn from overall progress. Domain is the number of seconds, value is the amount to send as damage to nose.
@export var progress_burn_curve : Curve
##Effect of this allergen on sensitivity from overall progress. Domain is the number of seconds, value is the amount to send as damage to nose.
@export var progress_sensitivity_curve : Curve
##How long should it take this allergen to reset to idle state, after all particles are cleared from nose?
@export var allergen_time_decay_seconds : float = 60.0
##How many seconds of allergy decay should be fast-forwarded on sneeze? Assumes sneeze size 1.0
@export var allergen_decay_sneeze_seconds : float = 0.0

@export_category("Particles")
##Domain represents number of particles. Value represents how much progress to add, each second.
@export var particle_count_time_effect : Curve = preload("res://resources/curves/default_particle_count_time_effect.tres")
##How many seconds should it take for all particles to be removed from nose, from max count? Used to compute idle decay rate.
@export var particle_decay_seconds : float = 60.0
##How many seconds of particle decay should be fast-forwarded on sneeze? Assumes sneeze size 1.0
@export var particle_decay_sneeze_seconds : float = 10.0

##Effect of this allergen on tickle. Domain should remain 0 - 1, value is the amount to send as damage to nose.
@export var particle_tickle_curve : Curve
##Modifier on tickle depending on progress time. Domain should remain 0 - 1. Value is modifier on particle tickle depending on progress
@export var particle_tickle_mod_curve : Curve
##Effect of this allergen on burn over time. Domain should remain 0 - 1, value is the amount to send as damage to nose.
@export var particle_burn_curve : Curve
##Modifier on burn depending on progress time. Domain should remain 0 - 1. Value is modifier on particle tickle depending on progress
@export var particle_burn_mod_curve : Curve
##Effect of this allergen on sensitivity over time. Domain should remain 0 - 1, value is the amount to send as damage to nose.
@export var particle_sensitivity_curve : Curve
##Modifier on sensitivity depending on progress time. Domain should remain 0 - 1. Value is modifier on particle tickle depending on progress
@export var particle_sensitivity_mod_curve : Curve

@onready var _particle_decay_rate : float = particle_count_time_effect.max_domain / particle_decay_seconds
var _allergen_time_decay_rate : float
var allergen_time : CustomBoundedValue
var allergen_particles : CustomBoundedValue

var nose_dict : Dictionary[NoseTriggerZone, float]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("has_sliders")
	
	var all_noses = get_tree().get_nodes_in_group("nose")
	for nose in all_noses:
		if nose is NoseTriggerZone:
			nose_dict[nose as NoseTriggerZone] = 0.0
			nose.on_nose_damage.connect(_on_nose_damage)
	
	var time_of_curve = func(curve : Curve) -> float:
		return curve.max_domain if curve != null else -1.0
	
	var max_time : float = max(time_of_curve.call(progress_tickle_curve),
								time_of_curve.call(progress_burn_curve),
								time_of_curve.call(progress_sensitivity_curve),
								time_of_curve.call(particle_tickle_mod_curve),
								time_of_curve.call(particle_burn_mod_curve),
								time_of_curve.call(particle_sensitivity_mod_curve))
	
	if max_time != -1.0:
		allergen_time = CustomBoundedValue.new()
		allergen_time.name = allergen.allergy_name + " Progress"
		allergen_time.max_value = max_time
		_allergen_time_decay_rate = max_time / allergen_time_decay_seconds
	
	allergen_particles = CustomBoundedValue.new()
	allergen_particles.name = allergen.allergy_name + " Particles"
	allergen_particles.max_value = particle_count_time_effect.max_domain
	
	if brain != null:
		brain.on_sneeze.connect(func():
			#Decay a number of particles on sneeze
			allergen_particles.add_value(-_particle_decay_rate * particle_decay_sneeze_seconds)
			if allergen_time != null:
				allergen_time.add_value(-_allergen_time_decay_rate * allergen_decay_sneeze_seconds)
		)

##Return the raw tickle  value depending on the allergen progress and particle percentage.
func sample_tickle() -> float:
	var amount = 0.0
	if progress_tickle_curve != null:
		amount += progress_tickle_curve.sample_baked(allergen_time.current_value)
	if particle_tickle_curve != null:
		var raw : float = particle_tickle_curve.sample_baked(allergen_particles.get_percent())
		if particle_tickle_mod_curve != null:
			raw *= particle_tickle_mod_curve.sample_baked(allergen_time.current_value)
		amount += raw
	return amount

##Return the raw burn value depending on the allergen progress and particle percentage.
func sample_burn() -> float:	
	var amount = 0.0
	if progress_burn_curve != null:
		amount += progress_burn_curve.sample_baked(allergen_time.current_value)
	if particle_burn_curve != null:
		var raw : float = particle_burn_curve.sample_baked(allergen_particles.get_percent())
		if particle_burn_mod_curve != null:
			raw *= particle_burn_mod_curve.sample_baked(allergen_time.current_value)
		amount += raw
	return amount

##Return the raw burn value depending on the allergen progress and particle percentage.
func sample_sensitivity() -> float:	
	var amount = 0.0
	if progress_sensitivity_curve != null:
		amount += progress_sensitivity_curve.sample_baked(allergen_time.current_value)
	if particle_sensitivity_curve != null:
		var raw : float = particle_sensitivity_curve.sample_baked(allergen_particles.get_percent())
		if particle_sensitivity_mod_curve != null:
			raw *= particle_sensitivity_mod_curve.sample_baked(allergen_time.current_value)
		amount += raw
	return amount


func _on_nose_damage(damage_amount : float, damage_type : TickleComponent.DAMAGE_TYPES, allergy_resource : AllergyResource):
	if damage_type == TickleComponent.DAMAGE_TYPES.ALLERGY and allergy_resource.allergy_name == allergen.allergy_name:
		#print("Detecting allergy damage")
		allergen_particles.add_value(damage_amount)

func _physics_process(delta: float) -> void:
	allergen_particles.add_value(delta * - _particle_decay_rate)
	
	#Modify allergen progress by particle amount
	if allergen_time != null:
		if allergen_particles.get_percent() <= 0:
			allergen_time.add_value(delta * - _allergen_time_decay_rate)
		else:
			allergen_time.add_value(delta * particle_count_time_effect.sample_baked(allergen_particles.get_percent()))
	
	var tickle_damage : float = sample_tickle()
	if tickle_damage != 0:
		for nose in nose_dict:
			nose.damage(delta * tickle_damage, TickleComponent.DAMAGE_TYPES.TICKLE, null, false)
		
	var burn_damage : float = sample_burn()
	if burn_damage != 0:
		for nose in nose_dict:
			nose.damage(delta * burn_damage, TickleComponent.DAMAGE_TYPES.BURN, null, false)
	
	var sensitivity_damage : float = sample_sensitivity()
	if sensitivity_damage != 0:
		for nose in nose_dict:
			nose.damage(delta * sensitivity_damage, TickleComponent.DAMAGE_TYPES.SENSITIVITY, null, false)

#func debug() -> void:
	#print("DETECTOR %s\n\tParticles %.1f (%.2f%%) \tProgress: %.1f (%.1f%%) \n\tTickle Damage: %.2f\tBurn Damage: %.2f\tSensitivity Damage: %.2f" % 
		#[allergen.allergy_name, 
		#allergen_particles.current_value, 
		#allergen_particles.get_percent() * 100,
		#allergen_time.current_value,
		#allergen_time.get_percent() * 100,
		#sample_tickle(),
		#sample_burn(),
		#sample_sensitivity()])

func send_sliders(container : SliderBarContainer):
	print("Allergen Detector sending sliders...")
	container.add_new_header(allergen.allergy_name)
	container.add_new_slider(allergen_particles)
	if allergen_time != null:
		container.add_new_slider(allergen_time)
	
