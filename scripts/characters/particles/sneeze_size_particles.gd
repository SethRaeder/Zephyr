extends GPUParticles2D
class_name SneezeSizeDrivenParticles

@export var update_on_sneeze : bool = true
@export var emit_on_breathe : bool = false
var timer : Timer

@export var control_curve : Curve

func _ready() -> void:
	#Wait for nodes to initialize
	await get_tree().process_frame
	
	#Link to brain
	var brain = get_tree().get_first_node_in_group("brain")
	if brain is Brain:
		if update_on_sneeze:
			brain.on_sneeze.connect(func():
				emitting = false
				amount_ratio = brain.sneeze_size.get_percent() * control_curve.sample_baked(brain.control_count.get_percent())
			)
			brain.on_build.connect(func():
				emitting = false
			)
			brain.on_hitch.connect(func():
				emitting = false
			)
			brain.on_sniff.connect(func():
				emitting = false
			)
			brain.on_sigh.connect(func():
				emitting = false
			)
		else:
			if emit_on_breathe:
				emitting = true
				var lungs = get_tree().get_first_node_in_group("lungs")
				if lungs is Lungs:
					lungs.breathe_rate.connect(func(rate):
						#print("Particles update on breathe: %s"%rate)
						if rate < 0:
							amount_ratio = brain.sneeze_trigger_count.get_percent() * control_curve.sample_baked(brain.control_count.get_percent())
							#print("Amount ratio: %s"%amount_ratio)
						else:
							amount_ratio = 0.0
					)
			else:
				emitting = true
				timer = Timer.new()
				add_child(timer)
				timer.start(0.5)
				timer.timeout.connect(func():
					amount_ratio = brain.sneeze_trigger_count.get_percent() * control_curve.sample_baked(brain.control_count.get_percent())
				)
