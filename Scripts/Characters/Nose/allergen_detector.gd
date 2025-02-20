extends Node
class_name AllergenDetector

@export var allergen : AllergyResource

##From 0 to max particles, add delta * this sample to the progress each tick
@export var particle_count_time_effect : Curve = preload("res://Resources/Curves/default_particle_count_time_effect.tres")
##How many seconds does it take to reach the end of the allergen effect curve, from 0?
@export var time_to_max_progress : float = 60.0
##How many seconds does it take to reach the beginning of the allergen effect curve, from 100?
@export var decay_time_seconds : float = 15.0

##How many seconds should it take for all particles to be removed from nose, from max count?
@export var particle_decay_seconds : float = 60.0

@onready var progress_decay_rate = -time_to_max_progress / decay_time_seconds
@onready var particle_decay_rate = -allergen.max_count / particle_decay_seconds 
var allergen_time := CustomBoundedValue.new()
var allergen_particles := CustomBoundedValue.new()

var nose : NoseTriggerZone
var debug_timer : Timer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("has_sliders")
	
	debug_timer = Timer.new()
	debug_timer.wait_time = 2.0
	debug_timer.timeout.connect(debug)
	#debug_timer.autostart = true
	add_child(debug_timer)
	
	nose = get_parent()
	nose.on_allergy_damage.connect(on_allergy_damage)
		
	allergen_time.name = allergen.allergy_name + " Progress"
	allergen_time.max_value = time_to_max_progress
	
	allergen_particles.name = allergen.allergy_name + " Particles"
	allergen_particles.max_value = allergen.max_count

func on_allergy_damage(damage_amount : float, allergy_type : AllergyResource):
	if allergy_type.allergy_name == allergen.allergy_name:
		#print("Detecting allergy damage")
		allergen_particles.add_value(damage_amount)

func _process(delta: float) -> void:
	allergen_particles.add_value(delta * particle_decay_rate)
	
	if allergen_particles.get_percent() == 0.0:
		allergen_time.add_value(delta * progress_decay_rate)
	else:
		allergen_time.add_value(delta * particle_count_time_effect.sample(allergen_particles.get_percent()))
		
	if allergen.does_tickle():
		nose.add_tickle(delta * get_tickle_damage(), TickleComponent.DAMAGE_TYPES.TICKLE, null)
	if allergen.does_burn():
		nose.add_tickle(delta * get_burn_damage(), TickleComponent.DAMAGE_TYPES.BURN, null)

func get_tickle_damage() -> float:
	return allergen.sample_tickle(allergen_time.get_percent(), allergen_particles.get_percent())

func get_burn_damage() -> float:
	return allergen.sample_burn(allergen_time.get_percent(), allergen_particles.get_percent())
	
func debug() -> void:
	print("DETECTOR %s %s" % [allergen.allergy_name, allergen_time.to_string()])
	print("DETECTOR %s %s" % [allergen.allergy_name, allergen_particles.to_string()])
	print("Burn Damage: ",get_burn_damage())
	print("Tickle Damage: ",get_tickle_damage())

func send_sliders(container : SliderBarContainer):
	print("Allergen Detector sending sliders...")
	container.add_new_slider(allergen_particles)
	container.add_new_slider(allergen_time)
	
