extends Area2D
class_name NoseTriggerZone

#var damage_sensitivity_dict = {
	#"RUB" : 1.0,
	#"FLUFF" : 1.0,
	#"POKE" : 1.0,
	#"POLLEN" : 1.0,
	#"DUST" : 1.0,
	#"CHHINKNI" : 1.0,
#}

var tickle := CustomBoundedValue.new("Tickle",0.0,50.0,0.0)
var burn := CustomBoundedValue.new("Burn",0.0,30.0,0.0)
var sensitivity := CustomBoundedValue.new("Sensitivity",0.0,5.0,1.0)

@export var tickle_wait_seconds : float = 10.0
@export var burn_wait_seconds : float = 20.0

@export var tickle_decay_seconds : float = 20.0
@export var burn_decay_seconds : float = 45.0
@export var sensitivity_decay_seconds : float = 180.0

var tickle_decay = -tickle.max_value / tickle_decay_seconds
var burn_decay = -burn.max_value / burn_decay_seconds
var sensitivity_decay = sensitivity.max_value / sensitivity_decay_seconds
var sensitivity_target = 1.0

@export var tickle_decay_on_sneeze_seconds : float = 15.0
@export var burn_decay_on_sneeze_seconds : float = 10.0
@export var sensitivity_multiplier_on_sneeze : float = 0.7

@onready var sneeze_trigger_timer: Timer = %SneezeTriggerTimer
@onready var tickle_decay_timer: Timer = %TickleDecayTimer
@onready var burn_decay_timer: Timer = %BurnDecayTimer

#signal tickle_report(ticklePercent : float)
#signal burn_report(burnPercent : float)
#signal sensitivity_report(sensitivityPercent : float)
signal sneeze_trigger
signal on_allergy_damage(damage_amount, allergy_type)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sneeze_trigger_timer.timeout.connect(timer_timeout)

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_T):
		tickle.add_value(delta * 20.0) 
	else:
		if tickle_decay_timer.is_stopped():
			tickle.add_value(delta * tickle_decay)

	if Input.is_key_pressed(KEY_B):
		burn.add_value(delta * 20.0)
	else:
		if burn_decay_timer.is_stopped():
			burn.add_value(delta * burn_decay)

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
		sneeze_trigger.emit()
		#print("Trigger Sneeze")
	#tickle_report.emit(tickle.get_percent())
	#burn_report.emit(burn.get_percent())
	#sensitivity_report.emit(sensitivity.get_percent())

func on_sneeze():
	print("<NOSE> On Sneeze")
	tickle.add_value(tickle_decay * tickle_decay_on_sneeze_seconds)
	burn.add_value(burn_decay * tickle_decay_on_sneeze_seconds)
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
		TickleComponent.DAMAGE_TYPES.ALLERGY:
			#print("Sending allergy damage. ", tickle_amount, ", ", allergy_type)
			on_allergy_damage.emit(tickle_amount, allergy_type)
