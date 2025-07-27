extends GPUParticles2D
class_name SneezeSizeDrivenParticles

func _ready() -> void:
	#Wait for nodes to initialize
	await get_tree().process_frame
	
	#Link to brain
	var brain = get_tree().get_first_node_in_group("brain")
	if brain is Brain:
		brain.on_sneeze.connect(func():
			amount_ratio = brain.sneeze_size
		)
