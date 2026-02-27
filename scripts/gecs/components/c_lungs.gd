extends Component
class_name C_Lungs

enum State {IDLE,INHALE,EXHALE,HOLD,HITCH,SNEEZE,SIGH}

@export_group("Breath Settings")
@export var max_air : float = 100
@export_category("Air rates")
@export_range(0.1,5.0,0.001) var inhale_rate : float = 0.8
@export_range(0.1,5.0,0.001) var exhale_rate : float = 0.7
@export_range(0.1,5.0,0.001) var hitch_rate : float = 0.6
@export_range(0.1,5.0,0.001) var sneeze_rate : float = 1.2
@export_range(0.1,5.0,0.001) var sigh_rate : float = 0.25
@export_category("Wind bonus power")
@export var inhale_power : float = 1.0
@export var exhale_power : float = 1.0
@export var hitch_power : float = 5
@export var sneeze_power : float = 20
@export var sigh_power : float = 0.5

@export_group("Oxygen Settings")
##Max amount of oxygen storable in the lungs
@export var max_oxygen : float = 10
##How many units of oxygen per unit of air?
@export var oxygen_per_air : float = 0.2
##Amount of oxygen to drain per second
@export var oxygen_drain_rate : float = 1.0
##What oxygen value can a breath be triggered below?
@export var oxygen_can_breathe_threshold : float = 4.0

##Current air in lungs
var air : float = 0.0
##Current oxygen in lungs
var oxygen : float = 0.0
##Current state
var state : State = State.IDLE

var next_breathe_threshold : float = -1 
var time_inhale_stopped : int = -1
