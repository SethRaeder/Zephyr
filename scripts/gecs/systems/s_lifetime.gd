extends System
class_name S_Lifetime

func query() -> QueryBuilder:
	return q.with_all([C_Lifetime])

func process(entities: Array[Entity], components: Array, delta: float) -> void:
	var killed : Array[Entity]
	for entity in entities:
		var life : C_Lifetime = entity.get_component(C_Lifetime)
		life.time -= delta
		if life.time <= 0:
			killed.append(entity)
	
	for entity in killed:
		ECS.world.remove_entity(entity)
