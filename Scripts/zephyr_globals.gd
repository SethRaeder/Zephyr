extends Node

var particle_tool_max_multiplier = 0.1
var particle_global_max = 250
var particle_array = []

func add_particle(particle : ToolParticle):
	particle_array.append(particle)
	if particle_array.size() > particle_global_max:
		var to_remove : ToolParticle = particle_array.pop_front()
		if is_instance_valid(to_remove):
			to_remove.queue_free()
