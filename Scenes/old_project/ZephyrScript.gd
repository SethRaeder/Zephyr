extends Node2D
@onready var motion = $"Motion Animations"
@onready var animTree: AnimationTree = $AnimationTree
var blend: AnimationNodeBlendTree

var enableBlink = true
var blinkQueued = false
var spawn = 0
var sneezing = false
var desiredVal = 0.0

var tickleAmount = 0
var sneezePower = 0
var sneezeTarget = 0

enum STATES {idle,hitch,sneeze}
var state = STATES.idle

# Called when the node enters the scene tree for the first time.
func _ready():
	#desired = 0.0
	spawn = 0
	#expression.play("RESET")
	
	animTree.active = true
	#blend = $AnimationTree.get("parameters/playback")
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(state)
	var tickle = animTree.get("parameters/tickleblend/blend_position")
	var hitch = animTree.get("parameters/hitchblend/blend_amount")
	var sneeze = animTree.get("parameters/sneezeblend/blend_amount")
	tickle = lerpf(tickle, tickleAmount, delta/.25)
	sneezeTarget = lerpf(sneezeTarget,0,delta/2.0)
	
	match(state):
		STATES.idle:
			hitch = lerpf(hitch, 0, delta/.5)
			sneeze = lerpf(sneeze, 0, delta/.5)
		STATES.hitch:
			hitch = lerpf(hitch, 1, delta/0.5)
			sneeze = lerpf(sneeze, 0, delta/0.15)
		STATES.sneeze:
			hitch = lerpf(hitch, 0, delta/0.75)
			sneeze = lerpf(sneeze, sneezeTarget, delta/.5)
	
	animTree.set("parameters/tickleblend/blend_position",tickle)
	animTree.set("parameters/hitchblend/blend_amount",hitch)
	animTree.set("parameters/sneezeblend/blend_amount",sneeze)
	animTree.set("parameters/squintblend/blend_position",tickle)

	
func _on_sneeze_manager_idle():	
	#print("recieve idle")
	state = STATES.idle
	tickleAmount = 0
	animTree.set("parameters/expression/transition_request","idle")

	
func _on_sneeze_manager_tickle(val):	
	#print("recieve tickle")
	state = STATES.idle
	tickleAmount = val
	animTree.set("parameters/expression/transition_request","tickle")

	
func _on_sneeze_manager_hitch(wait):
	print("====> Recieved hitch, ",wait)
	state = STATES.hitch
	var sm = animTree.get("parameters/hitchStateMachine/playback")
	

	if(wait):
		animTree.set("parameters/expression/transition_request","hitchwait")
		animTree.get("parameters/hitchStateMachine/playback").travel("hitchwait")

	else:
		animTree.set("parameters/expression/transition_request","hitch")
		var i = animTree.get("parameters/hitchStateMachine/playback").get_current_node()
		#print(i)
		if(i == "hitch"):
			i = "hitch 2"
		else:
			i = "hitch"
		#print(i)
		animTree.get("parameters/hitchStateMachine/playback").travel(i)

func _on_sneeze_manager_sneeze(val):
	print("=====> Recieved sneeze ",val)
	state = STATES.sneeze
	sneezeTarget = clampf(val,0.25,1.0)
	var i = animTree.get("parameters/sneezeToggle/current_state")
	if(i == "0"):
		i = "1"
	else:
		i = "0"
	print("Playing Sneeze Animation ", i)
	animTree.set("parameters/sneezeToggle/transition_request",i)
	animTree.set("parameters/expression/transition_request","sneeze")

func _on_blink_timer_timeout():
	motion.play("blink",-1,randf_range(0.5,1.5))
