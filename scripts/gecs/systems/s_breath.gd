extends System
class_name S_Breath

func query() -> QueryBuilder:
	return q.with_all([C_Lungs])

func process(entities: Array[Entity], components: Array, delta: float) -> void:
	for entity in entities:
		var lungs : C_Lungs = entity.get_component(C_Lungs) as C_Lungs
		#Always drain oxygen per tick.
		lungs.oxygen = clampf(lungs.oxygen - (delta * lungs.oxygen_drain_rate), 0, lungs.max_oxygen)
		
		##Used to send data to the wind emitter if it has one.
		var air_power : float = 0.0
		
		match lungs.state:
			C_Lungs.State.IDLE:
				var should_breathe : bool = false
				if lungs.oxygen <= 0:
					should_breathe = true
				elif lungs.oxygen <= lungs.next_breathe_threshold:
					lungs.next_breathe_threshold = -1
					should_breathe = true
				
				if should_breathe:
					#If we have enough air already, exhale
					if lungs.air >= lungs.max_air * 0.2:
						lungs.state = C_Lungs.State.EXHALE
					#Otherwise, inhale.
					else:
						lungs.state = C_Lungs.State.INHALE
				
				elif lungs.air > 0 and randf() < 0.05:
					lungs.state = C_Lungs.State.EXHALE
			
			C_Lungs.State.HOLD:
				if lungs.oxygen <= 0:
					lungs.state = C_Lungs.State.IDLE
			
			C_Lungs.State.INHALE:
				var air_delta : float = do_air(lungs,lungs.inhale_rate, delta)
				air_power = air_delta * lungs.inhale_power
				if lungs.air >= lungs.max_air:
					lungs.time_inhale_stopped = Time.get_ticks_msec()
					lungs.state = C_Lungs.State.IDLE
			
			C_Lungs.State.EXHALE:
				#Randomize the next random breath threshold a single time.
				if lungs.next_breathe_threshold < 0:
					lungs.next_breathe_threshold = randf_range(0,lungs.oxygen_can_breathe_threshold)
				
				var air_delta : float = do_air(lungs,-lungs.exhale_rate, delta)
				air_power = air_delta * lungs.exhale_power
				if lungs.air <= 0:
					lungs.state = C_Lungs.State.IDLE
			
			C_Lungs.State.HITCH:
				var air_delta : float = do_air(lungs,lungs.hitch_rate, delta)
				air_power = air_delta * lungs.hitch_power
				if lungs.air >= lungs.max_air:
					lungs.state = C_Lungs.State.HOLD
			
			C_Lungs.State.SNEEZE:
				var air_delta : float = do_air(lungs,-lungs.sneeze_rate, delta)
				air_power = air_delta * lungs.sneeze_power
				if lungs.air <= 0:
					lungs.state = C_Lungs.State.IDLE
			
			C_Lungs.State.SIGH:
				var air_delta : float = do_air(lungs,-lungs.sigh_rate, delta)
				air_power = air_delta * lungs.sigh_power
				if lungs.air <= 0:
					lungs.state = C_Lungs.State.IDLE
		
		#print("Entity %s lungs state %s, air %f, oxygen %f"%[entity,C_Lungs.State.keys()[lungs.state],lungs.air,lungs.oxygen])
		
		if entity.has_component(C_WindEmitter):
			var emitter : C_WindEmitter = entity.get_component(C_WindEmitter)
			emitter.wind_direction = air_power

func do_air(lungs : C_Lungs, power : float, delta : float) -> float:
	var old_air : float = lungs.air
	var air_delta : float = (power * lungs.max_air) * delta
	lungs.air = clamp(lungs.air + air_delta, 0, lungs.max_air)
	var actual_delta : float = lungs.air - old_air
	
	if actual_delta > 0:
		lungs.oxygen = clampf(lungs.oxygen + (lungs.oxygen_per_air * actual_delta), 0, lungs.max_oxygen)
	return actual_delta
