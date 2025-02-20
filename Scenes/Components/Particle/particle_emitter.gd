extends Node2D
class_name ParticleEmitter

@export var particle_scene : PackedScene

@export_category("Use Jerk Release")
@export var release_on_jerk : bool = false
@export var jerk_accelerate : bool = false
@export var jerk_decelerate : bool = true
@export var jerk_threshold : float = 10000
@export var jerk_speed_max : float = 100000
@export var jerk_particle_amount : int = 1
@export var jerk_particle_variance : Vector2 = Vector2.ONE

@export_category("Use Velocity Release")
@export var release_on_speed : bool = true
@export var particle_spawn_max_speed : float= 2000.0
@export var particle_spawn_velocity_curve : Curve = preload("res://Resources/Curves/default_particle_spawn_curve.tres")

@export_category("Particle Spawn Settings")
@export var particle_spawn_radius : float = 10
@export var particle_spawn_force_max : float = 50
@export var particle_spawn_rotation_max : float = 2.5
@export var particle_size_var_range : Vector2 = Vector2(0.5,2.0)
@export var particle_max_count : int = 100

@export var particle_spawn_lifetime_limit : int = -1
var particle_spawn_lifetime_count : int = 0

var particle_count = 0
var last_velocity := Vector2.ZERO

var particle_array = []

var emission_enabled : bool = true

signal particles_exhausted()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for node : ToolParticle in get_tree().get_nodes_in_group("tool_particles"):
		if node.scene_file_path == particle_scene.resource_path:
			particle_count += 1
			particle_array.append(node)
			
	var parent : SneezeTool = get_parent()
	
	particle_max_count = int(float(particle_max_count) * ZephyrGlobals.particle_tool_max_multiplier)
	parent.move.connect(on_move)

func on_move(velocity : Vector2, delta : float):
	if not emission_enabled:
		return

	if release_on_jerk:
		var delta_dot = (last_velocity.dot(velocity))
		var jerk_speed = clampf((velocity - last_velocity).length() / delta, 0.0, jerk_speed_max)
		#print(jerk_speed)
		if ((delta_dot > 0 and jerk_accelerate) and (jerk_speed >= jerk_threshold)) or ((delta_dot < 0 and jerk_decelerate) and (jerk_speed >= jerk_threshold)):
			var spawn_count = int(jerk_particle_amount * randf_range(jerk_particle_variance.x,jerk_particle_variance.y))
			for i in range(spawn_count):
				spawn_particle()
	if release_on_speed:
		var current_speed = clampf(velocity.length(), 0.0, particle_spawn_max_speed)
		var sample = particle_spawn_velocity_curve.sample(current_speed / particle_spawn_max_speed)
		if randf() < sample:
			spawn_particle()
	
	last_velocity = velocity

func spawn_particle():
	if not emission_enabled:
		return
		
	if particle_spawn_lifetime_limit > 0:
		particle_spawn_lifetime_count += 1
		if particle_spawn_lifetime_count > particle_spawn_lifetime_limit:
			particles_exhausted.emit()
			return

		elif particle_spawn_lifetime_count == particle_spawn_lifetime_limit:
			particles_exhausted.emit()
	
	particle_count += 1
	
	if particle_count >= particle_max_count:
		var to_delete = particle_array.pop_front()
		if is_instance_valid(to_delete):
			to_delete.queue_free()
		
	var new_particle : ToolParticle = particle_scene.instantiate()
	get_tree().root.add_child(new_particle)
	
	particle_array.append(new_particle)
	ZephyrGlobals.add_particle(new_particle)

	new_particle.particle_die.connect(on_particle_die)
	new_particle.sprite.scale *= randf_range(particle_size_var_range.x, particle_size_var_range.y)
	
	var position_offset = Vector2.RIGHT.rotated(randf_range(0,2 * PI)) * (particle_spawn_radius * randf())
	new_particle.global_position = global_position + position_offset
	new_particle.rotation = randf_range(0,2 * PI)
	
	new_particle.apply_central_force(Vector2.RIGHT.rotated(randf_range(0,2*PI)) * (particle_spawn_force_max * randf()))
	new_particle.angular_velocity = (particle_spawn_rotation_max * randf_range(-1,1))
	
	if get_parent().inserted:
		for child in new_particle.get_children(true):
			if child is TickleComponent:
				if child.tickle_damage_limit > 0:
					child.intensity *= 10
				child.set_collision_mask_value(8, true)

func on_particle_die(particle : ToolParticle):
	particle_count -= 1
	particle_array.remove_at(particle_array.find(particle))
	
	
