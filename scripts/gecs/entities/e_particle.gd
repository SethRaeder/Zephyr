@tool
class_name Particle
extends Entity

func on_ready():
	# Sync the entity's scene position to the Transform component
	if has_component(C_Transform):
		var c_trs = get_component(C_Transform) as C_Transform
		c_trs.position = self.global_position
	if has_component(C_Velocity):
		var c_vel = get_component(C_Velocity) as C_Velocity
		c_vel.velocity = Vector2(randf_range(-5,5),randf_range(-5,5))
