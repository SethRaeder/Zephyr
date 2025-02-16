extends Node2D
class_name Brain

@export var lungs: Lungs
@export var voice: VoiceBox

@export var hitch_curve : Curve
@export var buildup_curve : Curve
@export var sneeze_curve : Curve
@onready var animation_tree: AnimationTree = %AnimationTree
@onready var update_timer: Timer = $UpdateTimer
@onready var fit_timer: Timer = $FitTimer

var idletickleblend := 0.0

var hitch := false
var buildup := false
var sneeze := false
var sigh := false

var sneeze_trigger_count := 0.0
@export var sneeze_trigger_target : float = 20.0
@export var tickle_max := 8.0

@export var sneeze_trigger_expel : float = 5

@export var update_timer_base_time := 0.25
@export var update_timer_max_variance := 1.0

@export var fit_probability : float = 0.3
@export var multiple_sneeze_window_seconds : Vector2 = Vector2(5.0, 20.0)
@export var sneeze_multiples_bonus : float = 2.0

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
	voice.sneeze_finished.connect(breathe_out)
	voice.hitch_finished.connect(hold_breath)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	idletickleblend = lerpf(idletickleblend, clamp(float(sneeze_trigger_count * (1.0 if fit_timer.is_stopped() else sneeze_multiples_bonus) /tickle_max), 0.0, 1.0), delta)
	
	sneeze_trigger_count = clamp(sneeze_trigger_count - delta * 0.2,0.0,sneeze_trigger_target)
	animation_tree.set("parameters/SneezeMachine/IdleTickle/blend_position",idletickleblend)

func timer_timeout():
	update_timer.wait_time = update_timer_base_time + randf_range(0.0,update_timer_max_variance)
	#print("<Brain> Sneeze trigger: ",sneeze_trigger_count)
	#print("<Brain> IdleTickleBlend: ",idletickleblend)
	var sneeze_percent = clampf(sneeze_trigger_count/sneeze_trigger_target,0.0,1.0)
	if randf() < hitch_curve.sample(sneeze_percent):
		if not lungs.is_full():
			hitch = true
		else:
			sigh = true
	if randf() < buildup_curve.sample(sneeze_percent) * (1.0 if fit_timer.is_stopped() else sneeze_multiples_bonus):
		if not lungs.is_full():
			buildup = true
		else:
			sigh = true
	if randf() < sneeze_curve.sample(sneeze_percent) * (1.0 if fit_timer.is_stopped() else sneeze_multiples_bonus):
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
	sneeze_trigger_count = clampf(sneeze_trigger_count - (sneeze_trigger_expel * sneeze_size), 0, sneeze_trigger_target);
	lungs.set_breath_state(lungs.BREATH_STATE.SNEEZE)
	
	if randf() < fit_probability:
		print("Fit started")
		fit_timer.start(randf_range(multiple_sneeze_window_seconds.x, multiple_sneeze_window_seconds.y))
	
func hold_breath():
	lungs.set_breath_state(lungs.BREATH_STATE.HOLD)

func breathe_out():
	lungs.set_breath_state(lungs.BREATH_STATE.OUT)
	
func sneeze_trigger():
	sneeze_trigger_count += 1
	
func want_breathe(weight : float):
	if randf() < weight:
		print("Want Breathe Started")
		lungs.set_breath_state(lungs.BREATH_STATE.IN)
		
func must_breathe():
	print("Must Breathe Started")
	lungs.set_breath_state(lungs.BREATH_STATE.IN)
