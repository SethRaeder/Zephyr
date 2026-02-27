extends System
class_name S_Movement

func query() -> QueryBuilder:
	return q.with_all([C_Transform,C_Velocity]).with_none([C_CharacterBody2D])

func process(entities: Array[Entity], components: Array, delta: float) -> void:
	for entity in entities:
		var trans : C_Transform = entity.get_component(C_Transform)
		var vel : C_Velocity = entity.get_component(C_Velocity)
		
		trans.position += vel.velocity * delta
		entity.global_position = trans.position
