extends Component
class_name C_WindEmitter

@export_category("Node Links")
@export_node_path("Marker2D") var wind_origin_marker : NodePath

##Strength of wind
@export var wind_power : float = 100
@export var linear_radial_lerp_curve : Curve = preload("uid://bcnn5ac1ounkb")

##Defines the strength to apply depending on the dot product of 
##	the wind's pointing direction relative to the blown object's position.
@export var falloff_curve : Curve = preload("uid://6hg5h6yc0rb7")
@export var distance_falloff_exp : float = 1.0

##From -1 to 1
var wind_direction : float = 0.0
