extends GPUParticles2D
class_name WetnessDrivenParticles

var nose_zones : Array[NoseTriggerZone]
var update_timer : Timer

@export var update_interval : float = 0.5

var max_wetness : float = 0.0
var wet_ratio : float = 0.0

func _ready() -> void:
	#Wait for nodes to initialize
	await get_tree().process_frame
	
	#Link to brain
	var brain = get_tree().get_first_node_in_group("brain")
	if brain is Brain:
		brain.on_sneeze.connect(func():
			amount_ratio = wet_ratio * brain.sneeze_size
		)
	
	#Get all nose triggers in tree
	for nose in get_tree().get_nodes_in_group("nose"):
		if nose is NoseTriggerZone:
			nose_zones.append(nose)
			max_wetness += nose.nose_wetness.max_value
	
	#Add timer for updating emission amount ratio
	update_timer = Timer.new()
	update_timer.autostart = true
	update_timer.wait_time = update_interval
	add_child(update_timer)
	
	update_timer.timeout.connect(func():
		wet_ratio = 0.0
		for nose in nose_zones:
			wet_ratio += nose.nose_wetness.current_value
		wet_ratio /= max_wetness
	)
