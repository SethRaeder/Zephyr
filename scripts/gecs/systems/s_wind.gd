extends System
class_name S_Wind

func query() -> QueryBuilder:
	return q.with_all([C_WindEmitter])

func process(entities: Array[Entity], components: Array, delta: float) -> void:
	#Get all things that can be blown
	var wind_listeners : Array[Entity] = q.with_all([C_CanBeBlown,C_Transform]).execute()
	for listener : Entity in wind_listeners:
		var blow : C_CanBeBlown = listener.get_component(C_CanBeBlown)
		blow.last_wind_vector = Vector2.ZERO
	
	for entity in entities:
		var emitter : C_WindEmitter = entity.get_component(C_WindEmitter) as C_WindEmitter
		#Ignore emitters not emitting.
		if is_zero_approx(emitter.wind_direction):
			continue
		
		var marker : Marker2D = entity.get_node(emitter.wind_origin_marker) as Marker2D
		assert(marker)
		if not marker:
			continue
		var marker_direction : Vector2 = Vector2.RIGHT.rotated(marker.global_rotation)
		
		for listener : Entity in wind_listeners:
			var listener_blow : C_CanBeBlown = listener.get_component(C_CanBeBlown)
			var listener_transform : C_Transform = listener.get_component(C_Transform)
			#Calculate angle to blowable position
			var direction : Vector2 = marker.global_position.direction_to(listener_transform.position).normalized()
			var distance : float = marker.global_position.distance_to(listener_transform.position)
			var dot_product : float = marker_direction.dot(direction)
			var angle_factor : float = emitter.falloff_curve.sample_baked(dot_product)
			var common_component : float = angle_factor * emitter.wind_power * emitter.wind_direction / pow(distance,emitter.distance_falloff_exp)
			var radial_component : Vector2 = -direction * common_component * (dot_product / 2.0 + 0.5)
			#var linear_component : Vector2 = marker_direction * common_component * (dot_product / 2.0 - 0.5)
			
			listener_blow.last_wind_vector = radial_component# + linear_component
			
			var mass : C_Mass = listener.get_component(C_Mass)
			var vel : C_Velocity = listener.get_component(C_Velocity)
			if mass and vel:
				vel.velocity += listener_blow.last_wind_vector / mass.mass_grams
				
			#print("Listner recieved wind vector %v"%wind_vector)
			
