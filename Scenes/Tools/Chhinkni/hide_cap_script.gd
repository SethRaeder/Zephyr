extends Sprite2D

@onready var cap_emitter: ParticleEmitter = %CapParticle
@onready var particles: ParticleEmitter = %Particles

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	particles.emission_enabled = false
		
	cap_emitter.particles_exhausted.connect(func():
		hide()
		particles.emission_enabled = true
	)
