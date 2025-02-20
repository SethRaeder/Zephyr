extends Area2D
class_name NoseTriggerZone

@export_category("General Stats")
@export var connected_nose : NoseTriggerZone
@export var nose_share : float = 0.5
@export var sneeze_trigger_amount : float = 1.0
#Bounded values for the three main parameters in the nose
@export var tickle : CustomBoundedValue
@export var burn : CustomBoundedValue
@export var sensitivity : CustomBoundedValue

@export_category("Sensitivity")
##General idle sensitivity of the nose
@export var sensitivity_target : float = 1.0
##Multiplier to apply to the current sensitivity on sneeze
@export var sensitivity_multiplier_on_sneeze : float = 0.7
##How many seconds does it take to decay the sensitivity value from full to zero.
@export var sensitivity_decay_seconds : float = 180.0

@export_category("Tickle")
##Idle tickle value of the nose.
@export var tickle_target : float = 0.0
##How many seconds to wait before decaying tickle value
@export var tickle_wait_seconds : float = 10.0
##How many seconds does it take to decay the tickle value from full to zero.
@export var tickle_decay_seconds : float = 20.0
##How many seconds of decay to apply to tickle on sneeze
@export var tickle_decay_on_sneeze_seconds : float = 15.0

@export_category("Burn")
##Idle tickle value of the nose.
@export var burn_target : float = 0.0
##How many seconds to wait before decaying burn value
@export var burn_wait_seconds : float = 20.0
##How many seconds does it take to decay the burn value from full to zero.
@export var burn_decay_seconds : float = 45.0
##How many seconds of decay to apply to burn on sneeze
@export var burn_decay_on_sneeze_seconds : float = 10.0

@onready var sneeze_trigger_timer: Timer = %SneezeTriggerTimer
@onready var tickle_decay_timer: Timer = %TickleDecayTimer
@onready var burn_decay_timer: Timer = %BurnDecayTimer

@onready var tickle_decay = tickle.max_value / tickle_decay_seconds
@onready var burn_decay = burn.max_value / burn_decay_seconds
@onready var sensitivity_decay = sensitivity.max_value / sensitivity_decay_seconds

signal sneeze_trigger(amount : float)
signal on_allergy_damage(damage_amount, allergy_type)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if connected_nose:
		connected_nose.on_allergy_damage.connect(func(amount, type):
			add_tickle(amount, TickleComponent.DAMAGE_TYPES.ALLERGY, type)
		)
	sneeze_trigger_timer.timeout.connect(timer_timeout)

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_T):
		add_tickle(delta * 2.0, TickleComponent.DAMAGE_TYPES.TICKLE, null)
		
	else:
		if tickle_decay_timer.is_stopped():
			tickle.add_value(delta * tickle_decay * (tickle_target - tickle.current_value))

	if Input.is_key_pressed(KEY_B):
		add_tickle(delta * 2.0, TickleComponent.DAMAGE_TYPES.BURN, null)
		
	else:
		if burn_decay_timer.is_stopped():
			burn.add_value(delta * burn_decay * (burn_target - burn.current_value))

	if Input.is_key_pressed(KEY_S):
		sensitivity.add_value(delta * 2.0)
		
	else: 
		sensitivity.add_value(delta * sensitivity_decay * (sensitivity_target - sensitivity.current_value))
	
func timer_timeout():
	#print("Tickle: ",tickle.get_percent())
	#print("Burn: ",burn.get_percent())
	var sneeze_chance = (tickle.current_value + burn.current_value) * sensitivity.current_value
	
	#print("<NOSE.GD> Sneeze chance: ",sneeze_chance, " Sensitivity: ",sensitivity.current_value, " Tickle: ",tickle.current_value, " Burn: ",burn.current_value)
	if randf()*100.0 < sneeze_chance:
		sneeze_trigger.emit(sneeze_trigger_amount)
		#print("Trigger Sneeze")
	#tickle_report.emit(tickle.get_percent())
	#burn_report.emit(burn.get_percent())
	#sensitivity_report.emit(sensitivity.get_percent())

func on_sneeze():
	print("<NOSE> On Sneeze")
	tickle.add_value(-tickle_decay * tickle_decay_on_sneeze_seconds)
	burn.add_value(-burn_decay * tickle_decay_on_sneeze_seconds)
	sensitivity.current_value = sensitivity.current_value * sensitivity_multiplier_on_sneeze

func add_tickle(tickle_amount : float, damage_type : TickleComponent.DAMAGE_TYPES, allergy_type : AllergyResource):
	match(damage_type):
		TickleComponent.DAMAGE_TYPES.TICKLE:
			tickle_decay_timer.stop()
			tickle_decay_timer.start(tickle_wait_seconds)
			
			tickle.add_value(tickle_amount)
		TickleComponent.DAMAGE_TYPES.BURN:
			burn_decay_timer.stop()
			burn_decay_timer.start(burn_wait_seconds)
			
			burn.add_value(tickle_amount)
		
		TickleComponent.DAMAGE_TYPES.SENSITIVITY:
			sensitivity.add_value(tickle_amount)
			
		TickleComponent.DAMAGE_TYPES.ALLERGY:
			#print("Sending allergy damage. ", tickle_amount, ", ", allergy_type)
			on_allergy_damage.emit(tickle_amount, allergy_type)

func send_sliders(container : SliderBarContainer):
	container.add_new_header(self.name + " Settings")
	container.add_new_slider(tickle)
	container.add_new_slider(burn)
	container.add_new_slider(sensitivity)
