extends Node2D
class_name Brain

@export var lungs: Lungs
@export var voice: VoiceBox

@export var hitch_curve : Curve
@export var buildup_curve : Curve
@export var sneeze_curve : Curve
@onready var animation_tree: AnimationTree = %AnimationTree
@onready var update_timer: Timer = $UpdateTimer

var idletickleblend := 0.0

var hitch := false
var buildup := false
var sneeze := false

var sneeze_trigger_count := 0.0
@export var sneeze_trigger_target := 20.0
@export var tickle_max := 8.0
var sneeze_trigger_max := sneeze_trigger_target*2


@export var update_timer_base_time := 0.25
@export var update_timer_max_variance := 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_tree.set("parameters/Blink Shot/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	animation_tree.set("parameters/Earflick Shot/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
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
	voice.sneeze_finished.connect(hold_breath)
	voice.hitch_finished.connect(hold_breath)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	idletickleblend = lerpf(idletickleblend, clamp(float(sneeze_trigger_count/tickle_max), 0.0, 1.0), delta)
	
	sneeze_trigger_count = clamp(sneeze_trigger_count - delta * 0.2,0.0,sneeze_trigger_max)
	animation_tree.set("parameters/SneezeMachine/IdleTickle/blend_position",idletickleblend)

func timer_timeout():
	update_timer.wait_time = update_timer_base_time + randf_range(0.0,update_timer_max_variance)
	#print("<Brain> Sneeze trigger: ",sneeze_trigger_count)
	#print("<Brain> IdleTickleBlend: ",idletickleblend)
	var sneeze_percent = clampf(sneeze_trigger_count/sneeze_trigger_target,0.0,1.0)
	if randf() < hitch_curve.sample(sneeze_percent):
		if not lungs.is_full():
			hitch = true
	if randf() < buildup_curve.sample(sneeze_percent):
		if not lungs.is_full():
			buildup = true
	if randf() < sneeze_curve.sample(sneeze_percent):
		sneeze = true
	
	animation_tree.set("parameters/SneezeMachine/conditions/sneeze",sneeze)
	animation_tree.set("parameters/SneezeMachine/conditions/buildup",buildup)
	animation_tree.set("parameters/SneezeMachine/conditions/hitch",hitch)
	
	hitch = false
	buildup = false
	sneeze = false

func on_hitch():
	print("Brain: On Hitch")
	lungs.set_breath_state(lungs.BREATH_STATE.HITCH)
	
func on_sneeze():
	sneeze_trigger_count = clampf(sneeze_trigger_count - (sneeze_trigger_target), 0, sneeze_trigger_max);
	lungs.set_breath_state(lungs.BREATH_STATE.SNEEZE)
	
func hold_breath():
	lungs.set_breath_state(lungs.BREATH_STATE.HOLD)
	
func sneeze_trigger():
	sneeze_trigger_count += 1
	
func want_breathe(weight : float):
	if randf() < weight:
		print("Want Breathe Started")
		lungs.set_breath_state(lungs.BREATH_STATE.IN)
		
func must_breathe():
	print("Must Breathe Started")
	lungs.set_breath_state(lungs.BREATH_STATE.IN)
