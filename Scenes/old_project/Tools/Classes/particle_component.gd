extends Area2D

var particle = preload("res://Scenes/old_project/Tools/ToolParticle.tscn")
var enable = false

@export var spawn_on_breath : bool = false

@export var spawnRate : int
@export var particleResource : Particle_Resource
@export var useVelocity : bool
@export var velocityCurve : Curve
@export var maxSpeed : int = 1500

var particleProgress = 0.0

func _physics_process(delta):
	var velocity = get_parent().linear_velocity
	#print("DEBUG: PArticle Velocity: ",velocity.length())
	
	if useVelocity:
		var sample = velocityCurve.sample(velocity.length() / maxSpeed)
		particleProgress += sample * spawnRate * delta
	
	else:
		particleProgress += spawnRate * delta
	
	while particleProgress > 1:
		#print("DEBUG: ParticlePRogress: ",particleProgress)
		particleProgress -= 1
		spawnParticle(particleResource,velocity.normalized()*150,global_position)

func spawnParticle(type, bonusVelocity, spawnPosition):
	var newParticle = particle.instantiate()
	
	newParticle.setup(particleResource)
	
	newParticle.global_position = spawnPosition
	newParticle.velocity = Vector2.from_angle(randf_range(0,2*PI)) * randf_range(10,50) + bonusVelocity
	#newParticle.position += newParticle.velocity * 1
	get_tree().get_root().add_child(newParticle)
	
