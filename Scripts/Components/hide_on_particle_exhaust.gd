extends Node
class_name HideOnParticleExhaust

@export var particle_emitter: ParticleEmitter

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	particle_emitter.particles_exhausted.connect(func():
		get_parent().hide()
	)
