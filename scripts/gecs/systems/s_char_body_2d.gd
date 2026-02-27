extends System
class_name S_CharacterBody2D

func query() -> QueryBuilder:
	return q.with_all([C_Transform,C_Velocity,C_CharacterBody2D])

func process(entities: Array[Entity], components: Array, delta: float) -> void:
	for entity in entities:
		var velocity = entity.get_component(C_Velocity) as C_Velocity
		var transform = entity.get_component(C_Transform) as C_Transform
		# Set the velocity from the velocity component
		entity.velocity = velocity.velocity
		# Move the entity
		if entity.move_and_slide():
			entity.velocity = Vector2.ZERO
			pass
			## Add a collision event to the entity that just collided to handle collisions
			#var c_collision = C_Collision.new()
			#c_collision.collision = entity.get_last_slide_collision()
			#entity.add_component(c_collision)
		# Set the velocity from the entity to the component
		velocity.velocity = entity.velocity
