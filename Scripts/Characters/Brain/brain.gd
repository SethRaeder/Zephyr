extends Node
class_name Brain

@export_category("Node References")
@export var lungs: Lungs
@export var voice: VoiceBox
@export var animation_tree: AnimationTree

@export_category("Curves")
##Define the chances of hitch animation playing depending on sneeze level
@export var hitch_curve : Curve
##Define the chances of buildup animation playing depending on sneeze level
@export var buildup_curve : Curve
##Define the chances of sneeze animation playing depending on sneeze level
@export var sneeze_curve : Curve
##Define the transition blend to the "tickle" expression
@export var tickle_curve : Curve

##How many sneeze triggers is needed to reach max sneeze level?
@export var sneeze_trigger_target : float = 20.0
##How many seconds to decay sneeze trigger to zero?
@export var sneeze_trigger_decay_seconds : float = 20.0
##How many sneeze triggers to remove on sneeze
@export var sneeze_trigger_expel : float = 5
##How often to check for animation transitions
@export var update_timer_base_time := 0.25
##Variance in the update timer, from 0 seconds to value seconds
@export var update_timer_max_variance := 1.0

@export_category("Animation Modifiers")
##Modifier to chance to play a hitch while waiting in the hitch interrupt state
@export var hitch_repeat_modifier : CustomBoundedValue
##Modifier to chance to play a buildup while waiting in the buildup interrupt state
@export var buildup_repeat_modifier : CustomBoundedValue
##Modifier to chance to play a sneeze while waiting in the sneeze interrupt state
@export var sneeze_repeat_modifier : CustomBoundedValue

@export_category("Fits")
##How likely to have a fit? Max 1.0
@export var fit_probability : float = 0.3
##How many seconds should a fit last? From X to Y seconds
@export var fit_window_seconds : Vector2 = Vector2(5.0, 20.0)
##How much to boost sneeze level while in a fit?
@export var fit_sneeze_bonus : float = 1.5
##How much to modify sneeze trigger removal while in a fit?
@export var fit_trigger_count_mult : float = 1

#Local node references
@onready var update_timer: Timer = %UpdateTimer
@onready var fit_timer: Timer = %FitTimer
@onready var anim_timeout_timer: Timer = %AnimTimeoutTimer

var sneeze_trigger_count := CustomBoundedValue.new()

@onready var sneeze_decay_rate : float = -sneeze_trigger_target / sneeze_trigger_decay_seconds
var idletickleblend := 0.0
var sneeze_size : float = 1.0
var anim_parameters = {
	"hitch": false,
	"hitch_interrupt": false,
	"buildup": false,
	"buildup_interrupt": false,
	"sneeze": false,
	"sneeze_interrupt": false,
	"sigh": false,
	"sigh_interrupt": false,
	"sniff": false,
	"sniff_interrupt": false,
}

var is_hitching : bool = false
var is_building : bool = false
var is_sneezing : bool = false
var is_sighing : bool = false
var is_sniffing : bool = false

signal on_hitch()
signal on_build()
signal on_sneeze()
signal on_sigh()
signal on_sniff()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sneeze_trigger_count.name = "Sneeze Trigger Count"
	sneeze_trigger_count.max_value = sneeze_trigger_target
	
	animation_tree.set("parameters/Blink Shot/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	animation_tree.set("parameters/Earflick Shot/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
	animation_tree.connect("animation_finished",_on_animation_finished)
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
	
	lungs.want_breathe.connect(do_want_breathe)
	lungs.must_breathe.connect(do_must_breathe)
	
	#Attach all nose hitbox zones to the brain control
	for node in get_tree().get_nodes_in_group("nose"):
		if node is NoseTriggerZone:
			print("<BRAIN> Added Nose Trigger Zone ",node)
			node.sneeze_trigger.connect(sneeze_trigger)
			voice.on_sneeze.connect(node.on_sneeze)
	
	update_timer.timeout.connect(timer_timeout)
	
	voice.on_hitch.connect(do_hitch)
	voice.on_buildup.connect(do_buildup)
	voice.on_sneeze.connect(do_sneeze)
	
	voice.on_sneeze_finished.connect(func():
		anim_timeout_timer.start()
		await anim_timeout_timer.timeout
		sneeze_finished()
	)
	voice.on_buildup_finished.connect(func():
		anim_timeout_timer.start()
		await anim_timeout_timer.timeout
		buildup_finished()
	)
	voice.on_hitch_finished.connect(func():
		anim_timeout_timer.start()
		await anim_timeout_timer.timeout
		hitch_finished()
	)
	voice.on_sigh_finished.connect(func():
		anim_timeout_timer.start()
		await anim_timeout_timer.timeout
		sigh_finished()
	)
	voice.on_sniff_finished.connect(func():
		anim_timeout_timer.start()
		await anim_timeout_timer.timeout
		sniff_finished()
	)
	
	animation_tree.active = true
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	idletickleblend = lerpf(idletickleblend, get_tickle_percent(), delta)
	
	sneeze_trigger_count.add_value(delta * sneeze_decay_rate)
	animation_tree.set("parameters/Parameter Animation/IdleTickle/blend_position", idletickleblend)
	
	#print("Hitch amount: ",hitch_curve.sample_baked(sneeze_trigger_count.get_percent()))

func get_tickle_percent() -> float:
	return clampf(tickle_curve.sample_baked(sneeze_trigger_count.get_percent() * (1.0 if fit_timer.is_stopped() else fit_sneeze_bonus)), 0.0, 1.0)

func timer_timeout():
	anim_parameters["hitch"] = false
	anim_parameters["buildup"] = false
	anim_parameters["sneeze"] = false
	anim_parameters["sigh"] = false
	anim_parameters["sniff"] = false
	
	update_timer.wait_time = update_timer_base_time + randf_range(0.0,update_timer_max_variance)
	#print("<Brain> Sneeze trigger: ",sneeze_trigger_count)
	#print("<Brain> IdleTickleBlend: ",idletickleblend)
	var sneeze_percent = sneeze_trigger_count.get_percent()
	
	if randf() < hitch_curve.sample(sneeze_percent) * (hitch_repeat_modifier.current_value if is_hitching else 1.0):
		if not lungs.is_full():
			anim_parameters["hitch"] = true
		else:
			anim_parameters["sigh"] = true
	
	if randf() < buildup_curve.sample(sneeze_percent) * (1.0 if fit_timer.is_stopped() else fit_sneeze_bonus) * (buildup_repeat_modifier.current_value if is_building else 1.0):
		if not lungs.is_full():
			anim_parameters["buildup"] = true
		else:
			anim_parameters["sigh"] = true
			
	if randf() < sneeze_curve.sample(sneeze_percent) * (1.0 if fit_timer.is_stopped() else fit_sneeze_bonus) * (sneeze_repeat_modifier.current_value if is_sneezing else 1.0):
		anim_parameters["sneeze"] = true
		
	if randf() < 0.1 : 
		anim_parameters["sigh"] = true
	
	if randf() < 0.2 and sneeze_percent > 0.5: 
		anim_parameters["sniff"] = true

func reset_tracker_params():
	is_hitching = false
	is_building = false
	is_sneezing = false
	is_sighing = false
	is_sniffing = false
	anim_parameters["hitch_interrupt"] = false
	anim_parameters["buildup_interrupt"] = false
	anim_parameters["sneeze_interrupt"] = false
	anim_parameters["sigh_interrupt"] = false
	anim_parameters["sniff_interrupt"] = false

func _on_animation_finished(animation_name : StringName):
	#print("On anim finished... ",animation_name)
	match animation_name:
		"hitch", "sneeze", "buildup":
			reset_tracker_params()

func on_hitch_anim():
	reset_tracker_params()
	is_hitching = true

func on_buildup_anim():
	reset_tracker_params()
	is_building = true

func on_sneeze_anim():
	reset_tracker_params()
	is_sneezing = true
	sneeze_size = 1.0

func on_sigh_anim():
	reset_tracker_params()
	is_sighing = true

func on_sniff_anim():
	reset_tracker_params()
	is_sniffing = true
	#TODO: Reduce "mess" after mess implemented
	
func do_hitch():
	lungs.set_breath_state(lungs.BREATH_STATE.HITCH)
	
func do_buildup():
	lungs.set_breath_state(lungs.BREATH_STATE.BUILDUP)
	
func do_sneeze():
	on_sneeze.emit()
	lungs.set_breath_state(lungs.BREATH_STATE.SNEEZE)
	
	if randf() < fit_probability:
		print("Fit started")
		fit_timer.start(randf_range(fit_window_seconds.x, fit_window_seconds.y))
	
	if fit_timer.is_stopped():
		sneeze_trigger_count.add_value(-sneeze_trigger_expel * sneeze_size)
	else:
		sneeze_trigger_count.add_value(-sneeze_trigger_expel * fit_trigger_count_mult * sneeze_size)

func sneeze_finished():
	print("Sneeze Interrupt")
	anim_parameters["sneeze_interrupt"] = true

func hitch_finished():
	print("Hitch Interrupt")
	anim_parameters["hitch_interrupt"] = true

func buildup_finished():
	print("Buildup Interrupt")
	anim_parameters["buildup_interrupt"] = true

func sigh_finished():
	print("Sigh Interrupt")
	anim_parameters["sigh_interrupt"] = true

func sniff_finished():
	print("Sniff Interrupt")
	anim_parameters["sniff_interrupt"] = true
	
func sneeze_trigger(value):
	sneeze_trigger_count.add_value(value)
	
func do_want_breathe(weight : float):
	if randf() < weight:
		print("Want Breathe Started")
		lungs.set_breath_state(lungs.BREATH_STATE.IN)
		
func do_must_breathe():
	print("Must Breathe Started")
	lungs.set_breath_state(lungs.BREATH_STATE.IN)

func send_sliders(container : DebugUIContainer):
	container.add_new_header(name + " Settings", "Settings for various brain functions")
	container.add_new_slider(sneeze_trigger_count, "Determines chance of hitch/buildup/sneeze")
	container.add_new_slider(hitch_repeat_modifier, "Modifies chance of hitching again after hitch")
	container.add_new_slider(buildup_repeat_modifier, "Modifies chance of buildup again after buildup")
	container.add_new_slider(sneeze_repeat_modifier, "Modifies chance of sneeze again after sneeze")

func send_curves(container : DebugUIContainer):
	container.add_new_header(name + " Curves", "Curve thresholds for various brain functions")
	container.add_new_curve("Hitch Curve",hitch_curve)
	container.add_new_curve("Buildup Curve",buildup_curve)
	container.add_new_curve("Sneeze Curve",sneeze_curve)
	container.add_new_curve("Tickle Curve",tickle_curve)
