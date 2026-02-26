@tool
extends Path2D

@export var target_path : Path2D

var _starting_curve : Curve2D
var _length_factor : float
func _ready() -> void:
	_starting_curve = curve.duplicate()
	var own_length : float = curve.get_baked_length()
	var target_length : float = target_path.curve.get_baked_length()
	_length_factor = own_length/target_length
	
func _process(delta: float) -> void:
	pass
