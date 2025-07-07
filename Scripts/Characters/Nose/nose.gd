extends Area2D
class_name NoseTriggerZone

@export_category("General Stats")
##Amount of trigger to send to brain if dice roll is successful
@export var sneeze_trigger_amount : float = 10
##Holds min, max and current value for tickle amount
@export var tickle : CustomBoundedValue
##Holds min, max and current value for burn amount
@export var burn : CustomBoundedValue
##Holds min, max and current value for sensitivity amount
@export var sensitivity : CustomBoundedValue

@export_category("Tickle Damage Share")
##Hitbox that this nose should share tickle damage to.
@export var connected_nose : NoseTriggerZone
##When tickle damage hits this nose, share this percent to connected nose.
@export var nose_share : float = 0.5

@export_category("Tickle")
##Trigger chance contribution depending on current tickle percent
@export var tickle_curve : Curve = preload("res://resources/curves/nose/default_tickle_curve.tres")
##How many seconds to wait before decaying tickle value
@export var tickle_wait_seconds : float = 10.0
##How many seconds does it take to decay the tickle value from full to zero.
@export var tickle_decay_seconds : float = 20.0
##How many seconds of decay to apply to tickle on sneeze
@export var tickle_decay_on_sneeze_seconds : float = 15.0

@export_category("Burn")
##Trigger chance contribution depending on current burn percent
@export var burn_curve : Curve = preload("res://resources/curves/nose/default_burn_curve.tres")
##How many seconds to wait before decaying burn value
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
@export var sensitivity_decay_seconds : float = 180.0

@onready var sneeze_trigger_timer: Timer = %SneezeTriggerTimer
@onready var tickle_decay_timer: Timer = %TickleDecayTimer
@onready var burn_decay_timer: Timer = %BurnDecayTimer

@onready var tickle_decay : float = tickle.max_value / tickle_decay_seconds
@onready var burn_decay : float = burn.max_value / burn_decay_seconds
@onready var sensitivity_decay : float = sensitivity.max_value / 2 / sensitivity_decay_seconds

##Idle tickle value of the nose.
var _tickle_target : float
##Idle burn value of the nose.
var _burn_target : float
##General idle sensitivity of the nose
var sensitivity_target : float

signal sneeze_trigger(amount : float)
signal on_tickle_damage(tickle_amount : float, damage_type : TickleComponent.DAMAGE_TYPES, allergy_type : AllergyResource)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sneeze_trigger_timer.timeout.connect(timer_timeout)
	
	#Tickle/Burn move to the low end of the bounded value.
	_tickle_target = tickle.min_value
	_burn_target = burn.min_value
	
	#Sensitivity moves towards the middle of the graph when idle by default.
	sensitivity_target = sensitivity.max_value / 2.0

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_T):
		add_tickle(delta * 2.0, TickleComponent.DAMAGE_TYPES.TICKLE, null)
		
	else:
		if tickle_decay_timer.is_stopped():
			tickle.add_value(delta * -tickle_decay)

	if Input.is_key_pressed(KEY_B):
		add_tickle(delta * 2.0, TickleComponent.DAMAGE_TYPES.BURN, null)
		
	else:
		if burn_decay_timer.is_stopped():
			burn.add_value(delta * -burn_decay)

	if Input.is_key_pressed(KEY_S):
		sensitivity.add_value(delta * 2.0)
		
	else: 
		sensitivity.add_value(delta * sensitivity_decay * (sensitivity_target - sensitivity.current_value))
	
func timer_timeout():
	var trigger_chance : float = 0.0
	trigger_chance += tickle_curve.sample_baked(tickle.get_percent()) + burn_curve.sample_baked(burn.get_percent())
	trigger_chance *= sensitivity_curve.sample_baked(sensitivity.get_percent())
	
	if randf() < trigger_chance:
		sneeze_trigger.emit(sneeze_trigger_amount)

func on_sneeze():
	print("<NOSE> On Sneeze")
	tickle.add_value(-tickle_decay * tickle_decay_on_sneeze_seconds)
	burn.add_value(-burn_decay * tickle_decay_on_sneeze_seconds)
	sensitivity.current_value = sensitivity.current_value * sensitivity_multiplier_on_sneeze

func add_tickle(tickle_amount : float, damage_type : TickleComponent.DAMAGE_TYPES, allergy_resource : AllergyResource, share : bool = true):
	if share and connected_nose != null:
		connected_nose.add_tickle(tickle_amount * nose_share, damage_type, allergy_resource)
	
	on_tickle_damage.emit(tickle_amount, damage_type, allergy_resource)
	match(damage_type):
		TickleComponent.DAMAGE_TYPES.TICKLE:
			tickle_decay_timer.start(tickle_wait_seconds)
			
			tickle.add_value(tickle_amount)
		TickleComponent.DAMAGE_TYPES.BURN:
			burn_decay_timer.start(burn_wait_seconds)
			
			burn.add_value(tickle_amount)
		
		TickleComponent.DAMAGE_TYPES.SENSITIVITY:
			sensitivity.add_value(tickle_amount)
		
		TickleComponent.DAMAGE_TYPES.SNEEZECOUNT:
			sneeze_trigger.emit(tickle_amount)

func send_sliders(container : SliderBarContainer):
	container.add_new_header(self.name + " Settings")
	container.add_new_slider(tickle)
	container.add_new_slider(burn)
	container.add_new_slider(sensitivity)
