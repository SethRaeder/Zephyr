extends Node2D
class_name EnableOnBreatheComponent

enum BREATHE_TYPE {IN, OUT, BOTH}
##Which breathe type should this be enabled on?
@export var enabled_on_breath_type : BREATHE_TYPE = BREATHE_TYPE.IN

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	for node in get_tree().get_nodes_in_group("lungs"):
		if node is Lungs:
			node.breathe_rate.connect(on_breathe)
			
func on_breathe(rate : float):
	if rate > 0:
		match enabled_on_breath_type:
			BREATHE_TYPE.IN, BREATHE_TYPE.BOTH:
				get_parent().set_process(true)
				get_parent().set_physics_process(true)
			_:
				get_parent().set_process(false)
				get_parent().set_physics_process(false)

	elif rate < 0:
		match enabled_on_breath_type:
			BREATHE_TYPE.OUT, BREATHE_TYPE.BOTH:
				get_parent().set_process(true)
				get_parent().set_physics_process(true)
			_:
				get_parent().set_process(false)
				get_parent().set_physics_process(false)
	
	else:
		get_parent().set_process(false)
		get_parent().set_physics_process(false)
