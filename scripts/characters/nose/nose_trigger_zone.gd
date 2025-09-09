extends Area2D
class_name NoseTriggerZone

@export_category("General Stats")
##Amount of trigger to send to brain if dice roll is successful
@export var sneeze_trigger_amount : float = 10
@export var sniff_trigger_amount : float = 0.01
@export var update_frequency : float = 0.5
@export_flags_2d_physics var collision_layers : int = 8

@export_category("Wetness")
@export var tickle_wetness_mod : float = 0.05
@export var burn_wetness_mod : float = 0.1
@export var sneeze_wetness_mod : float = -0.75
@export var sniff_wetness_mod : float = -0.2

@export_category("Tickle Damage Share")
##Hitbox that this nose should share tickle damage to.
@export var connected_nose : NoseTriggerZone
##When tickle damage hits this nose, share this percent to connected nose.
@export var nose_share : float = 0.5

@export_category("Tickle")
##Trigger chance contribution depending on current tickle percent
@export var tickle_curve : Curve = preload("res://resources/curves/nose/default_tickle_curve.tres")
##How many seconds to wait after damage before decaying tickle value
@export var tickle_wait_seconds : float = 10.0
##How many seconds does it take to decay the tickle value from full to zero.
@export var tickle_decay_seconds : float = 20.0
##How many seconds of decay to apply to tickle on sneeze
@export var tickle_decay_on_sneeze_seconds : float = 15.0

@export_category("Burn")
##Trigger chance contribution depending on current burn percent
@export var burn_curve : Curve = preload("res://resources/curves/nose/default_burn_curve.tres")
##How many seconds to wait after damage before decaying burn value
@export var burn_wait_seconds : float = 20.0
##How many seconds does it take to decay the burn value from full to zero.
@export var burn_decay_seconds : float = 45.0
##How many seconds of decay to apply to burn on sneeze
@export var burn_decay_on_sneeze_seconds : float = 10.0

@export_category("Sensitivity")
##Multiplier to trigger chance depending on current sensitivity
@export var sensitivity_curve : Curve = preload("res://resources/curves/nose/default_sensitivity_curve.tres")
##Multiplier to apply to the current sensitivity on sneeze
@export var sensitivity_multiplier_on_sneeze : float = 0.7
##How many seconds does it take to decay the sensitivity value from full back to the middle point of the graph.
@export var sensitivity_decay_seconds : float = 60

var sneeze_trigger_timer: Timer
var tickle_decay_timer: Timer
var burn_decay_timer: Timer

#Holds min, max and current value for tickle amount
var tickle : CustomBoundedValue
#Holds min, max and current value for burn amount
var burn : CustomBoundedValue
#Holds min, max and current value for sensitivity amount
var sensitivity : CustomBoundedValue

##Idle tickle value of the nose.
var _tickle_target : float
##Idle burn value of the nose.
var _burn_target : float
##General idle sensitivity of the nose
var sensitivity_target : float

var tickle_decay : float
var burn_decay : float
var sensitivity_decay : float

#Holds min, max, current nose wetness, used for spray amount.
var nose_wetness : CustomBoundedValue

signal sneeze_trigger(amount : float)
signal sniff_trigger(amount : float)
signal on_nose_damage(tickle_amount : float, damage_type : TickleComponent.DAMAGE_TYPES, allergy_type : AllergyResource)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("has_sliders")
	add_to_group("nose")
	
	collision_layer = collision_layers
	collision_mask = 0
	
	var setup_bound = func(name : String, curve : Curve) -> CustomBoundedValue:
		var bound = CustomBoundedValue.new()
		bound.name = name
		bound.max_value = curve.max_domain
		bound.min_value = curve.min_domain
		bound.current_value = curve.min_domain
		return bound
	
	tickle = setup_bound.call("Tickle Amount", tickle_curve)
	burn = setup_bound.call("Burn Amount", burn_curve)
	sensitivity = setup_bound.call("Sensitivity Amount", sensitivity_curve)
	
	sensitivity.current_value = sensitivity.max_value / 2
	
	nose_wetness = CustomBoundedValue.new()
	nose_wetness.name = "Wetness"
	
	tickle_decay = tickle.max_value / tickle_decay_seconds
	burn_decay = burn.max_value / burn_decay_seconds
	sensitivity_decay = sensitivity.max_value / 2 / sensitivity_decay_seconds


	burn_decay_timer = Timer.new()
	burn_decay_timer.one_shot = true
	tickle_decay_timer = Timer.new()
	tickle_decay_timer.one_shot = true
	sneeze_trigger_timer = Timer.new()
	
	add_child(burn_decay_timer)
	add_child(tickle_decay_timer)
	add_child(sneeze_trigger_timer)
	
	sneeze_trigger_timer.timeout.connect(do_sneeze_trigger)
	sneeze_trigger_timer.start(update_frequency)
	
	#Tickle/Burn move to the low end of the bounded value.
	_tickle_target = tickle.min_value
	_burn_target = burn.min_value
	
	#Sensitivity moves towards the middle of the graph when idle by default.
	sensitivity_target = sensitivity.max_value / 2.0

func _process(delta: float) -> void:
	if tickle_decay_timer.is_stopped():
		tickle.add_value(delta * -tickle_decay)

	if burn_decay_timer.is_stopped():
		burn.add_value(delta * -burn_decay)

	if sensitivity.get_percent() > 0.5:
		sensitivity.add_value(delta * -sensitivity_decay)
	if sensitivity.get_percent() < 0.5:
		sensitivity.add_value(delta * sensitivity_decay)
	
	nose_wetness.add_value(delta * tickle.get_percent() * tickle_wetness_mod)
	nose_wetness.add_value(delta * burn.get_percent() * burn_wetness_mod)

func do_sneeze_trigger():
	var trigger_chance : float = 0.0
	trigger_chance += tickle_curve.sample_baked(tickle.current_value) + burn_curve.sample_baked(burn.current_value)
	trigger_chance *= sensitivity_curve.sample_baked(sensitivity.current_value)
	
	if randf() < trigger_chance:
		sneeze_trigger.emit(sneeze_trigger_amount)
	
	sniff_trigger.emit(nose_wetness.get_percent() * sniff_trigger_amount)

func on_sneeze(sneeze_size : float = 1.0):
	print("<NOSE> On Sneeze")
	#Remove tickle/burn/sensitivity
	tickle.add_value(-tickle_decay * tickle_decay_on_sneeze_seconds * sneeze_size)
	burn.add_value(-burn_decay * tickle_decay_on_sneeze_seconds * sneeze_size)
	sensitivity.current_value = sensitivity.current_value * sensitivity_multiplier_on_sneeze * sneeze_size
	
	#Remove some amount of wetness
	nose_wetness.add_value(nose_wetness.max_value * sneeze_wetness_mod * sneeze_size)

func on_sniff():
	print("<NOSE> On Sniff")
	#Remove some amount of wetness
	nose_wetness.add_value(nose_wetness.max_value * sniff_wetness_mod)

func damage(amount : float, damage_type : TickleComponent.DAMAGE_TYPES, allergy_resource : AllergyResource = null, share : bool = true):
	if share and connected_nose != null:
		connected_nose.damage(amount * nose_share, damage_type, allergy_resource)
	
	on_nose_damage.emit(amount, damage_type, allergy_resource)
	match(damage_type):
		TickleComponent.DAMAGE_TYPES.TICKLE:
			tickle_decay_timer.start(tickle_wait_seconds)
			tickle.add_value(amount)
		
		TickleComponent.DAMAGE_TYPES.BURN:
			burn_decay_timer.start(burn_wait_seconds)
			burn.add_value(amount)
		
		TickleComponent.DAMAGE_TYPES.SENSITIVITY:
			sensitivity.add_value(amount)
		
		TickleComponent.DAMAGE_TYPES.SNEEZECOUNT:
			sneeze_trigger.emit(amount)

func send_sliders(container : DebugUIContainer):
	container.add_new_header(self.name + " Settings", "Settings and data in nose")
	container.add_new_slider(tickle, "Tickle amount increases chance to add sneeze count to brain")
	container.add_new_slider(burn, "Burn amount increases chance to add sneeze count to brain")
	container.add_new_slider(sensitivity, "Sensitivity modifies chance to add sneeze count to brain")
	container.add_new_slider(nose_wetness, "Amount of moisture in nose, affects spray")

func send_curves(container : DebugUIContainer):
	container.add_new_header(name + " Curves", "Curve thresholds for various nose functions")
	container.add_new_curve("Tickle Curve",tickle_curve)
	container.add_new_curve("Burn Curve",burn_curve)
	container.add_new_curve("Sensitivity Curve",sensitivity_curve)
	
