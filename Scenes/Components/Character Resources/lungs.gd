extends Node2D
class_name Lungs

#Lungs must:
  #have capacity
  #track breath inside
  #track oxygen level
  #breathe as magnitude (+ in, - out)
  #send lungs breathe signal as magnitude float
  #modify breath by magnitude * delta
  #add oxygen when breath increases
  #consume breathe event and add breath/oxygen depending on breath velocity magnitude
  #send "lungs full" signal
  #send "lungs empty" signal
  #send "desire oxygen" signal
  #send "oxygen empty" signal

var lungs := CustomBoundedValue.new("Lungs",0.0,100.0,0.0)
var oxygen := CustomBoundedValue.new("Oxygen",0.0,100.0,0.0)

var oxygen_per_lungs = 1.0
var oxygen_decay_rate = 10.0

signal breathe_in
signal breathe_out
signal breathe_done
signal want_breathe
signal must_breathe
signal breathe_rate(rate : float)

enum BREATH_STATE {IDLE, IN, OUT, HOLD, HITCH, SNEEZE, SIGH}
var breath_state_current = BREATH_STATE.IDLE
@export var IDLE_RATE = 0.0
@export var IN_RATE = 50.0
@export var OUT_RATE = -70.0
@export var HITCH_RATE = 15.0
@export var SNEEZE_RATE = -40.0
@export var SIGH_RATE = -30.0

@export var IN_WIND_BONUS = 1.0
@export var OUT_WIND_BONUS = 1.0
@export var HITCH_WIND_BONUS = 1.0
@export var SNEEZE_WIND_BONUS = 20.0
@export var SIGH_WIND_BONUS = 5.75

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("lungs")
	
	lungs.hit_max.connect(
		func():
			match breath_state_current:
				BREATH_STATE.HITCH:
					set_breath_state(BREATH_STATE.HOLD)
				_:
					set_breath_state(BREATH_STATE.OUT)
	)
	lungs.hit_min.connect(
		func():
			set_breath_state(BREATH_STATE.IDLE)
	)
	oxygen.hit_min.connect(must_breathe.emit)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	oxygen.add_value(-oxygen_decay_rate * delta)
	
	print("Lungs: Current breath state: ",breath_state_current)
	print("Lungs: Current value: ",lungs.current_value)
	match breath_state_current:
		BREATH_STATE.IDLE, BREATH_STATE.HOLD:
			breathe_rate.emit(0)
		
		BREATH_STATE.IN:
			breathe(IN_RATE, IN_WIND_BONUS, delta)
			
		BREATH_STATE.OUT:
			breathe(OUT_RATE, OUT_WIND_BONUS, delta)
		
		BREATH_STATE.HITCH:
			breathe(HITCH_RATE, HITCH_WIND_BONUS, delta)
			
		BREATH_STATE.SNEEZE:
			breathe(SNEEZE_RATE * lungs.get_percent(), SNEEZE_WIND_BONUS, delta)
		
		BREATH_STATE.SIGH:
			breathe(SNEEZE_RATE * lungs.get_percent(), SIGH_WIND_BONUS, delta)


func set_breath_state(new_state):
	breath_state_current = new_state
	match new_state:
		BREATH_STATE.OUT:
			breathe_out.emit()
		BREATH_STATE.IN:
			breathe_in.emit()
		BREATH_STATE.IDLE:
			breathe_done.emit()

func is_full():
	return lungs.get_percent() >= .95

func breathe(rate,bonus,delta):
	breathe_rate.emit(rate * bonus * delta)
	lungs.add_value(rate * delta)
	#print("Lungs: Current value: ", lungs.current_value)
	if rate > 0:
		oxygen.add_value(rate * oxygen_per_lungs * delta)
	
