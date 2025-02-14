extends Node2D

var particle = preload("res://Scenes/old_project/Tools/ToolParticle.tscn")
var enable = false

@export var spawnRate : int
@export var useVelocity : bool
@export var velocityCurve : Curve
@export var maxSpeed : int = 50

var particleProgress = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func spawnParticle(type, bonusVelocity, spawnPosition):
	var newParticle = particle.instantiate()
	
	for i in range(Globals.PARTICLETYPES.size()):
		var test = Globals.PARTICLETYPES[i]
		if(test.particle_name == type):
			type = test
			break
			
	newParticle.setup(type)
	
	newParticle.global_position = spawnPosition
	newParticle.velocity = Vector2.from_angle(randf_range(0,2*PI)) * randf_range(10,50) + bonusVelocity
	newParticle.position += newParticle.velocity * 1
	get_tree().get_root().add_child(newParticle)
	
