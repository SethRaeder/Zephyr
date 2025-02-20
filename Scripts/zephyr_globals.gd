extends Node

var particle_tool_max_multiplier = 1.0
var particle_global_max = 100
var particle_array = []

func add_particle(particle : ToolParticle):
	particle_array.append(particle)
	if particle_array.size() > particle_global_max:
		if is_instance_valid(particle_array[0]):
			var to_remove = particle_array.pop_front()
			to_remove.queue_free()
