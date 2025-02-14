extends Sprite2D

#var gravity:Vector2 = Vector2(0,-100)

var particleType : Particle_Resource

var velocity: Vector2 = Vector2(0,0)
var health
var toScale
var angVelocity

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setup(type):
	particleType = type
	health = particleType.HP * randf_range(0.5,1.0)
	toScale = Vector2(particleType.size,particleType.size)
	scale = (health / particleType.HP) * toScale / 10
	rotation = randf_range(0,2*PI)
	angVelocity = randf_range(-.5,.5)
	modulate = particleType.color
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#velocity += gravity * delta
	velocity -= velocity * delta * 0.5
	position += velocity * delta
	rotation += angVelocity * delta
	health -= delta
	scale = lerp(scale,(health / particleType.HP) * toScale,delta*2)
	modulate.a = (health / particleType.HP) * particleType.color.a
	if(health <= 0.1):
		queue_free()
	
func breathe(breathPoint: Vector2, breathVector:Vector2, breathSpeed: float, delta):	
	var distance = global_position.distance_to(breathPoint)
	var healthLost = particleType.HP * delta * breathSpeed / (distance) 
	var toRet = Vector2.ZERO
	
	velocity += breathSpeed * position.direction_to(breathPoint) / (distance * (health / particleType.HP) * particleType.mass)
	#if distance < 10 and health < 10 and breathSpeed > 0:
	#	healthLost = health
		
	if(breathSpeed > 0):
		health -= healthLost
		#Globals.addParticle(particleType, healthLost);

func getParticleType():
	return particleType
