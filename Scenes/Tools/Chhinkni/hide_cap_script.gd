extends Sprite2D

@onready var particle_emitter: ParticleEmitter = %CapParticle

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	particle_emitter.particles_exhausted.connect(func():
		hide()
	)
