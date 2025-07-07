extends Marker2D
class_name WindOrigin

@export var lungs : Lungs
@export var wind_strength_radial : float = 0.0
@export var wind_strength_linear : float = 0.0

##A Marker2D representing the origin of radial suction/blowing from this wind origin. Should be child of this node.
@export var radial_wind_origin : Marker2D
##A Marker2D representing the origin of linear wind from this wind origin. Should be child of this node.
@export var linear_wind_origin : Marker2D
##A Marker2D representing the direction of linear wind from this wind origin. Should be child of the linear wind origin node!.
@export var linear_wind_direction : Marker2D

###What exponent does the radial wind decay at?
#@export var radial_falloff : float = 1.5
###What exponent does the linear wind decay at?
#@export var linear_falloff : float = 2.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if lungs:
		lungs.breathe_rate.connect(func(rate : float):
			#print("Origin: Rate: %.2f" % rate)
			wind_strength_radial = rate * 15000
			wind_strength_linear = rate * 100
		)

func get_strength(pos : Vector2):
	var radial_component = pos.direction_to(radial_wind_origin.global_position) * (wind_strength_radial / pos.distance_squared_to(radial_wind_origin.global_position))
	var linear_component = linear_wind_direction.position * (wind_strength_linear / pos.distance_squared_to(linear_wind_origin.global_position))
	return radial_component + linear_component
