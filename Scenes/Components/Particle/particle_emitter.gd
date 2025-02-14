extends Node2D
class_name ParticleEmitter

@export var particle_scene : PackedScene

@export var particle_spawn_max_speed : float= 2000.0
@export var particle_spawn_velocity_curve : Curve = preload("res://default_particle_spawn_curve.tres")
@export var particle_spawn_radius : float = 10
@export var particle_spawn_force_max : float = 50
@export var particle_spawn_rotation_max : float = 2.5
@export var particle_size_var_range : Vector2 = Vector2(0.5,2.0)
@export var particle_max_count : int = 100

var particle_count = 0
var last_velocity := Vector2.ZERO

var particle_array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for node : ToolParticle in get_tree().get_nodes_in_group("tool_particles"):
		if node.scene_file_path == particle_scene.resource_path:
			particle_count += 1
			particle_array.append(node)
			
	var parent : SneezeTool = get_parent()
	parent.move.connect(on_move)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_move(velocity : Vector2):
	#print("Hello?")
	var current_speed = clampf((velocity - last_velocity).length(), 0.0, particle_spawn_max_speed)
	
	var sample = particle_spawn_velocity_curve.sample(current_speed / particle_spawn_max_speed)
	if randf() < sample:
		spawn_particle()

func spawn_particle():
	if particle_count >= particle_max_count:
		var to_delete = particle_array.pop_front()
		if is_instance_valid(to_delete):
			to_delete.queue_free()
		
	var new_particle : ToolParticle = particle_scene.instantiate()
	get_tree().root.add_child(new_particle)
	
	particle_array.append(new_particle)
	
	particle_count += 1
	new_particle.particle_die.connect(on_particle_die)
	new_particle.sprite.scale *= randf_range(particle_size_var_range.x, particle_size_var_range.y)
	
	var position_offset = Vector2.RIGHT.rotated(randf_range(0,2 * PI)) * (particle_spawn_radius * randf())
	new_particle.global_position = global_position + position_offset
	new_particle.rotation = randf_range(0,2 * PI)
	
	new_particle.apply_central_force(Vector2.RIGHT.rotated(randf_range(0,2*PI)) * (particle_spawn_force_max * randf()))
	new_particle.angular_velocity = (particle_spawn_rotation_max * randf_range(-1,1))

func on_particle_die(particle : ToolParticle):
	particle_count -= 1
	particle_array.remove_at(particle_array.find(particle))
	
	
