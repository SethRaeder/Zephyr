extends RigidBody2D
class_name ToolParticle

@export var particle_lifetime : float = 10.0
@export var particle_lifetime_variance : Vector2 = Vector2(0.5,1.0)

@export var delete_on_tickle_finished : bool = false

var lifetime : float = 0.0

var tickle_components = []
var sprite : Sprite2D
var wind_subscriber : WindSubscriber

signal particle_die()
@export var particle_air_limit : float = 200.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("tool_particles")
	particle_lifetime *= randf_range(particle_lifetime_variance.x, particle_lifetime_variance.y)
	
	for child in get_children(true):
		if child is TickleComponent:
			tickle_components.append(child)
		if child is Sprite2D:
			sprite = child
		if child is WindSubscriber:
			wind_subscriber = child


func _physics_process(delta: float) -> void:
	var delete_me = delete_on_tickle_finished
		
	if tickle_components.size() > 0:
		for child : TickleComponent in tickle_components:
			if child.tickle_damage_limit > 0:
				child.total_tickle_damage += child.tickle_damage_limit / particle_lifetime * delta
				
				if delete_me and child.total_tickle_damage / child.tickle_damage_limit < 1:
					#If we haven't exceeded the limit on all components yet, don't delete!
					delete_me = false
					
	lifetime += delta
	if lifetime >= particle_lifetime and particle_lifetime > 0:
		delete_me = true
	
	if delete_me:
		particle_die.emit(self)
		if is_instance_valid(self):
			queue_free()
		return
		
	if wind_subscriber:
		##Handle wind stuffs
		var force = wind_subscriber.wind_vector * delta
		force = force.limit_length(40.0)
		##Simulate air resistance.
		force += Vector2.ZERO.lerp(linear_velocity * -1 * delta, linear_velocity.length() / particle_air_limit)
		apply_central_force(force)
		
		 
