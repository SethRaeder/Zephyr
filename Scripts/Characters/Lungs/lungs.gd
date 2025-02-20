extends Node
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

@export var lungs : CustomBoundedValue
@export var oxygen : CustomBoundedValue

var oxygen_per_lungs = 2.0
@onready var oxygen_decay_rate = oxygen.max_value / 6.0

signal breathe_in
signal breathe_out
signal breathe_done
signal want_breathe
signal must_breathe
signal breathe_rate(rate : float)

enum BREATH_STATE {IDLE, IN, OUT, HOLD, HITCH, BUILDUP, SNEEZE, SIGH}
var breath_state_current = BREATH_STATE.IDLE
@export var IDLE_RATE = 0.0
@export var IN_RATE = 50.0
@export var OUT_RATE = -70.0
@export var HITCH_RATE = 15.0
@export var BUILD_RATE = 25.0
@export var SNEEZE_RATE = -40.0
@export var SIGH_RATE = -30.0

@export var IN_WIND_BONUS = 1.0
@export var OUT_WIND_BONUS = 1.0
@export var HITCH_WIND_BONUS = 1.0
@export var BUILD_WIND_BONUS = 1.0
@export var SNEEZE_WIND_BONUS = 20.0
@export var SIGH_WIND_BONUS = 5.75

@export var OXY_SNEEZE_DECAY = -20.0
@onready var low_oxy_timer: Timer = %LowOxyTimer

@export_category("Sneeze Wind Audio Settings")
@export var voice_box : VoiceBox
@export var sneeze_wind_curve : Curve



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("lungs")
	
	low_oxy_timer.timeout.connect(low_oxy_check)
	
	lungs.hit_max.connect(
		func():
			match breath_state_current:
				BREATH_STATE.HITCH:
					set_breath_state(BREATH_STATE.HOLD)
				BREATH_STATE.SNEEZE:
					pass
				_:
					set_breath_state(BREATH_STATE.OUT)
	)
	lungs.hit_min.connect(
		func():
			match breath_state_current:
				BREATH_STATE.SNEEZE:
					pass
				_:
					set_breath_state(BREATH_STATE.IDLE)
	)
	oxygen.hit_min.connect(must_breathe.emit)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	oxygen.add_value(-oxygen_decay_rate * delta)
	
	#print("Lungs: Current breath state: ",breath_state_current)
	#print("Lungs: Current value: ",lungs.current_value)
	match breath_state_current:
		BREATH_STATE.IDLE, BREATH_STATE.HOLD:
			breathe_rate.emit(0)
		
		BREATH_STATE.IN:
			breathe(IN_RATE, IN_WIND_BONUS, delta)
			
		BREATH_STATE.OUT:
			breathe(OUT_RATE, OUT_WIND_BONUS, delta)
		
		BREATH_STATE.HITCH:
			breathe(HITCH_RATE, HITCH_WIND_BONUS, delta)
		
		BREATH_STATE.BUILDUP:
			breathe(BUILD_RATE, BUILD_WIND_BONUS, delta)
			
		BREATH_STATE.SNEEZE:
			if voice_box.Sneeze.playing and sneeze_wind_curve:
				var progress = voice_box.Sneeze.get_playback_position()
				var sample = sneeze_wind_curve.sample_baked(clampf(progress,0,1))
			
				breathe(SNEEZE_RATE * sample, SNEEZE_WIND_BONUS, delta)
				oxygen.add_value(OXY_SNEEZE_DECAY * sample * delta)
			#else:
				#breathe(SNEEZE_RATE * lungs.get_percent(), SNEEZE_WIND_BONUS, delta)
				#oxygen.add_value(OXY_SNEEZE_DECAY * lungs.get_percent() * delta)
		
		BREATH_STATE.SIGH:
			breathe(SNEEZE_RATE * lungs.get_percent(), SIGH_WIND_BONUS, delta)

func low_oxy_check():
	if oxygen.current_value < 0 and oxygen.min_value < 0:
		want_breathe.emit(lerp(0.05,0.50,oxygen.current_value/oxygen.min_value))
		
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
	return lungs.get_percent() >= .85

func breathe(rate, bonus, delta):
	breathe_rate.emit(rate * bonus * delta)
	lungs.add_value(rate * delta)
	#print("Lungs: Current value: ", lungs.current_value)
	if rate > 0:
		oxygen.add_value(rate * oxygen_per_lungs * delta)
	
