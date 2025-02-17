extends Node
class_name Brain

@export_category("Node References")
@export var lungs: Lungs
@export var voice: VoiceBox

@export_category("Curves")
##Define the chances of hitch animation playing depending on sneeze level
@export var hitch_curve : Curve
##Define the chances of buildup animation playing depending on sneeze level
@export var buildup_curve : Curve
##Define the chances of sneeze animation playing depending on sneeze level
@export var sneeze_curve : Curve

##How many sneeze triggers is needed to reach max sneeze level?
@export var sneeze_trigger_target : float = 20.0
##How many seconds to decay sneeze trigger to zero?
@export var sneeze_trigger_decay_seconds : float = 20.0
##How many sneeze triggers is needed to reach max tickle level?
@export var tickle_max := 8.0
##How many sneeze triggers to remove on sneeze
@export var sneeze_trigger_expel : float = 5
##How often to check for animation transitions
@export var update_timer_base_time := 0.25
##Variance in the update timer, from 0 seconds to value seconds
@export var update_timer_max_variance := 1.0

@export_category("Fits")
##How likely to have a fit? Max 1.0
@export var fit_probability : float = 0.3
##How many seconds should a fit last? From X to Y seconds
@export var fit_window_seconds : Vector2 = Vector2(5.0, 20.0)
##How much to boost sneeze level while in a fit?
@export var fit_sneeze_bonus : float = 2.0

@onready var animation_tree: AnimationTree = %AnimationTree
@onready var update_timer: Timer = $UpdateTimer
@onready var fit_timer: Timer = $FitTimer
@onready var sneeze_trigger_count := CustomBoundedValue.new("sneeze_trigger_count",0.0,sneeze_trigger_target,0.0)
@onready var sneeze_decay_rate : float = -sneeze_trigger_target / sneeze_trigger_decay_seconds
var idletickleblend := 0.0

var hitch := false
var buildup := false
var sneeze := false
var sigh := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_tree.set("parameters/Blink Shot/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	animation_tree.set("parameters/Earflick Shot/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
	animation_tree.get("parameters/SneezeMachine/playback").get_current_node()
	
	lungs.breathe_out.connect(
		func():
			animation_tree.set("parameters/NoseFlareTransition/transition_request","idle")
	)
	lungs.breathe_in.connect(
		func():
			animation_tree.set("parameters/NoseFlareTransition/transition_request","flare")
	)
	lungs.breathe_done.connect(
		func():
			animation_tree.set("parameters/NoseFlareTransition/transition_request","idle")
	)
	
	lungs.want_breathe.connect(want_breathe)
	lungs.must_breathe.connect(must_breathe)
	
	#Attach all nose hitbox zones to the brain control
	for node in get_tree().get_nodes_in_group("nose"):
		if node is NoseTriggerZone:
			print("<BRAIN> Added Nose Trigger Zone ",node)
			node.sneeze_trigger.connect(sneeze_trigger)
			voice.on_sneeze.connect(node.on_sneeze)
	
	update_timer.timeout.connect(timer_timeout)
	
	voice.on_hitch.connect(on_hitch)
	voice.on_buildup.connect(on_hitch)
	voice.on_sneeze.connect(on_sneeze)
	voice.sneeze_finished.connect(sneeze_finished)
	voice.sneeze_finished.connect(breathe_out)
	voice.hitch_finished.connect(hold_breath)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	idletickleblend = lerpf(idletickleblend, clamp(float(sneeze_trigger_count.current_value * (1.0 if fit_timer.is_stopped() else fit_sneeze_bonus) / tickle_max), 0.0, 1.0), delta)
	
	sneeze_trigger_count.add_value(delta * sneeze_decay_rate)
	animation_tree.set("parameters/SneezeMachine/IdleTickle/blend_position", idletickleblend)

func timer_timeout():
	update_timer.wait_time = update_timer_base_time + randf_range(0.0,update_timer_max_variance)
	#print("<Brain> Sneeze trigger: ",sneeze_trigger_count)
	#print("<Brain> IdleTickleBlend: ",idletickleblend)
	var sneeze_percent = sneeze_trigger_count.get_percent()
	var playback = animation_tree.get("parameters/SneezeMachine/playback")
	if randf() < hitch_curve.sample(sneeze_percent):
		if not lungs.is_full():
			match playback.get_current_node():
				"hitch":
					pass
				"hitch_interrupt":
					if randf() <= 0.2:
						hitch = true
				_:
					hitch = true
		else:
			sigh = true
	if randf() < buildup_curve.sample(sneeze_percent) * (1.0 if fit_timer.is_stopped() else fit_sneeze_bonus):
		if not lungs.is_full():
			match playback.get_current_node():
				"buildup":
					pass
				"buildup_interrupt":
					if randf() <= 0.2:
						buildup = true
				_:
					buildup = true
		else:
			sigh = true
	if randf() < sneeze_curve.sample(sneeze_percent) * (1.0 if fit_timer.is_stopped() else fit_sneeze_bonus):
		sneeze = true
	
	animation_tree.set("parameters/SneezeMachine/conditions/sneeze",sneeze)
	animation_tree.set("parameters/SneezeMachine/conditions/buildup",buildup)
	animation_tree.set("parameters/SneezeMachine/conditions/hitch",hitch)
	
	if sigh and (not hitch and not buildup and not sneeze):
		breathe_out()

	hitch = false
	buildup = false
	sneeze = false
	sigh = false

func on_hitch():
	print("Brain: On Hitch")
	lungs.set_breath_state(lungs.BREATH_STATE.HITCH)

func on_sneeze():
	var sneeze_size = 1.0
	sneeze_trigger_count.add_value(-sneeze_trigger_expel * sneeze_size)
	lungs.set_breath_state(lungs.BREATH_STATE.SNEEZE)
	
	if randf() < fit_probability:
		print("Fit started")
		fit_timer.start(randf_range(fit_window_seconds.x, fit_window_seconds.y))

func sneeze_finished():
	lungs.set_breath_state(lungs.BREATH_STATE.IDLE)
	
func hold_breath():
	lungs.set_breath_state(lungs.BREATH_STATE.HOLD)

func breathe_out():
	lungs.set_breath_state(lungs.BREATH_STATE.OUT)
	
func sneeze_trigger(value):
	sneeze_trigger_count.add_value(value)
	
func want_breathe(weight : float):
	if randf() < weight:
		print("Want Breathe Started")
		lungs.set_breath_state(lungs.BREATH_STATE.IN)
		
func must_breathe():
	print("Must Breathe Started")
	lungs.set_breath_state(lungs.BREATH_STATE.IN)
