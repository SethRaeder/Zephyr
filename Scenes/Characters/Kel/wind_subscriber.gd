extends Marker2D
class_name WindSubscriber

var wind_vector := Vector2.ZERO
var wind_origins = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.add_to_group("wind");
	
	for wind_node in get_tree().get_nodes_in_group("wind"):
		if wind_node is WindOrigin:
			wind_origins.append(wind_node)

func _physics_process(delta: float) -> void:
	var new_wind = Vector2.ZERO
	for wind_node : WindOrigin in wind_origins:
		new_wind += wind_node.wind_strength * global_position.direction_to(wind_node.global_position) / global_position.distance_squared_to(wind_node.global_position)
		#scale = Vector2.ONE * point_vector.length()
		#rotation = point_vector.angle()
	
	wind_vector = new_wind
	#print("Wind Subscriber: Vector ",wind_vector)
		
		
		##Old Wind Code for funky wind field breathing. Use pull push for now.
		#if wind_strength > 0:
			#var wind_rotation = wind_node.rotation
			#var weight = wind_node.transform.x.dot(point_vector) / 2.0 + 0.5
			#
			#var max_distance = 175
			#var distance = clampf(wind_node.global_position.distance_to(global_position),0,max_distance)
			#
			##print(distance)
			#scale = lerp(Vector2(1.5,1.0), Vector2(0.25,0.25), clampf(distance * weight / max_distance, 0.01, 1.0))
			##print(weight)
			#rotation = lerp_angle(wind_rotation,point_rotation,weight)
		#elif wind_strength < 0:
			#var max_distance = 175
			#var distance = clampf(wind_node.global_position.distance_to(global_position),0,max_distance)
			#scale = lerp(Vector2(1.5,1.0), Vector2(0.25,0.25), clampf(distance / max_distance, 0.01, 1.0))
			#rotation = point_rotation
		#else:
			#scale = Vector2.ZERO
